extends Node

signal stats_ready

var network = NetworkedMultiplayerENet.new()
var ip = "127.0.0.1"
var port = 1909

var token

var latency_array = []
var decimal_collector : float = 0
var latency = 0
var delta_latency = 0
var client_clock = 0

func _physics_process(delta):
	client_clock += int(delta*1000) + delta_latency
	delta_latency = 0
	decimal_collector += (delta*1000) - int(delta*1000)
	if decimal_collector >= 1.0:
		client_clock += 1
		decimal_collector -= 1.0

func ConnectToServer():
	network.create_client(ip, port)
	get_tree().set_network_peer(network)
	network.connect("connection_failed", self, "_OnConnectionFailed")
	network.connect("connection_succeeded", self, "_OnConnectionSucceeded")

func _OnConnectionFailed():
	print("Failed to connect")

func _OnConnectionSucceeded():
	emit_signal("ready")
	print("Successfully connected")
	rpc_id(1, "FetchServerTime", OS.get_system_time_msecs())
	var timer = Timer.new()
	timer.wait_time = 0.5
	timer.autostart = true
	timer.connect("timeout", self, "DetermineLatency")
	self.add_child(timer)

func DetermineLatency():
	rpc_id(1, "DetermineLatency", OS.get_system_time_msecs())

remote func ReturnServerTime(server_time, client_time):
	latency = (OS.get_system_time_msecs() - client_time) / 2
	client_clock = server_time + latency

remote func ReturnLatency(client_time):
	latency_array.append((OS.get_system_time_msecs() - client_time) / 2)
	if latency_array.size() == 9:
		var total_latency = 0
		latency_array.sort()
		var mid_point = latency_array[4]
		for i in range(latency_array.size()-1, -1, -1):
			if latency_array[i] > (2 * mid_point) and latency_array[i] > 20:
				latency_array.remove(i)
			else:
				total_latency += latency_array[i]
		delta_latency = (total_latency / latency_array.size()) - latency
		latency = total_latency / latency_array.size()
		# print("new latency ", latency)
		# print("delta latency ", delta_latency)
		latency_array.clear()

func FetchPlayerStats():
	rpc_id(1, "FetchPlayerStats")

func NPCHit(enemy_id, damage):
	print("hit NPC with: " + str(damage) + " damage")
	rpc_id(1, "SendNPCHit", enemy_id, damage)

remote func ReturnPlayerStats(stats):
	emit_signal("stats_ready", stats)

func RequestSkillDamage(skill_name, requester):
	# rpc_id( 1 <- server, 0 <- everybody, or specific peer id
	rpc_id(1, "RequestSkillDamage", skill_name, requester)
	print("actually requested with " + str(skill_name) )

remote func ReturnSkillDamage(response_damage, requester):
	print("returned")
	instance_from_id(requester).SetDamage(response_damage)

remote func FetchToken():
	rpc_id(1, "ReturnToken", token)

remote func ReturnTokenVerificationResults(result):
	if result == true:
		# get_node("../LoginScreen").queue_free()
		# get_tree().change_scene("res://World.tscn")
		print("successful token verification")
	else:
		print("Login failed, try again")
		get_node("../LoginScreen").login_button.disabled = false
		get_node("../LoginScreen").create_account_button.disabled = false

remote func SpawnNewPlayer(player_id, spawn_position):
	get_node("../World").SpawnNewPlayer(player_id, spawn_position)

remote func DespawnPlayer(player_id):
	get_node("../World").DespawnPlayer(player_id)

func SendPlayerState(player_state):
	rpc_unreliable_id(1, "ReceivedPlayerState", player_state)

remote func ReceiveWorldState(world_state):
	get_node("../World").UpdateWorldState(world_state)
	#print("server-clock: ", world_state["T"], " client-clock: ", client_clock)

