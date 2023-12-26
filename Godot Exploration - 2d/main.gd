extends Node2D

const GameOverscreen = preload("res://UI/game_over_screen.tscn")

@onready var bullet_manager = $BulletManager
@onready var player: Player = $Player
@onready var ally_map_points = $AllyMapPoints
@onready var ally_ai = $AllyMapDirector
@onready var enemy_ai = $EnemyMapDirector
@onready var gui = $GUI
@onready var ground = $Ground
@onready var pathfinding = $Pathfinding
# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	GlobalSignals.bullet_fired.connect(bullet_manager.handle_bullet_spawned)
	GlobalSignals.move_allies.connect(ally_ai.assign_next_position)
	var ally_next_positions = ally_map_points.get_positions()
	ally_ai.initialize(ally_next_positions, pathfinding)
	enemy_ai.initialize([], pathfinding)
	gui.set_player(player)

func _process(delta):
	# TODO check performance, maybe only call recounting when ally/enemy dies?
	var allies_left = ally_ai.get_child_count()
	if allies_left == 0:
		all_allies_died()
		return
	var enemies_left = enemy_ai.get_child_count()
	if enemies_left == 0:
		all_enemies_died()
		return

func all_allies_died():
	var game_over = GameOverscreen.instantiate()
	add_child(game_over)
	get_tree().paused = true
	game_over.set_title(false)
	
func all_enemies_died():
	var game_over = GameOverscreen.instantiate()
	add_child(game_over)
	game_over.set_title(true)
	get_tree().paused = true
