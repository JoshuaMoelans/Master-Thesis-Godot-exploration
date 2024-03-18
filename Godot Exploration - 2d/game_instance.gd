extends Node2D
class_name GameInstance

var update_time = 0

@export var verbose = false
@export var id = 0
var game_state:GameState; # the current game state
@onready var AllyMapDirector = $AllyMapDirector
@onready var EnemyMapDirector = $EnemyMapDirector


# Called when the node enters the scene tree for the first time.
func _ready():
	game_state = GameState.new()
	game_state.game_instance_name = name # used for flushing to file
	AllyMapDirector.connect("game_over", stop_instance.bind(false))
	EnemyMapDirector.connect("game_over", stop_instance.bind(true))
	for unit:Actor in AllyMapDirector.get_children():
		unit.connect("actor_hit_by", game_state.update_dmg)
		unit.ai.connect("flush_AI_state_sgn", game_state.update_ally_state)
		game_state.add_ally(unit.ai.get_AI_state())
	for unit:Actor in EnemyMapDirector.get_children():
		unit.connect("actor_hit_by", game_state.update_dmg)
		unit.ai.connect("flush_AI_state_sgn", game_state.update_enemy_state)
		game_state.add_enemy(unit.ai.get_AI_state())

func set_flush_state(on):
	game_state.flush = on

func stop_instance(allies_won:bool):
	print("game over in instance: ", name)
	if allies_won:
		$"Game Over/AlliesWon".visible = true
	else:
		$"Game Over/EnemiesWon".visible = true
	# TODO also stop remaining gameplay (or reset behaviour?)

func _process(delta):
	game_state.update_time += delta

# constructs named dict of id:node for given list of child nodes
func construct_name_dict(child_list):
	var out = {}
	for c:Node in child_list:
		out[c.name] = c
	return out

func load_game_state(newstate):
	print("loading game state")
	# UPDATING ALLIES
	var allyData = newstate["allies"]
	var allies = AllyMapDirector.get_children()
	var allies_map:Dictionary = construct_name_dict(allies)
	for ally_update in allyData:
		var ally_id = allyData[ally_update]["id"]
		if ally_id in allies_map: # checks if ally from load exists
			var ally:Actor = allies_map[ally_id]
			ally.set_state(allyData[ally_update])
	# UPDATING ENEMIES
	var enemyData = newstate["enemies"]
	var enemies = EnemyMapDirector.get_children()
	var enemies_map:Dictionary = construct_name_dict(enemies)
	for enemy_update in enemyData:
		var enemy_id = enemyData[enemy_update]["id"]
		if enemy_id in enemies_map:
			var enemy:Actor = enemies_map[enemy_id]
			enemy.set_state(enemyData[enemy_update])
	# WRITING LOADED STATE AS CHECK
	game_state.state_update(true, "postload")
	
	

# class that gathers data
# this consists of both the Scoring Metrics:
#	 amount of team damage vs enemy damage; time spent; total distance traversed; trade-off between metrics
# as well as intermediate State (which can be used for scoring metrics too)
# it's not a listener class, we want it to receive data from other sources
class GameState:
	var flush = false # whether to attempt to flush the game state
	var update_time = 0
	var state = {};
	var teams = ["allies", "enemies"]
	var game_instance_name = ""
	func _init():
		state = {} # state is dictionary of 'interesting' values
		state["team_damage"] = {"allies": 0, "enemies": 0}  # damage done within team (friendly fire)
		state["damage_done"] = {"allies": 0, "enemies": 0}  # damage done to other team
		state["allies"] = {}
		state["enemies"] = {}
	
	func add_ally(ally_state):
		self.state["allies"][ally_state.id] = ally_state
	
	func add_enemy(enemy_state):
		self.state["enemies"][enemy_state.id] = enemy_state
	
	signal state_flush(filename, data)
	
	func state_update(force=false, suffix=""):
		if force or flush:
			self.state["timer"] = update_time
			var filename = game_instance_name + "_" + str(update_time) + suffix
			state_flush.emit(filename, JSON.stringify(state)) # emit state flush signal TODO every update or only every X?
		
	func update_team_damage(team, damage):
		self.state["team_damage"][team] += damage
		state_update()
	
	func update_damage_done(team, damage):
		self.state["damage_done"][team] += damage
		state_update()
	
	func update_dmg(to_team, from_team, damage):
		if from_team == to_team: # friendly fire
			update_team_damage(teams[from_team], damage)
		else: # regular damage
			update_damage_done(teams[from_team], damage)
	
	func update_ally_state(ally_name, newstate):
		self.state["allies"][ally_name] = newstate
		state_update()
		
	func update_enemy_state(enemy_name, newstate):
		self.state["enemies"][enemy_name] = newstate
		state_update()
