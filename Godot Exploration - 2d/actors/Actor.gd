extends CharacterBody2D
class_name Actor

@onready var collision_shape = $CollisionShape2D
@onready var health = $Health
@onready var ai:AI = $AI
@onready var weapon = $Weapon
@onready var team = $Team
@export var speed:int = 100

var actor_director:Director

signal actor_hit_by(own_team, bullet_team, damage)

func _ready() -> void:
	ai.initialize(self, weapon.get_child(0), team.team)

func handle_hit(by_team:int):
	var dmg = 20 # TODO maybe make parameter of Bullet?
	health.health -= dmg
	ai.update_AI_health(health.health)
	# helper function; takes in actor, text and single piece of data to print
	# gets current actor scope (container and instance) for output
	var container = self.get_parent()
	var instance = container.get_parent()
	actor_hit_by.emit(team.team, by_team, dmg)
	if instance.verbose:
		print(instance.name, "/", container.name, "/", self.name, " got hit")
	if health.health <= 0:
		if instance.verbose:
			print(instance.name, "/", container.name, "/", self.name, " died")
		# send message to director on death			
		actor_director.reduce_count()
		queue_free()

func rotate_toward(location: Vector2):
	rotation = lerp_angle(rotation,global_position.direction_to(location).angle(), 0.2)

func velocity_toward(location: Vector2) -> Vector2:
	return global_position.direction_to(location) * speed

func has_reached_position(location: Vector2) -> bool:
	return global_position.distance_to(location) < randi_range(50,100) # for now, random stopping criterion

func get_team() -> int:
	return team.team

# takes "(x, y)" and returns (x,y) as Vector2 
func str_to_vec2(input:String):
	var outputstr = input.erase(0) # remove (
	outputstr = outputstr.erase(outputstr.length()-1) # remove )
	var outputlist = outputstr.split(",")
	return Vector2(float(outputlist[0]),float(outputlist[1]))

func path_str_to_vec(input):
	var output = []
	for point in input:
		output.append(str_to_vec2(point))
	return output

func set_state(newstate):
	health.health = newstate["health"]
	if health.health <= 0: # if we dead, we dead
		queue_free()
	ai.weapon.set_current_ammo(newstate["ammo"])
	ai.next_position = str_to_vec2(newstate["goal_position"])
	ai.current_path = path_str_to_vec(newstate["path"])
	global_position = str_to_vec2(newstate["position"])
	ai.current_state = newstate["state"]
	ai.AI_State["reload_count"] = newstate["reload_count"]
	ai.previous_state = newstate["previous_state"]
