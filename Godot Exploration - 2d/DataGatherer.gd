extends Node
class_name DataGatherer
# class that gathers data
# this consists of both the Scoring Metrics:
#	 amount of team damage vs enemy damage; time spent; total distance traversed; trade-off between metrics
# as well as intermediate State (which can be used for scoring metrics too)
# it's not a listener class, we want it to receive data from other sources

class GameState:
	var state = {};
	func _init():
		print("initializing GameState")
		state = {} # state is dictionary of 'interesting' values
		state["team_damage"] = {"allies": 0, "enemies": 0}  # damage done within team (friendly fire)
		state["damage_done"] = {"allies": 0, "enemies": 0}  # damage done to other team
	
	func state_update():
		print("flushing current game state")
		# TODO need to flush game state after each update
	
	func update_team_damage(team, damage):
		self.state["team_damage"][team] += damage
		state_update()
	
	func update_damage_done(team, damage):
		self.state["damage_done"][team] += damage
		state_update()


var game_state:GameState; # the current game state

# Called when the node enters the scene tree for the first time.
func _ready():
	game_state = GameState.new()
	print(game_state.state)

# TODO connect signal to update (team) damage
