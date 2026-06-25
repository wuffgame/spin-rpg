extends Control

@onready var level = Level.level
@onready var lvl: Label = $LVL

func _ready() -> void:
	lvl.text = "YOU BEAT " + str(level - 1) + " LEVELS"
	Level.lock = false

func _on_try_again_pressed() -> void:\
	get_tree().change_scene_to_file("res://scenes/TEST.tscn")
