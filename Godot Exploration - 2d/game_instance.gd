extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$AllyMapDirector.connect("game_over", stop_instance.bind(false))
	$EnemyMapDirector.connect("game_over", stop_instance.bind(true))
	
func stop_instance(allies_won:bool):
	if allies_won:
		$"Game Over/AlliesWon".visible = true
	else:
		$"Game Over/EnemiesWon".visible = true
	# TODO also stop remaining gameplay (or reset behaviour?)
