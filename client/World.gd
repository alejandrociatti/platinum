extends Node2D

var player_spawn = preload("res://Player/PlayerTemplate.tscn")
var last_world_state = 0
# TODO
var interpolation_offset = 100
var world_state_buffer = []

func _physics_process(delta):
	var render_time = OS.get_system_time_msecs() - interpolation_offset
	if world_state_buffer.size() > 1:
		while world_state_buffer.size() > 2 and render_time > world_state_buffer[1].T:
			world_state_buffer.remove(0)
		var interpolation_factor = (
			float(render_time - world_state_buffer[0]["T"]) / 
			float(world_state_buffer[1]["T"] - world_state_buffer[0]["T"])
		)
		for player in world_state_buffer[1].keys():
			if str(player) == "T":
				continue
			if player == get_tree().get_network_unique_id():
				continue
			if not world_state_buffer[0].has(player):
				continue
			if get_node("YSort/OtherPlayers").has_node(str(player)):
				var new_position = lerp(world_state_buffer[0][player]["P"], world_state_buffer[1][player]["P"], interpolation_factor)
				get_node("YSort/OtherPlayers/" + str(player)).MovePlayer(new_position)
	
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
	if world_state["T"] > last_world_state:
		last_world_state = world_state["T"]
		world_state_buffer.append(world_state)
	
func UpdateWorldState_OLD(world_state):
	# Buffer
	# Interpolation
	# Extrapolation
	# Rubber Banding
		for player in world_state.keys():
			if get_node("YSort/OtherPlayers").has_node(str(player)):
				get_node("YSort/OtherPlayers/" + str(player)).MovePlayer(world_state[player]["P"])
			else:
				print("spawning player")
				SpawnNewPlayer(player, world_state[player]["P"])
	
