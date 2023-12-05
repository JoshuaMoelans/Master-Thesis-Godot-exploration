extends Node2D


@export var health:int = 100 : set = set_health, get = get_health

func set_health(h:int) -> void:
	health = clamp(h,0,100)
	
func get_health() -> int:
	return health
