extends Node

var enemy_id_counter = 1
var enemy_maximum = 3
var enemy_types = ["bat"] # list of enemies that can spawn on the map
var enemy_spawn_points = [Vector2(50, 50)]
var open_locations = [0]
var occupied_locations = {}
var enemy_list = {}


func _ready():
	var timer = Timer.new()
	timer.wait_time = 3
	timer.autostart = true
	timer.connect("timeout", self, "SpawnEnemy")
	self.add_child(timer)

func SpawnEnemy():
	if not enemy_list.size() >= enemy_maximum:
		randomize()
		var type = enemy_types[randi() % enemy_types.size()]
		var rng_location_index = randi() % open_locations.size()
		var location = enemy_spawn_points[open_locations[rng_location_index]]
		open_locations.remove(rng_location_index)
		enemy_list[enemy_id_counter] = {"type": type, "location": location, "health": 10, "max_health": 10, "state": "idle", "timeout": 1}
		enemy_id_counter += 1
	for enemy in enemy_list.keys():
		if enemy_list[enemy]["state"] == "dead":
			if enemy_list[enemy]["timeout"] == 0:
				enemy_list.erase(enemy)
			else:
				enemy_list[enemy]["timeout"] -= 1
	
