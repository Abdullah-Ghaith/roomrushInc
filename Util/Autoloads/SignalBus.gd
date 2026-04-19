extends Node

signal money_collected(amount: float)
signal money_spent(amount: float)

signal level_completed(scene_path: String, completion_time: float)
signal level_period_elapsed(scene_path: String)

signal shake_camera(x_shake : float, y_shake : float)

# entity_type is "weapon" or "ability"
# Listened to by the upgrade table to dynamically add tabs.
signal entity_unlocked(entity_id: String, entity_type: String)
