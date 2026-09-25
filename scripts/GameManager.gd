extends Node

## Qırım Histori - Global Game Manager
## Центральный менеджер игры.

var game_version := "0.1.0"
var world_day := 1
var world_time := 8.0
var game_paused := false


func _ready() -> void:
	print("Qırım Histori started")
	print("Version: ", game_version)


func advance_time(hours: float) -> void:
	world_time += hours

	while world_time >= 24.0:
		world_time -= 24.0
		world_day += 1


func pause_game() -> void:
	game_paused = true


func resume_game() -> void:
	game_paused = false
