extends Node2D

var player_spawn = preload("res://Player/PlayerTemplate.tscn")
var last_world_state = 0

func SpawnNewPlayer(player_id, spawn_position):
	if get_tree().get_network_unique_id() == player_id:
		pass
	else:
		if not get_node("YSort/OtherPlayers").has_node(str(player_id)):
			var new_player = player_spawn.instance()
			new_player.position = spawn_position
			new_player.name = str(player_id)
			get_node("YSort/OtherPlayers").add_child(new_player)
		

func DespawnPlayer(player_id):
	get_node("YSort/OtherPlayers/" + str(player_id)).queue_free()
	
func UpdateWorldState(world_state):
	# Buffer
	# Interpolation
	# Extrapolation
	# Rubber Banding
	if world_state["T"] > last_world_state:
		last_world_state = world_state["T"]
		world_state.erase("T") # will use later for inter/extra-polation
		world_state.erase(get_tree().get_network_unique_id()) # erase local player (maybe use l8r?)
		for player in world_state.keys():
			if get_node("YSort/OtherPlayers").has_node(str(player)):
				get_node("YSort/OtherPlayers/" + str(player)).MovePlayer(world_state[player]["P"])
			else:
				print("spawning player")
				SpawnNewPlayer(player, world_state[player]["P"])
	
