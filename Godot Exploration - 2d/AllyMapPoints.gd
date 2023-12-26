extends Node2D


func get_positions() -> Array:
	var objects = get_children()
	var object_positions = []
	for obj in objects:
		object_positions.append(obj.global_position)
	return object_positions
