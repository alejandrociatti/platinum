extends Node

var network = NetworkedMultiplayerENet.new()
var ip = "127.0.0.1"
var port = 1911

func _ready():
	ConnectToServer()
	
func ConnectToServer():
	network.create_client(ip, port)
	get_tree().set_network_peer(network)
	network.connect("connection_failed", self, "_OnConnectionFailed")
	network.connect("connection_succeeded", self, "_OnConnectionSucceeded")
	
func _OnConnectionSucceeded():
	print("Success: connected to auth server")
	
	
func _OnConnectionFailed():
	print("Failure: connection to auth server")
 
func AuthenticatePlayer(username, password, player_id):
	print("sending out auth request")
	rpc_id(1, "AuthenticatePlayer", username, password, player_id)
	
remote func AuthenticationResults(result, player_id, token):
	print("results received and replying to player login req")
	Gateway.ReturnLoginRequest(result, player_id, token)
	
func CreateAccount(username, password, player_id):
	print("sending new account request...")
	rpc_id(1, "CreateAccount", username, password, player_id)
	
remote func CreateAccountResults(result, player_id, message):
	print("result received, replying to player")
	Gateway.ReturnCreateAccountRequest(result, player_id, message)
