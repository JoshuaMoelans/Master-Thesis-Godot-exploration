extends Area2D
class_name Bullet

@export var SPEED:float = 10.0
@export var PIERCE:int = 0  # don't pierce by default
var dir:= Vector2.ZERO

@onready var kill_timer = $KillTimer

func _ready() -> void:
	kill_timer.start()

func _physics_process(delta):
	if dir != Vector2.ZERO:
		var velocity = dir * SPEED
		global_position += velocity

func set_direction(dir:Vector2):
	self.dir = dir


func _on_kill_timer_timeout():
	queue_free()


func _on_body_entered(body):
	if body.has_method("handle_hit"):  # anything that can be hit by a bullet needs this method implemented
		body.handle_hit()
	PIERCE -= 1
	if PIERCE < 0:
		queue_free()  # destroy bullet after it hits a body
