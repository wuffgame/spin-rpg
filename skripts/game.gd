extends Node2D

@onready var enemy_hp_bar: ProgressBar = $mosterbar/ProgressBar
@onready var player_hp_bar: ProgressBar = $playerbar/ProgressBar
@onready var gold: Label = $Label

@onready var lvl_sword: Label = $Upgrades/Sword_upg/Label
@onready var lvl_shield: Label = $Upgrades/Shield_upg/Label
@onready var lvl_heart: Label = $Upgrades/Heart_upg/lvl
@onready var lvl_gold: Label = $Upgrades/Coin_upg/Label

@onready var cost_sword: Label = $Upgrades/Sword_upg/HBoxContainer/Label
@onready var cost_shield: Label = $Upgrades/Shield_upg/HBoxContainer/Label
@onready var cost_heart: Label = $Upgrades/Heart_upg/HBoxContainer/cost
@onready var cost_gold: Label = $Upgrades/Coin_upg/HBoxContainer/Label

@onready var hurt_sound: AudioStreamPlayer = $Hurt
@onready var slash_sound: AudioStreamPlayer = $Slash
@onready var death_sound: AudioStreamPlayer = $death

@onready var enemy_name_label: Label = $mosterbar/Label
@onready var player_name_label: Label = $playerbar/Label

@onready var monster_level_label: Label = $mosterbar/Label2

var upgrade_levels = {
	"sword": 0,
	"shield": 0,
	"heart": 0,
	"gold": 0
}

var base_upgrade_cost: int = 30

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

var monster_pool: Array[String] = ["orc", "orc rider", "skieleton"]
var current_monster_name: String = "orc"

func _ready() -> void:
	setup_battle()
	update_upgrade_ui()
	
func setup_battle() -> void:
	current_monster_name = monster_pool[randi() % monster_pool.size()]
	
	monster_max_hp = int(40 + (15 * pow(1.35, monster_index)))
	monster_current_hp = monster_max_hp
	monster_damage = int(8 + (3 * pow(1.3, monster_index)))
	
	enemy_hp_bar.max_value = monster_max_hp
	enemy_hp_bar.value = monster_current_hp
	
	player_hp_bar.max_value = player_max_hp
	player_hp_bar.value = player_current_hp
	monster_level_label.text = "Level " + str(monster_index)
	update_hp_labels()
	
	$monsters/AnimatedSprite2D.play(current_monster_name + "_idle")

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
			heal_player(heal_amount)
			
			await damage_player(monster_final_dmg)
		
		"Wand":
			var ulti_dmg = total_player_dmg * 3
			await damage_monster(ulti_dmg)
			
			if monster_current_hp > 0:
				await damage_player(monster_final_dmg)
				
func damage_monster(amount: int) -> void:
	$monsters/AnimatedSprite2D.play(current_monster_name + "_hurt")
	hurt_sound.play()
	await $monsters/AnimatedSprite2D.animation_finished
	$monsters/AnimatedSprite2D.play(current_monster_name + "_idle")
	monster_current_hp -= amount
	enemy_hp_bar.value = monster_current_hp
	
	var gold_multiplier = 1.0 + (upgrade_levels["gold"] * 0.15)
	player_gold += int((amount * 2) * gold_multiplier)
	gold.text = str(player_gold)
	
	if monster_current_hp <= 0:
		monster_killed()
	update_hp_labels()
func damage_player(amount: int) -> void:
	$monsters/AnimatedSprite2D.play(current_monster_name + "_attack")
	await get_tree().create_timer(0.6).timeout
	slash_sound.play()
	await $monsters/AnimatedSprite2D.animation_finished
	$monsters/AnimatedSprite2D.play(current_monster_name + "_idle")
	player_current_hp -= amount
	player_hp_bar.value = player_current_hp
	
	if player_current_hp <= 0:
		game_over()
	update_hp_labels()	
func heal_player(amount: int) -> void:
	player_current_hp = min(player_max_hp, player_current_hp + amount)
	player_hp_bar.value = player_current_hp
	update_hp_labels()
func monster_killed() -> void:
	$monsters/AnimatedSprite2D.play(current_monster_name + "_death")
	death_sound.play()
	await $monsters/AnimatedSprite2D.animation_finished
	$monsters/AnimatedSprite2D.play(current_monster_name + "_idle")
	
	var gold_multiplier = 1.0 + (upgrade_levels["gold"] * 0.15)
	player_gold += int((monster_index * 35) * gold_multiplier)
	gold.text = str(player_gold)
	monster_index += 1
	
	setup_battle()
	update_hp_labels()
func game_over() -> void:
	monster_index = 1
	player_gold = 0
	gold.text = str(player_gold)
	player_current_hp = player_max_hp
	setup_battle()
	
func get_upgrade_cost(type: String) -> int:
	var lvl = upgrade_levels[type]
	return int(base_upgrade_cost * pow(1.5, lvl))
	
func update_upgrade_ui() -> void:
	lvl_sword.text = "lvl " + str(upgrade_levels["sword"])
	lvl_shield.text = "lvl " + str(upgrade_levels["shield"])
	lvl_heart.text = "lvl " + str(upgrade_levels["heart"])
	lvl_gold.text = "lvl " + str(upgrade_levels["gold"])
	
	cost_sword.text = str(get_upgrade_cost("sword"))
	cost_shield.text = str(get_upgrade_cost("shield"))
	cost_heart.text = str(get_upgrade_cost("heart"))
	cost_gold.text = str(get_upgrade_cost("gold"))
	update_hp_labels()
func buy_upgrade(type: String) -> void:
	var cost = get_upgrade_cost(type)
	
	if player_gold >= cost:
		player_gold -= cost
		gold.text = str(player_gold)
		upgrade_levels[type] += 1
		
		match type:
			"sword":
				player_dmg_upgrade = upgrade_levels["sword"] * 3
			"shield":
				player_defense = upgrade_levels["shield"] * 1
			"heart":
				player_max_hp = 100 + (upgrade_levels["heart"] * 15)
				player_current_hp += 15
				player_hp_bar.max_value = player_max_hp
				player_hp_bar.value = player_current_hp
			"gold":
				pass
		update_upgrade_ui()
		update_hp_labels()
	
	

	
func update_hp_labels() -> void:
	enemy_name_label.text = current_monster_name + " (HP: " + str(monster_current_hp) + "/" + str(monster_max_hp) + ")"
	player_name_label.text = "Player (HP: " + str(player_current_hp) + "/" + str(player_max_hp) + ")"
	
	
	
	
	
	
	


func _on_sword_upg_pressed() -> void:
	buy_upgrade("sword")


func _on_shield_upg_pressed() -> void:
	buy_upgrade("shield")


func _on_heart_upg_pressed() -> void:
	buy_upgrade("heart")


func _on_coin_upg_pressed() -> void:
	buy_upgrade("gold")
