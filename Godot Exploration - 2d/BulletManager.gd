extends Node2D

func handle_bullet_spawned(bullet : Bullet, position: Vector2, direction: Vector2, team:int):
	if bullet.get_parent() == null:
		add_child(bullet)
	bullet.global_position = position
	bullet.set_direction(direction)
	bullet.set_team(team)
