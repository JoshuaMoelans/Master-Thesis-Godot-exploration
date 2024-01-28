extends Node2D

const GameOverscreen = preload("res://UI/game_over_screen.tscn")
var Game_Instance_Scene = preload("res://game_instance.tscn")
@export var instance_num = 1;

@onready var player: Player = $Player
@onready var gui = $GUI


# Called when the node enters the scene tree for the first time.
# using deferred setup due to navigationserver error
# see https://github.com/godotengine/godot/issues/84677
func _ready():
	set_physics_process(false)
	setup()
	
func setup():
	randomize()
	await get_tree().physics_frame
	set_physics_process(true)
	var grid_dim:int = ceil(sqrt(instance_num))
	for i in range(instance_num):
		print("instancing game: ", i)
		# instance a Game_Instance from the Game_Instance scene
		var new_game_instance = Game_Instance_Scene.instantiate()
		add_child(new_game_instance)
		# set Game_Instance position on grid;
		var bounds = new_game_instance.get_node("Bounds")
		var area = bounds.get_node("area")
		var size = area.get_shape().get_rect().size
		var x = (i%grid_dim)*(size.x + 350)
		var y = (floor(i/grid_dim))*(size.y + 350)
		new_game_instance.position = Vector2(x, y)
		# get all (previously onready) vars needed for instance setup
		var bullet_mgr = new_game_instance.get_node("BulletManager")
		var ally_map_pts = new_game_instance.get_node("AllyMapPoints")
		var ally_ai = new_game_instance.get_node("AllyMapDirector")
		var enemy_ai = new_game_instance.get_node("EnemyMapDirector")
		var pathfinding = new_game_instance.get_node("Pathfinding")
		# connect Global Signal bullet fired
		GlobalSignals.bullet_fired.connect(bullet_mgr.handle_bullet_spawned)
		# initialize ally and enemy ai for instance
		var ally_next_positions = ally_map_pts.get_positions()
		ally_ai.initialize(ally_next_positions, pathfinding)
		enemy_ai.initialize([], pathfinding)
	
	gui.set_player(player)
	#get_node("Game_Instance").queue_free()  # remove first instance for debugging
