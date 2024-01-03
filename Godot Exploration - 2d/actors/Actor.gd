extends CharacterBody2D
class_name Actor

@onready var collision_shape = $CollisionShape2D
@onready var health = $Health
@onready var ai = $AI
@onready var weapon = $Weapon
@onready var team = $Team
@export var speed:int = 100

var actor_director:Director

func _ready() -> void:
	ai.initialize(self, weapon.get_child(0), team.team)

func handle_hit():
	health.health -= 20
	if health.health <= 0:
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
