extends Camera2D

var player_ref

var zoomSpeed = 10
var zoomStep = 0.1

var zoomMin = 0.1
var zoomMax = 2

@export var new_zoom = 1.0

func _ready():
	player_ref = get_parent()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	zoom.x = lerp(zoom.x, new_zoom, zoomSpeed * delta)
	zoom.y = lerp(zoom.y, new_zoom, zoomSpeed * delta)
	
	zoom.x = clamp(zoom.x, zoomMin, zoomMax)
	zoom.y = clamp(zoom.y, zoomMin, zoomMax)

	player_ref.SPEED = 500*(zoomMax*1.5-zoom.x)

	

func _input(event):
	if Input.is_action_pressed("zoom_in"):
		new_zoom += zoomStep
	elif Input.is_action_pressed("zoom_out"):
		new_zoom -= zoomStep
	new_zoom = float(clamp(new_zoom, zoomMin, zoomMax))


