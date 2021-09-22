extends Node

func _ready():	
	get_tree().change_scene("res://UI/LoginScreen.tscn")
	GameServer.connect("ready", self, "_OnServerReady")
	
func _OnServerReady():
	pass
	# get_tree().change_scene("res://World.tscn")
