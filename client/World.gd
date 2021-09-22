extends Node2D

var player_spawn = preload("res://Player/PlayerTemplate.tscn")

func SpawnNewPlayer(player_id, spawn_position):
	if get_tree().get_network_unique_id() == player_id:
		pass
	else:
		var new_player = player_spawn.instance()
		new_player.position = spawn_position
		new_player.name = str(player_id)
		get_node("YSort/OtherPlayers").add_child(new_player)
		

func DespawnPlayer(player_id):
	get_node("YSort/OtherPlayers" + str(player_id)).queue_free()
	
