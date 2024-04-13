extends Node2D
class_name  Pathfinding

var nav_map: RID

func _ready():
	nav_map = get_world_2d().get_navigation_map()

# start and end are both in world coordinates
func get_new_path(start: Vector2, end:Vector2) -> Array:
	var current_path = NavigationServer2D.map_get_path(nav_map, start, end, false)
	return current_path

# returns whether position is obstacle tile or not
func check_position_clear(goal: Vector2) -> bool:
	var tile_map :TileMap = get_parent().get_child(0)
	var goal_m = tile_map.local_to_map(goal)
	var tiledata0m = tile_map.get_cell_tile_data(0, goal_m)
	if tiledata0m.get_collision_polygons_count(0) > 0:
		return false
	return true
	
