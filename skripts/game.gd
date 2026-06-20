extends Node2D

@onready var enemy_hp_bar: ProgressBar = $mosterbar/ProgressBar
@onready var player_hp_bar: ProgressBar = $playerbar/ProgressBar
@onready var gold: Label = $Label

var player_max_hp: int = 100
var player_current_hp: int = 100
var player_base_damage: int = 15
var player_dmg_upgrade: int = 0
var player_defense: int = 0
var player_gold: int =0

var monster_index: int = 1
var monster_max_hp: int = 50
var monster_current_hp: int = 50
var monster_damage: int = 12

func _ready() -> void:
	setup_battle()
	
func setup_battle() -> void:
	monster_max_hp = 40 + (monster_index * 20)
	monster_current_hp = monster_max_hp
	monster_damage = 8 + (monster_index * 4)
	
	enemy_hp_bar.max_value = monster_max_hp
	enemy_hp_bar.value = monster_current_hp
	
	player_hp_bar.max_value = player_max_hp
	player_hp_bar.value = player_current_hp

func _on_wheel_spin_completed(action_name: String) -> void:
	var total_player_dmg = player_base_damage + player_dmg_upgrade
	var monster_final_dmg = max(1, monster_damage - player_defense)
	
	match action_name:
		"Sword":
			await damage_monster(total_player_dmg)
			
			if monster_current_hp > 0:
				await damage_player(monster_final_dmg)
		
		"Shield":
			pass
		
		"Potion":
			var heal_amount = 15 + (player_dmg_upgrade * 0.5)
			await heal_player(heal_amount)
			
			await damage_player(monster_final_dmg)
		
		"Wand":
			var ulti_dmg = total_player_dmg * 3
			await damage_monster(ulti_dmg)
			
			if monster_current_hp > 0:
				await damage_player(monster_final_dmg)
				
func damage_monster(amount: int) -> void:
	$monsters/AnimatedSprite2D.play("orc hurt")
	await $monsters/AnimatedSprite2D.animation_finished
	$monsters/AnimatedSprite2D.play("orc idle")
	monster_current_hp -= amount
	enemy_hp_bar.value = monster_current_hp
	
	player_gold += amount *2
	gold.text = str(player_gold)
	
	if monster_current_hp <= 0:
		monster_killed()
		
func damage_player(amount: int) -> void:
	$monsters/AnimatedSprite2D.play("orc attack")
	await $monsters/AnimatedSprite2D.animation_finished
	$monsters/AnimatedSprite2D.play("orc idle")
	player_current_hp -= amount
	player_hp_bar.value = player_current_hp
	
	if player_current_hp <= 0:
		game_over()
		
func heal_player(amount: int) -> void:
	player_current_hp = min(player_max_hp, player_current_hp + amount)
	player_hp_bar.value = player_current_hp
	
func monster_killed() -> void:
	$monsters/AnimatedSprite2D.play("orc death")
	await $monsters/AnimatedSprite2D.animation_finished
	$monsters/AnimatedSprite2D.play("orc idle")
	player_gold += monster_index * 50
	gold.text = str(player_gold)
	monster_index += 1
	
	setup_battle()
	
func game_over() -> void:
	monster_index = 1
	player_gold = 0
	gold.text = str(player_gold)
	player_current_hp = player_max_hp
	setup_battle()

	
	
	
	
	
	
	
	
	
	
	
