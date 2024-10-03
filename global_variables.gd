extends Node

# Constants
var curse_words: Array = ["fear", "tear", "taste", "ward", "drag", "axed", "east", "dread", "dwarf","scarf", "feast", "swear"]

var dir_to_v = {"left" : Vector2(-1, 0),
				"right": Vector2(1, 0),
				"down" : Vector2(0, 1),
				"up"   : Vector2(0, -1)}

# Game Information
var level_information = {1: {"path": "res://levels/level_1.tscn",
							 "best_enemies_escaped": 0,
							 "best_completion_time": null,
							 "escapes_allowed": 2},
						 2: {"path": "res://levels/level_2.tscn",
							 "best_enemies_escaped": 0,
							 "best_completion_time": null,
							 "escapes_allowed": 1},
						3: {"path": "res://levels/level_3.tscn",
							 "best_enemies_escaped": 0,
							 "best_completion_time": null,
							 "escapes_allowed": 1},
						4: {"path": "res://levels/level_4.tscn",
							 "best_enemies_escaped": 0,
							 "best_completion_time": null,
							 "escapes_allowed": 0},
						5: {"path": "res://levels/level_5.tscn",
							 "best_enemies_escaped": 0,
							 "best_completion_time": null,
							 "escapes_allowed": 0},}
							
