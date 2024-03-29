extends Node

var network = NetworkedMultiplayerENet.new()
var port = 1909
var max_players = 100

var expected_tokens = []
var player_states = {}

onready var player_verification_process = get_node("PlayerVerification")
onready var combat_functions = get_node("Combat")


# Called when the node enters the scene tree for the first time.
func _ready():
	StartServer()

func StartServer():
	network.create_server(port, max_players)
	get_tree().set_network_peer(network)
	print("Server Startedi !!")
	network.connect("peer_connected", self, "_Peer_Connected")
	network.connect("peer_disconnected", self, "_Peer_Disconnected")

func _Peer_Connected(player_id):
	print("User " + str(player_id) + " Connected.")
	player_verification_process.start(player_id)
	
func _Peer_Disconnected(player_id):
	print("User " + str(player_id) + " Disconnected.")
	if has_node(str(player_id)):
		get_node(str(player_id)).queue_free()
		player_states.erase(player_id)
		rpc_id(0, "DespawnPlayer", player_id)
	
remote func RequestSkillDamage(skill_name, requester):
	var player_id = get_tree().get_rpc_sender_id()
	var damage = combat_functions.GetSkillDamage(skill_name, player_id)
	rpc_id(player_id, "ReturnSkillDamage", damage, requester)
	print("sending " + str(damage) + " back to " + str(player_id) + " for skill: " + str(skill_name))

remote func FetchPlayerStats():
	var player_id = get_tree().get_rpc_sender_id()
	var player_stats = get_node(str(player_id)).player_stats
	rpc_id(player_id, "ReturnPlayerStats", player_stats)

func _on_TokenExpiration_timeout():
	var current_time = OS.get_unix_time()
	var token_time
	if expected_tokens == []:
		pass
	else:
		for i in range(expected_tokens.size() -1, -1, -1):
			token_time = int(expected_tokens[i].right(64))
			if current_time - token_time >= 30:
				expected_tokens.remove(i)
	# print("expected tokens")
	# print(expected_tokens)

remote func FetchServerTime(client_time):
	var player_id = get_tree().get_rpc_sender_id()
	rpc_id(player_id, "ReturnServerTime", OS.get_system_time_msecs(), client_time)

remote func DetermineLatency(client_time):
	var player_id = get_tree().get_rpc_sender_id()
	rpc_id(player_id, "ReturnLatency", client_time)
	
func FetchToken(player_id):
	rpc_id(player_id, "FetchToken")

remote func ReturnToken(token):
	var player_id = get_tree().get_rpc_sender_id()
	player_verification_process.Verify(player_id, token)
	
func ReturnTokenVerificationResults(player_id, result):
	rpc_id(player_id, "ReturnTokenVerificationResults", result)
	if result:
		rpc_id(0, "SpawnNewPlayer", player_id, Vector2(50, 50))
		
remote func ReceivedPlayerState(player_state):
	var player_id = get_tree().get_rpc_sender_id()
	if player_states.has(player_id):
		if player_states[player_id]["T"] < player_state["T"]: # if player state is newer
			player_states[player_id] = player_state
	else:
		player_states[player_id] = player_state # add to state if not present

func SendWorldState(world_state):
	rpc_unreliable_id(0, "ReceiveWorldState", world_state)

remote func SendNPCHit(enemy_id, damage):
	get_node("World").NPCHit(enemy_id, damage)

remote func Attack(position, animation_vector, spawn_time):
	var player_id = get_tree().get_rpc_sender_id()
	rpc_id(0, "ReceiveAttack", position, animation_vector, spawn_time, player_id)
