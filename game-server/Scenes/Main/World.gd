extends Node

var enemy_id_counter = 1
var enemy_maximum = 3
var enemy_types = ["bat"] # list of enemies that can spawn on the map
var enemy_spawn_points = [Vector2(50, 50), Vector2(200, 150), Vector2(220, 50)]
var open_locations = [0, 1, 2]
var occupied_locations = {}
var enemy_list = {}


func _ready():
	var timer = Timer.new()
	timer.wait_time = 3
	timer.autostart = true
	timer.connect("timeout", self, "SpawnEnemy")
	self.add_child(timer)

func SpawnEnemy():
	print("enemy list size: " + str(enemy_list.size()))
	print("open locations size: " + str(open_locations.size()))

	if not enemy_list.size() >= enemy_maximum and not open_locations.size() == 0:
		randomize()
		var type = enemy_types[randi() % enemy_types.size()]
		var rng_location_index = randi() % open_locations.size()
		var location = open_locations[rng_location_index]
		var spawn_point = enemy_spawn_points[location]
		open_locations.remove(rng_location_index)
		enemy_list[enemy_id_counter] = {"type": type, "pos": spawn_point, "health": 10, "max_health": 10, "state": "idle", "timeout": 1}
		occupied_locations[enemy_id_counter] = location
		enemy_id_counter += 1
	for enemy in enemy_list.keys():
		if enemy_list[enemy]["state"] == "dead":
			if enemy_list[enemy]["timeout"] == 0:
				enemy_list.erase(enemy)
			else:
				enemy_list[enemy]["timeout"] -= 1

func NPCHit(enemy_id, damage):
	if enemy_list.has(enemy_id):
		var enemy = enemy_list[enemy_id]
		if not enemy["health"] <= 0:
			enemy["health"] -= damage
			if enemy["health"] <= 0:
				enemy["state"] = "dead"
				open_locations.append(occupied_locations[enemy_id])
				occupied_locations.erase(enemy_id)
