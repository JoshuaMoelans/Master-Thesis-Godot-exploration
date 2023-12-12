extends Node2D
class_name  Weapon

signal weapon_fired(bullet, location, direction)
signal weapon_out_of_ammo()
signal weapon_ammo(new_ammo_count)

@export var max_ammo = 10
@export var semi_auto = true
var current_ammo: int = max_ammo : set = set_current_ammo
var is_reloading: bool = false

@export var Bullet:PackedScene
@onready var end_of_gun = $EndOfGun
@onready var animation_player = $AnimationPlayer
@onready var muzzle_flash = $MuzzleFlash
@onready var audio_player = $AudioStreamPlayer2D
@onready var attack_cooldown = $AttackCooldown

func _ready():
	current_ammo = max_ammo
	muzzle_flash.hide()

func shoot():
	if current_ammo == 0 or is_reloading == true:
		return
	if attack_cooldown.is_stopped() and Bullet != null:
		audio_player.play()
		animation_player.play("muzzleflash")
		var bullet_instance = Bullet.instantiate()
		var direction = (end_of_gun.global_position-global_position).normalized()
		GlobalSignals.emit_signal("bullet_fired", bullet_instance, end_of_gun.global_position, direction)
		attack_cooldown.start()
		set_current_ammo(current_ammo-1)
			
func set_current_ammo(new_ammo:int):
	var actual_ammo = clamp(new_ammo, 0, max_ammo)
	if actual_ammo != current_ammo:
		current_ammo = actual_ammo
		if current_ammo == 0:
			weapon_out_of_ammo.emit()
		weapon_ammo.emit(current_ammo)
	
func start_reload():
	animation_player.play("reload")
	is_reloading = true

func _stop_reload():
	set_current_ammo(max_ammo)
	is_reloading = false
