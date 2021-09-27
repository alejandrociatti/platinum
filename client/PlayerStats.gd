extends Control

onready var dexterity = get_node("NinePatchRect/VBoxContainer/Dexterity/Value")
onready var intelligence = get_node("NinePatchRect/VBoxContainer/Intelligence/Value")
onready var strength = get_node("NinePatchRect/VBoxContainer/Strength/Value")

func _ready():
	GameServer.FetchPlayerStats()
	GameServer.connect("stats_ready", self, "_LoadPlayerStats")
	
func _process(_delta):
	if Input.is_action_just_released("toggle_player_stats"):
		queue_free()
	
func _LoadPlayerStats(stats):
	dexterity.set_text(str(stats.dexterity))
	intelligence.set_text(str(stats.intelligence))
	strength.set_text(str(stats.strength))
