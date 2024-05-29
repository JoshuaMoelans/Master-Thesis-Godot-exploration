extends Area2D

@onready var visionCone = $CollisionPolygon2D

func setCone(angle, distance):
	# sets CollisionPolygon2D dimensions based on a given vision angle and view distance
	var x_cord = distance
	var y_cord = tan(angle/2)*distance
	var start = Vector2(0,0)
	var top = Vector2(x_cord, y_cord)
	var bot = Vector2(x_cord, -y_cord)
	visionCone.polygon = PackedVector2Array([start, top, bot])
