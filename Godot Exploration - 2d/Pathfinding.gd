extends Node2D
class_name  Pathfinding

var nav_map: RID

func _ready():
	nav_map = get_world_2d().get_navigation_map()

# start and end are both in world coordinates
func get_new_path(start: Vector2, end:Vector2) -> Array:
	var current_path = NavigationServer2D.map_get_path(nav_map, start, end, false)
	return current_path
