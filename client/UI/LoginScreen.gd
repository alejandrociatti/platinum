extends Control

# UI STATE (login , create)
onready var login_screen = get_node("Background/LoginScreen")
onready var create_account_screen = get_node("Background/CreateAccount")
# login nodes
onready var username_input = get_node("Background/LoginScreen/Username")
onready var password_input = get_node("Background/LoginScreen/Password")
onready var login_button = get_node("Background/LoginScreen/LoginButton")
onready var create_account_button = get_node("Background/LoginScreen/CreateAccountButton")
# account nodes
onready var create_username_input = get_node("Background/CreateAccount/Username")
onready var create_userpassword_input = get_node("Background/CreateAccount/Password")
onready var create_userpassword_repeat_input = get_node("Background/CreateAccount/RepeatPassword")
onready var confirm_button = get_node("Background/CreateAccount/ConfirmButton")
onready var back_button = get_node("Background/CreateAccount/BackButton")

func _ready():
	GameServer.connect("ready", self, "_OnServerReady")
	
func _OnServerReady():
	get_tree().change_scene("res://World.tscn")

func _on_LoginButton_pressed():
	if username_input.text == "" or password_input.text == "":
		print("prease provide valid user and/or password")
	else:
		login_button.disabled = true
		create_account_button.disabled = true
		var username = username_input.get_text()
		var password = password_input.get_text()
		print("logging in ... ...")
		Gateway.ConnectToServer(username, password, false)


func _on_CreateAccountButton_pressed():
	login_screen.hide()
	create_account_screen.show()


func _on_BackButton_pressed():
	create_account_screen.hide()
	login_screen.show()


func _on_ConfirmButton_pressed():
	if create_username_input.get_text() == "":
		print("invalid username")
	elif create_userpassword_input.get_text() == "":
		print("provide a password")
	elif create_userpassword_repeat_input.get_text() == "":
		print("provide a password confirmation")
	elif create_userpassword_repeat_input.get_text() != create_userpassword_input.get_text():
		print("password does not match")
	elif create_userpassword_input.get_text().length() <= 6:
		print("password too short. min 7 chars")
	else:
		confirm_button.disabled = true
		back_button.disabled = true
		var username = create_username_input.get_text()
		var password = create_userpassword_input.get_text()
		Gateway.ConnectToServer(username, password, true)
	
