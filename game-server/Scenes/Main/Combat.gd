extends Node

func GetSkillDamage(skill_name, player_id):
	var damage_data = ServerData.skill_data[skill_name].damage
	var damage
	if has_node("../" + str(player_id)):
		var player_strength = get_node("../" + str(player_id)).player_stats.strength
		damage = damage_data + (0.1 * player_strength)
	else: 
		damage = damage_data
	return damage
