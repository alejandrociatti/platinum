extends KinematicBody2D

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var swordHitbox = $HitboxPivot/SwordHitbox
onready var hurtbox = $Hurtbox
onready var blinkAnimationPlayer = $BlinkAnimationPlayer

var state = "Idle"
var attack_dict = {}

func _ready():
	animationTree.active = true
	swordHitbox.SetOriginal(false)

func _physics_process(_delta):
	if not attack_dict == {}:
		Attack()

func MovePlayer(new_position, animation_vector):
	if not state == "Attack":
		animationTree.set("parameters/Idle/blend_position", animation_vector)
		animationTree.set("parameters/Run/blend_position", animation_vector)
		animationTree.set("parameters/Attack/blend_position", animation_vector)
		animationTree.set("parameters/Roll/blend_position", animation_vector)
		if new_position == position:
			state = "Idle"
			animationState.travel("Idle")
		else:
			state = "Run"
			swordHitbox.knockback_vector = animation_vector
			animationState.travel("Run")
			set_position(new_position)

func Attack():
	for attack_time in attack_dict.keys():
		if attack_time <= GameServer.client_clock:
			var attack = attack_dict[attack_time]
			state = "Attack"
			animationTree.set("parameters/Attack/blend_position", attack["a"])
			animationState.travel("Attack")
			set_position(attack["pos"])
			attack_dict.erase(attack_time)

func attack_animation_finished():
	state = "Idle"

func _on_Hurtbox_area_entered(_area):
	hurtbox.start_invincibility(0.6)
	hurtbox.create_hit_effect()

func _on_Hurtbox_invincibility_started():
	blinkAnimationPlayer.play("Start")

func _on_Hurtbox_invincibility_ended():
	blinkAnimationPlayer.play("Stop")

