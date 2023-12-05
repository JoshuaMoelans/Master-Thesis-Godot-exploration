extends CanvasLayer

@onready var health_bar = $MarginContainer/Rows/BottomRow/HealthSection/HealthBar
@onready var current_ammo = $MarginContainer/Rows/BottomRow/AmmoSection/CurrentAmmo
@onready var max_ammo = $MarginContainer/Rows/BottomRow/AmmoSection/MaxAmmo

var player: Player

func set_player(player: Player):
	self.player = player
	set_new_health_value(player.health.health)
	
	player.connect("player_health_changed", set_new_health_value)
	set_weapon(player.weapon_manager.get_current_weapon())
	player.weapon_manager.connect("weapon_changed", set_weapon)
	
func set_weapon(weapon: Weapon):
	set_current_ammo(weapon.current_ammo)
	set_max_ammo(weapon.max_ammo)
	if not weapon.is_connected("weapon_ammo", set_current_ammo):
		weapon.connect("weapon_ammo", set_current_ammo)
	

func set_new_health_value(new_health: int):
	health_bar.value = new_health

func set_current_ammo(new_ammo: int):
	current_ammo.text = str(new_ammo)
	

func set_max_ammo(new_max_ammo: int):
	max_ammo.text = str(new_max_ammo)
