extends Node

var world_state = {}

func _ready():
	pass


func _physics_process(_delta):
	if not get_parent().player_states.empty():
		var players = get_parent().player_states.duplicate(true)
		for player in players.keys():
			players[player].erase("T")
		world_state["T"] = OS.get_system_time_msecs()
		world_state["players"] = players
		world_state["enemies"] = get_node("../World").enemy_list
		# TODOS
		# Verification
		# Anti Cheat
		# Cuts ( chunks / maps / areas )
		# Physics checks
		# Other
		get_parent().SendWorldState(world_state)
		
		
