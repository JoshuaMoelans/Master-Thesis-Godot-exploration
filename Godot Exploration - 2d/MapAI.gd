extends Node2D
class_name Director

enum PositionMoveOrder {
	FIRST,
	LAST
}

@export var position_move_start : PositionMoveOrder
# allows communication of going to 'engage' up to X units away (closest to furthest)
# TODO might need to check for line-of-sight to target first?
@export var communication_count : int = 1
@export var communication_delay : float = 1.5 # takes 1.5s before notifying

var position_locations: Array = []
var current_position_index = 0
var pathfinding: Pathfinding

signal game_over

func reduce_count():
	var unit_count = get_child_count()
	if unit_count == 1: # we just killed the last remaining unit
		print("All units died in " + self.get_name())
		game_over.emit()

func sort_array_on_distance(a, b):
	if a["dist"] < b["dist"]:
		return true
	else:
		return false

func notify_others(unit_under_attack:Actor, unit_to_attack:Actor):
	# timeout has to happen first, else unit(s) might have been killed already
	 # TODO timeout between notifications? Based on distance?
	await get_tree().create_timer(communication_delay).timeout
	var preconditions:bool = (
		(unit_under_attack != null) and
		(unit_to_attack  != null) and
		(get_child_count() > 1) and
		(communication_count > 0))
	if not preconditions:
		return
	# grab the position of the unit
	var unit_position:Vector2 = unit_under_attack.global_position
	# grab all other units
	var units: Array = []
	for unit:Actor in get_children():
		if unit != unit_under_attack:
			var unit_dist = abs(unit_position.distance_to(unit.global_position))
			var unit_entry = {"unit": unit, "dist": unit_dist} 
			units.append(unit_entry)
	units.sort_custom(sort_array_on_distance) # sort on distance
	for i in range(communication_count):
		if i < len(units): # can only communicate to existing units
			# TODO add check if unit is already attacking (to avoid sudden change of interest)
			units[i]["unit"].trigger_attack(unit_to_attack, unit_under_attack) # from closest to furthest, trigger attack

func _ready():
	for unit:Actor in get_children():
		unit.ai.connect("organic_engage",notify_others)

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
