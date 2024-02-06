extends Node2D
class_name AI

@onready var patrol_timer = $PatrolTimer
@onready var path_line = $PathLine

@export var should_draw_path_line: bool = false

signal state_changed(new_state)

# state machine
enum State{
	PATROL,
	ENGAGE,
	ADVANCE
}

var current_state: int = -1 : set = set_state, get = get_state
var previous_state: int = -1
var actor: Actor = null
var target:CharacterBody2D = null
var weapon: Weapon = null
var team: int = -1

var pathfinding: Pathfinding
var initial_locations = []
var current_path = []
# PATROL STATE
var origin: Vector2 = Vector2.ZERO  # default position
var patrol_location: Vector2 = Vector2.ZERO
var patrol_location_reached: bool = false

# ADVANCE STATE
var next_position: Vector2 = Vector2.ZERO

func _ready():
	path_line.visible = should_draw_path_line

func handle_reload():
	weapon.start_reload()


func _physics_process(delta: float) -> void:
	path_line.global_rotation = 0 # reset pathing line rotation
	match current_state:
		State.PATROL:
			if not patrol_location_reached:
				if current_path.size() == 0:
					# caching path for patrol
					current_path = pathfinding.get_new_path(global_position, patrol_location)
				var path = current_path
				if path.size() > 1:
					actor.velocity = actor.velocity_toward(path[1])
					actor.move_and_slide()
					actor.rotate_toward(path[1])
					set_path_line(path)
					if global_position.distance_to(path[1]) < 5:
						current_path.pop_front()  # remove path steps one by one when reaching point
				# keep the line below to avoid 'clumping up' of units.
				# TODO could use tutorial 21.14:30 to do similar 'get random position'
				if global_position.distance_to(patrol_location) < 5:
					patrol_location_reached = true
					actor.velocity = Vector2.ZERO
					patrol_timer.start()
					path_line.clear_points()
					current_path = []
		State.ENGAGE:
			if target != null and weapon != null:
				# Check if target is 'hittable'
				var space_state = get_world_2d().direct_space_state
				# use global coordinates, not local to node
				var query = PhysicsRayQueryParameters2D.create(actor.global_position, target.global_position)
				var result = space_state.intersect_ray(query)
				# TODO what if not hittable now, but by ally/enemy movement they get hittable?
				if not result["collider"].has_method("get_team"):  # check if raycast hits character
					set_state(previous_state)
					return
				elif result["collider"].get_team() == actor.get_team():  # check if same team
					set_state(previous_state)
					return
				actor.rotate_toward(target.global_position)
				var angle_to_target = actor.global_position.direction_to(target.global_position).angle()
				if abs(actor.global_position.angle_to(target.global_position)) < 0.2:
					weapon.shoot()
			else:
				print("Engage state but lacking weapon/target")
				print("\t weapon is: ",str(weapon))
				print("\t target is: ",str(target))
		State.ADVANCE:
			if current_path.size() == 0:
				current_path = pathfinding.get_new_path(global_position, next_position)
			var path = current_path
			if path.size() > 1:
				actor.velocity = actor.velocity_toward(path[1])
				actor.move_and_slide()
				actor.rotate_toward(path[1])
				set_path_line(path)
				if global_position.distance_to(path[1]) < 5:
					current_path.pop_front()  # remove path steps one by one when reaching point
			# keep the line below to avoid 'clumping up' of units.
			# TODO maybe add slight randomization on goal position?
			if actor.global_position.distance_to(next_position) < 50:
				current_path = []
				#print("arrived at advance position")
				if initial_locations.size() != 0:  # if more positions to cover
					next_position = initial_locations.pop_front()
				else:
					set_state(State.PATROL)
				path_line.clear_points()
		_:
			print("Error switch to non-existent state")

func initialize(actor, weapon:Weapon, team:int):
	self.actor = actor
	self.weapon = weapon
	self.team = team
	weapon.connect("weapon_out_of_ammo", handle_reload)
	
func set_path_line(points: Array):
	if not should_draw_path_line:
		return
	var local_points := []
	for point in points:
		if point==points[0]:
			local_points.append(Vector2.ZERO)
		else:
			local_points.append(point - global_position)
	
	path_line.points = local_points

func set_weapon(weapon: Weapon):
	self.weapon = weapon

func set_state(new_state: int):
	previous_state = current_state
	if new_state == current_state:
		return
	current_state = new_state
	if new_state == State.PATROL:
		patrol_timer.start()
		origin = global_position
		patrol_location_reached = true
	elif new_state == State.ADVANCE:
		if actor.has_reached_position(next_position):
			set_state(State.PATROL)
	
func get_state() -> int:
	return current_state

func _on_detection_zone_body_entered(body):
	if body.has_method("get_team") and body.get_team() != team:
		set_state(State.ENGAGE)
		target = body


func _on_detection_zone_body_exited(body):
	if target and body == target:
		set_state(previous_state)
		target = null  # TODO what if target dies, does this trigger?


func _on_patrol_timer_timeout():
	var patrol_range = 100
	var min_patrol_range = 35
	var random_x = randf_range(-patrol_range, patrol_range)
	if random_x > 0:
		clamp(random_x, min_patrol_range, patrol_range)
	else:
		clamp(random_x, -patrol_range, -min_patrol_range)
	var random_y = randf_range(-patrol_range, patrol_range)
	if random_y > 0:
		clamp(random_y, min_patrol_range, patrol_range)
	else:
		clamp(random_y, -patrol_range, -min_patrol_range)
	patrol_location = Vector2(random_x, random_y) + origin
	# TODO add check whether patrol location is reachable
	patrol_location_reached = false
