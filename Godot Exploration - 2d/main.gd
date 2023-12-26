extends Node2D

const GameOverscreen = preload("res://UI/game_over_screen.tscn")

# TODO fix this structure for multiple game instances
@onready var bullet_manager_1 = $Game_Instance/BulletManager
@onready var ally_map_points_1 = $Game_Instance/AllyMapPoints
@onready var ally_ai_1 = $Game_Instance/AllyMapDirector
@onready var enemy_ai_1 = $Game_Instance/EnemyMapDirector
@onready var pathfinding_1 = $Game_Instance/Pathfinding

@onready var bullet_manager_2 = $Game_Instance2/BulletManager
@onready var ally_map_points_2 = $Game_Instance2/AllyMapPoints
@onready var ally_ai_2 = $Game_Instance2/AllyMapDirector
@onready var enemy_ai_2 = $Game_Instance2/EnemyMapDirector
@onready var pathfinding_2 = $Game_Instance2/Pathfinding

@onready var player: Player = $Player
@onready var gui = $GUI


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	GlobalSignals.bullet_fired.connect(bullet_manager_1.handle_bullet_spawned)
	#GlobalSignals.move_allies.connect(ally_ai.assign_next_position)
	var ally_next_positions_1 = ally_map_points_1.get_positions()
	ally_ai_1.initialize(ally_next_positions_1, pathfinding_1)
	enemy_ai_1.initialize([], pathfinding_1)
	
	var ally_next_positions_2 = ally_map_points_2.get_positions()
	ally_ai_2.initialize(ally_next_positions_2, pathfinding_2)
	enemy_ai_2.initialize([], pathfinding_2)
	gui.set_player(player)

func _process(delta):
	pass
	# TODO replace with game instance level checks?
	#var allies_left = ally_ai.get_child_count()
	#if allies_left == 0:
		#all_allies_died()
		#return
	#var enemies_left = enemy_ai.get_child_count()
	#if enemies_left == 0:
		#all_enemies_died()
		#return

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
