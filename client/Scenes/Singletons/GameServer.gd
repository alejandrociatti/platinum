extends Node

signal stats_ready

var network = NetworkedMultiplayerENet.new()
var ip = "127.0.0.1"
var port = 1909

var token

func _ready():
	pass
	# ConnectToServer()
	
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
	
func FetchPlayerStats():
	rpc_id(1, "FetchPlayerStats")
	
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
		get_node("../LoginScreen").queue_free()
		get_tree().change_scene("res://World.tscn")
		print("successful token verification")
	else:
		print("Login failed, try again")
		get_node("../LoginScreen").login_button.disabled = false
		get_node("../LoginScreen").create_account_button.disabled = false
	
