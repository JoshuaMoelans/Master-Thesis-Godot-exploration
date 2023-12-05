extends Node2D

signal weapon_changed(weapon: Weapon)

@onready var current_weapon: Weapon = $Pistol
var weapons: Array = []

func _ready() -> void:
	weapons = get_children()
	
	for weapon in weapons:
		weapon.hide()
	current_weapon.show()

func _unhandled_input(event: InputEvent):
	if current_weapon.semi_auto and event.is_action_pressed("shoot"):
		current_weapon.shoot()
	elif event.is_action_pressed("reload"):
		current_weapon.start_reload()
	elif event.is_action_pressed("command"):
		GlobalSignals.emit_signal("move_allies", get_global_mouse_position())
	elif event.is_action_pressed("weapon_1"):
		switch_weapon(weapons[0])
	elif event.is_action_pressed("weapon_2"):
		switch_weapon(weapons[1])
	pass

func _process(delta):
	if not current_weapon.semi_auto and Input.is_action_pressed("shoot"):
		current_weapon.shoot()

func switch_weapon(weapon: Weapon):
	if weapon == current_weapon:
		return
	current_weapon.hide()
	weapon.show()
	current_weapon = weapon
	weapon_changed.emit(current_weapon)

func get_current_weapon() -> Weapon:
	return current_weapon
	
func reload():
	current_weapon.start_reload()

