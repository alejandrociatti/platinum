extends Node

var skill_data
var test_data = {
	"stats": {
		"constitution": 16,
		"dexterity": 18,
		"strength": 12,
		"intelligence": 18,
		"wisdom": 16,
	}
}

# Called when the node enters the scene tree for the first time.
func _ready():
	var skill_data_file = File.new()
	skill_data_file.open("res://Data/skill_data.json", File.READ)
	var skill_data_json = JSON.parse(skill_data_file.get_as_text())
	skill_data_file.close()
	skill_data = skill_data_json.result
	print(skill_data)
