extends Area2D

signal spin_completed(action_name: String)
var is_spinning: bool = false

var wheel_data = [
	{"name": "Sword", "index": 0, "weight": 50},
	{"name": "Shield", "index": 2, "weight": 30},
	{"name": "Potion", "index": 3, "weight": 15},
	{"name": "Wand", "index": 1, "weight": 5}
]

func get_weighted_random_slot() -> Dictionary:
	var total_weight = 0
	for slot in wheel_data:
		total_weight += slot["weight"]
	var rolled_value = randi() % total_weight
	var currnet_sum = 0
	for slot in wheel_data:
		currnet_sum += slot["weight"]
		if rolled_value < currnet_sum:
			return slot
	return wheel_data[0]

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_released():
			if is_spinning:
				return
			
			is_spinning = true

			var winning_slot = get_weighted_random_slot()
			var random_index = winning_slot["index"]
			print("WYLOSOWANO: ", winning_slot["name"])

			var current_deg = fmod(rotation_degrees, 360.0)
			if current_deg < 0:
				current_deg += 360.0
			
			var current_index = round(current_deg / 90.0)
			if current_index >= 4: current_index = 0
			
			var steps_needed = random_index - current_index
			
			if steps_needed <= 0:
				steps_needed += 4
				
			var rot_full = 3 * 360
			var rotat = rotation_degrees + rot_full + (steps_needed * 90)
			
			var tween = create_tween()
			tween.tween_property(self, "rotation_degrees", rotat, 2.0)\
				.set_trans(Tween.TRANS_QUAD)\
				.set_ease(Tween.EASE_OUT)
				
			tween.tween_callback(func(): 
				is_spinning = false
				spin_completed.emit(winning_slot["name"])
			)
