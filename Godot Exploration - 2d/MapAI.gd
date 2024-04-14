extends Node2D
class_name Director

enum PositionMoveOrder {
	FIRST,
	LAST
}

@export var position_move_start : PositionMoveOrder
var position_locations: Array = []
var current_position_index = 0
var pathfinding: Pathfinding

signal game_over

func reduce_count():
	var unit_count = get_child_count()
	if unit_count == 1: # we just killed the last remaining unit
		print("All units died in " + self.get_name())
		game_over.emit()


func initialize(position_locations: Array, pathfinding: Pathfinding):
	self.pathfinding = pathfinding
	for unit:Actor in get_children(): # set pathfinding for all units
		unit.actor_director = self # set unit director to this
		unit.ai.pathfinding  = pathfinding
		unit.ai.initial_locations = position_locations.duplicate()
		unit.ai.set_state(AI.State.PATROL) # set default state to PATROL
	self.position_locations = position_locations
	var next_position = get_next_position()
	if next_position != null and next_position != Vector2.ZERO:
		assign_next_position(next_position)

func get_next_position():
	if self.position_locations.size() == 0:
		return Vector2.ZERO
	var next_position = null
	if self.position_move_start == PositionMoveOrder.FIRST:
		next_position = position_locations[current_position_index]
	else:
		next_position = position_locations[-1-current_position_index]
	current_position_index += 1
	print(current_position_index)
	if current_position_index == position_locations.size():
		current_position_index = current_position_index.size() -1
	return next_position

func assign_next_position(base_location):
	for unit in get_children():
		var randx = base_location.x + randf_range(-50,50)
		var randy = base_location.y + randf_range(-50,50)
		# assign semi-random next position here
		var ai :AI= unit.ai
		ai.next_position = Vector2(randx, randy)
		ai.set_state(AI.State.ADVANCE)

func _physics_process(delta):
	pass
	queue_redraw()

var draw_locations = []

func add_draw_location(location):
	draw_locations.append(location)
	print(location)

func _draw():
	for draw_location in draw_locations: 
		draw_circle(draw_location, 15, Color.HOT_PINK)
