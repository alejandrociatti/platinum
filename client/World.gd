extends Node2D

var player_spawn = preload("res://Player/PlayerTemplate.tscn")
var enemy_spawn = preload("res://Enemies/EnemyTemplate.tscn")
var last_world_state = 0
var interpolation_offset = 100
var world_state_buffer = []

func process_player_interpolation(player, interpolation_factor):
	if int(player) == get_tree().get_network_unique_id():
		return
	if not world_state_buffer[1]["players"].has(player):
		return
	if get_node("YSort/OtherPlayers").has_node(str(player)):
		var new_position = lerp(world_state_buffer[1]["players"][player]["pos"], world_state_buffer[2]["players"][player]["pos"], interpolation_factor)
		var animation_vector = world_state_buffer[2]["players"][player]["a"]
		get_node("YSort/OtherPlayers/" + str(player)).MovePlayer(new_position, animation_vector)
	else:
		print("spawning player")
		SpawnNewPlayer(player, world_state_buffer[2]["players"][player]["pos"])

func process_enemy_interpolation(enemy, interpolation_factor):
	if not world_state_buffer[1]["enemies"].has(enemy):
		return	
	if get_node("YSort/Enemies").has_node(str(enemy)):
		var new_position = lerp(world_state_buffer[1]["enemies"][enemy]["pos"], world_state_buffer[2]["enemies"][enemy]["pos"], interpolation_factor)
		get_node("YSort/Enemies/" + str(enemy)).MoveEnemy(new_position)
		get_node("YSort/Enemies/" + str(enemy)).Health(world_state_buffer[1]["enemies"][enemy]["health"])
	else:
		SpawnNewEnemy(enemy, world_state_buffer[2]["enemies"][enemy])


func process_player_extrapolation(player, extrapolation_factor):
	if player == get_tree().get_network_unique_id():
		return	
	if not world_state_buffer[0]["players"].has(player):
		return
	if get_node("YSort/OtherPlayers").has_node(str(player)):
		var position_delta = (world_state_buffer[1]["players"][player]["pos"] - world_state_buffer[0]["players"][player]["pos"])
		var new_position = world_state_buffer[1]["players"][player]["pos"] + (position_delta * extrapolation_factor)
		var animation_vector = world_state_buffer[1]["players"][player]["a"]
		get_node("YSort/OtherPlayers/" + str(player)).MovePlayer(new_position, animation_vector)
	else:
		print("spawning player")
		SpawnNewPlayer(player, world_state_buffer[2]["players"][player]["pos"])

func process_enemy_extrapolation(enemy, extrapolation_factor):
	if not world_state_buffer[0]["enemies"].has(enemy):
		return	
	if get_node("YSort/Enemies").has_node(str(enemy)):
		var position_delta = (world_state_buffer[1]["enemies"][enemy]["pos"] - world_state_buffer[0]["enemies"][enemy]["pos"])
		var new_position = world_state_buffer[1]["enemies"][enemy]["pos"] + (position_delta * extrapolation_factor)
		get_node("YSort/Enemies/" + str(enemy)).MoveEnemy(new_position)
	else:
		print("spawning enemy")
		SpawnNewEnemy(enemy, world_state_buffer[2]["enemies"][enemy]["pos"])

func _physics_process(_delta):
	var render_time = GameServer.client_clock - interpolation_offset
	if world_state_buffer.size() > 1:
		while world_state_buffer.size() > 2 and render_time > world_state_buffer[2].T:
			world_state_buffer.remove(0)
		if world_state_buffer.size() > 2: # we have a future state
			var interpolation_factor = (
				float(render_time - world_state_buffer[1]["T"]) /
				float(world_state_buffer[2]["T"] - world_state_buffer[1]["T"])
			)
			for player in world_state_buffer[2]["players"].keys():
				process_player_interpolation(player, interpolation_factor)
			for enemy in world_state_buffer[2]["enemies"].keys():
				process_enemy_interpolation(enemy, interpolation_factor)
		elif render_time > world_state_buffer[1].T:
			var extrapolation_factor = (
				float(render_time - world_state_buffer[0]["T"]) /
				float(world_state_buffer[1]["T"] - world_state_buffer[0]["T"])
			) - 1.0 # deduct time passed between the two states
			for player in world_state_buffer[1]["players"].keys():
				process_player_extrapolation(player, extrapolation_factor)
			for enemy in world_state_buffer[1]["enemies"].keys():
				process_enemy_extrapolation(enemy, extrapolation_factor)


func SpawnNewPlayer(player_id, spawn_position):
	if get_tree().get_network_unique_id() == player_id:
		pass
	else:
		if not get_node("YSort/OtherPlayers").has_node(str(player_id)):
			var new_player = player_spawn.instance()
			new_player.position = spawn_position
			new_player.name = str(player_id)
			get_node("YSort/OtherPlayers").add_child(new_player)


func SpawnNewEnemy(enemy_id, enemy_dict):
	var new_enemy = enemy_spawn.instance()
	new_enemy.position = enemy_dict["pos"]
	new_enemy.max_health = enemy_dict["max_health"]
	new_enemy.health = enemy_dict["health"]
	new_enemy.type = enemy_dict["type"]
	new_enemy.state = enemy_dict["state"]
	new_enemy.name = str(enemy_id)
	get_node("YSort/Enemies").add_child(new_enemy, true)


func DespawnPlayer(player_id):
	yield(get_tree().create_timer(0.2), "timeout")
	get_node("YSort/OtherPlayers/" + str(player_id)).queue_free()


func UpdateWorldState(world_state):
	if world_state["T"] > last_world_state:
		last_world_state = world_state["T"]
		world_state_buffer.append(world_state)

