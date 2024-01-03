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

@onready var bullet_manager_3 = $Game_Instance3/BulletManager
@onready var ally_map_points_3 = $Game_Instance3/AllyMapPoints
@onready var ally_ai_3 = $Game_Instance3/AllyMapDirector
@onready var enemy_ai_3 = $Game_Instance3/EnemyMapDirector
@onready var pathfinding_3 = $Game_Instance3/Pathfinding

@onready var bullet_manager_4 = $Game_Instance4/BulletManager
@onready var ally_map_points_4 = $Game_Instance4/AllyMapPoints
@onready var ally_ai_4 = $Game_Instance4/AllyMapDirector
@onready var enemy_ai_4 = $Game_Instance4/EnemyMapDirector
@onready var pathfinding_4 = $Game_Instance4/Pathfinding

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
	
	var ally_next_positions_3 = ally_map_points_3.get_positions()
	ally_ai_3.initialize(ally_next_positions_3, pathfinding_3)
	enemy_ai_3.initialize([], pathfinding_3)
	
	var ally_next_positions_4 = ally_map_points_4.get_positions()
	ally_ai_4.initialize(ally_next_positions_4, pathfinding_4)
	enemy_ai_4.initialize([], pathfinding_4)
	
	gui.set_player(player)
