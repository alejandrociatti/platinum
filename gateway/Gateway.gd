extends Node

var network = NetworkedMultiplayerENet.new()
var gateway_api = MultiplayerAPI.new()
var port = 1910
var max_players = 100
var cert_path = "res://certificate/platinum-certx509_certificate.crt"
var key_path = "res://certificate/platinum-certx509_key.key"
var cert = load(cert_path)
var key = load(key_path)

func _ready():
	StartServer()
	
func _process(_delta):
	if not custom_multiplayer.has_network_peer():
		return;
	custom_multiplayer.poll();
	
func StartServer():
	network.set_dtls_enabled(true)
	network.set_dtls_key(key)
	network.set_dtls_certificate(cert)
	network.create_server(port, max_players)
	set_custom_multiplayer(gateway_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	print("Gateway server started")
	network.connect("peer_connected", self, "_PeerConnected")
	network.connect("peer_disconnected", self, "_PeerDisconnected")
	
func _PeerConnected(player_id):
	print("User " + str(player_id) + " Connected")
	 
	
func _PeerDisconnected(player_id):
	print("User " + str(player_id) + " disconnected")
	

remote func LoginRequest(username, password):
	print("login request received")
	var player_id = custom_multiplayer.get_rpc_sender_id()
	Authenticate.AuthenticatePlayer(username, password, player_id)
	
func ReturnLoginRequest(result, player_id, token):
	var mystr
	if result:
		mystr = "received : true"
	else:
		mystr = "receoved : false	"
	print(mystr)
	rpc_id(player_id, "ReturnLoginRequest", result, token)
	network.disconnect_peer(player_id)

remote func CreateAccountRequest(username, password):
	var player_id = custom_multiplayer.get_rpc_sender_id()
	var valid_request = true
	if username == "" || password == "":
		valid_request = false
	elif password.length() <= 6:
		valid_request = false
	
	if not valid_request:
		ReturnCreateAccountRequest(valid_request, player_id, 1)
	else:
		Authenticate.CreateAccount(username.to_lower(), password, player_id)
		
func ReturnCreateAccountRequest(result, player_id, message):
	rpc_id(player_id, "ReturnCreateAccountRequest", result, message)
	# 1= failed to create, 2= existing user, 3= welcome
	network.disconnect_peer(player_id)
