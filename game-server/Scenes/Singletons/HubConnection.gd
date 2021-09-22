extends Node

var network = NetworkedMultiplayerENet.new()
var gateway_api = MultiplayerAPI.new()
var ip = "127.0.0.1"
var port = 1912

onready var gameserver = get_node("/root/GameServer")

# Called when the node enters the scene tree for the first time.
func _ready():
	ConnectToServer()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if get_custom_multiplayer() == null:
		return
	if not custom_multiplayer.has_network_peer():
		return;
	custom_multiplayer.poll();
	
func ConnectToServer():
	network.create_client(ip, port)
	set_custom_multiplayer(gateway_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	
	network.connect("connection_failed", self, "_OnConnectionFailed")
	network.connect("connection_succeeded", self, "_OnConnectionSucceeded")
	
func _OnConnectionFailed():
	print("failed to connect to GS Hub")
	
func _OnConnectionSucceeded():
	print("successfully connected to GS Hub")
	
remote func ReceiveLoginToken(token):
	gameserver.expected_tokens.append(token)
