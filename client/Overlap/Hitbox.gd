extends Area2D

var damage = 1
export var skill_name = "sword"

func _ready():
	GameServer.RequestSkillDamage(skill_name, get_instance_id())
	print("requested")
	
func SetDamage(response_damage):
	damage = response_damage
	print("set")
	
