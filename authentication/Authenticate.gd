extends Node

var network  = NetworkedMultiplayerENet.new()
var port = 1911
var max_servers = JOY_AXIS_5

func _ready():
	StartServer()
	
func StartServer():
	network.create_server(port, max_servers)
	get_tree().set_network_peer(network)
	print("Auth server started")
	
	network.connect("peer_connected", self, "_PeerConnected")
	network.connect("peer_disconnected", self, "_PeerDisonnected")
	
func _PeerConnected(gateway_id):
	print("Gateway " + str(gateway_id) + " Connected")
	
func _PeerDisconnected(gateway_id):
	print("Gateway " + str(gateway_id) + " Disonnected")
	
remote func AuthenticatePlayer(username, pwd, player_id):
	var token
	var gateway_id = get_tree().get_rpc_sender_id()
	var result
	if not PlayerData.PlayerIDs.has(username):
		print("invalid user")
		result = false
	elif not PlayerData.PlayerIDs[username].password == pwd:
		print("invalid password")
		result = false
	else:
		print("successful auth")
		result = true	
	randomize()
	token = str(randi()).sha256_text() + str(OS.get_unix_time())
	var gameserver = "GameServer1"
	GameServers.DistributeLoginToken(token, gameserver)
	rpc_id(gateway_id, "AuthenticationResults", result, player_id, token)
	
remote func CreateAccount(username, password, player_id):
	var gateway_id = get_tree().get_rpc_sender_id()
	var result
	var message
	if PlayerData.PlayerIDs.has(username):
		result = false
		message = 2
	else:
		result = true
		message = 3
		PlayerData.PlayerIDs[username] = {"password": password}
		PlayerData.SavePlayerIDs()
	rpc_id(gateway_id, "CreateAccountResults", result, player_id, message)	
