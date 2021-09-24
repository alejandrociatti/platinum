extends Node

var world_state = {}

func _ready():
	pass


func _physics_process(_delta):
	if not get_parent().player_states.empty():
		world_state = get_parent().player_states.duplicate(true)
		for player in world_state.keys():
			world_state[player].erase("T")
		world_state["T"] = OS.get_system_time_msecs()
		world_state["enemies"] = get_node("../World").enemy_list
		# TODOS
		# Verification
		# Anti Cheat
		# Cuts ( chunks / maps / areas )
		# Physics checks
		# Other
		get_parent().SendWorldState(world_state)
		
		
