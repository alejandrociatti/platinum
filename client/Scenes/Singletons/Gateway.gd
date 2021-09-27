extends Node

var network # = NetworkedMultiplayerENet.new()
var gateway_api # = MultiplayerAPI.new()
var ip = "127.0.0.1"
var port = 1910
var cert = load("res://certificate/platinum-certx509_certificate.crt")

var username
var password
var new_account = false

func _ready():
	pass
	
func _process(_delta):
	if get_custom_multiplayer() == null:
		return
	if not custom_multiplayer.has_network_peer():
		return;
	custom_multiplayer.poll();
	
func ConnectToServer(_username, _password, _new_account):
	network = NetworkedMultiplayerENet.new()
	gateway_api = MultiplayerAPI.new()
	network.set_dtls_enabled(true)
	network.set_dtls_verify_enabled(false)
	network.set_dtls_certificate(cert)
	username = _username
	password = _password
	new_account = _new_account
	network.create_client(ip, port)
	set_custom_multiplayer(gateway_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	network.connect("connection_failed", self, "_OnConnectionFailed")
	network.connect("connection_succeeded", self, "_OnConnectionSucceeded")
	
func _OnConnectionFailed():
	print("Failed to connect to login server")
	# TODO: popup error msg, server online, whatever
	# TODO: disable login button
	get_node("../LoginScreen").login_button.disabled = false
	get_node("../LoginScreen").create_account_button.disabled = false
	get_node("../LoginScreen").confirm_button.disabled = false
	get_node("../LoginScreen").back_button.disabled = false
	
func _OnConnectionSucceeded():
	print("Successfully connected to login server")
	if new_account:
		RequestCreateAccount()
	else:
		emit_signal("ready")
		RequestLogin()
	
	 
func RequestLogin():
	print("connect to gateway to request login")
	rpc_id(1, "LoginRequest", username, password.sha256_text())
	username = ""
	password = ""

func RequestCreateAccount():
	print("requesting new account")
	rpc_id(1, "CreateAccountRequest", username, password.sha256_text())
	username = ""
	password = ""

remote func ReturnLoginRequest(results, token):
	if results == true:
		GameServer.token = token
		GameServer.ConnectToServer()
		# TODO: remove login scene and load game scene
		# get_tree().change_scene("res://World.tscn")
		# self.queue_free()
	else:
		print("please provide valid credentials")
		get_node("../LoginScreen").login_button.disabled = false
		get_node("../LoginScreen").create_account_button.disabled = false
	network.disconnect("connection_failed", self, "_OnConnectionFailed")
	network.disconnect("connection_succeeded", self, "_OnConnectionSucceeded")
	
remote func ReturnCreateAccountRequest(results, message):
	print("results received")
	if results:
		print("account created, now you can log in")
		get_node("../LoginScreen")._on_BackButton_pressed()
	else:
		if message == 1:
			print("failed to create, try again")
		elif message == 2:
			print("username in use, please choose other") 	
		get_node("../LoginScreen").back_button.disabled = false
		get_node("../LoginScreen").confirm_button.disabled = false
	network.disconnect("connection_failed", self, "_OnConnectionFailed")
	network.disconnect("connection_succeeded", self, "_OnConnectionSucceeded")
