extends KinematicBody2D

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

onready var health_bar = get_node("HPBar")
onready var health_bar_tween = get_node("HPBar/Tween")
onready var hurtbox = $Hurtbox
onready var animationPlayer = $AnimationPlayer

var health = 0.0
var max_health = 0
var state = "idle"
var type # not used for now

func _ready():
	var percentage = int(health / max_health * 100)
	health_bar.value = percentage
	if state == "idle":
		pass
	elif state == "dead":
		kill_enemy(false)

func OnHit(damage):
	GameServer.NPCHit(int(get_name()), damage)

func MoveEnemy(_new_position):
	pass # TODO

func _on_Hurtbox_area_entered(area):
	hurtbox.create_hit_effect()
	OnHit(area.damage)
	hurtbox.start_invincibility(0.4)

func Health(new_health):
	if new_health != health:
		health = new_health
		update_health_bar()
		if health <= 0:
			kill_enemy(true)
	if health <= 0:
		kill_enemy(false)

func update_health_bar():
	var percentage = int(health / max_health * 100)
	print("health " + str(health) + " max : " + str(max_health) + " perc: " + str(percentage)) 
	health_bar_tween.interpolate_property(health_bar, 'value', health_bar.value, percentage, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT) 
	health_bar_tween.start()
	if percentage >= 50:
		health_bar.set_tint_progress("14E114") # green
	elif percentage <= 50 and percentage >= 25:
		health_bar.set_tint_progress("E1BE32") # orange
	else:
		health_bar.set_tint_progress("E11E1E") # red	
	
func enable_health_bar():
	health_bar.show()
	
func disable_health_bar():
	health_bar.hide()

func kill_enemy(animate_death):
	disable_health_bar()
	get_node("AnimationPlayer").stop()
	get_node("Hurtbox").set_deferred("disabled", true)
	get_node("Hitbox").set_deferred("disabled", true)
	get_node("SoftCollision").set_deferred("disabled", true)
	# queue_free()
	self.hide()
	if animate_death:
		var enemyDeathEffect = EnemyDeathEffect.instance()
		get_parent().add_child(enemyDeathEffect)
		enemyDeathEffect.global_position = global_position

func _on_Hurtbox_invincibility_started():
	animationPlayer.play("Start")

func _on_Hurtbox_invincibility_ended():
	animationPlayer.play("Stop")
