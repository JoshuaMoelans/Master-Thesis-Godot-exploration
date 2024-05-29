extends Area2D

@onready var visionCone = $CollisionPolygon2D

func setCone(angle, distance, resolution=30):
	# Convert angle from degrees to radians
	angle = angle * PI / 180
	var half_angle = angle / 2
	var step = angle / resolution

	var points = PackedVector2Array()
	points.append(Vector2(0, 0))  # Start point

	# Generate points for the vision cone
	for i in range(resolution + 1):
		var theta = -half_angle + step * i
		var x = distance * cos(theta)
		var y = distance * sin(theta)
		points.append(Vector2(x, y))

	points.append(Vector2(0, 0))  # End point

	visionCone.polygon = points
