extends Node
# UpgradeManager.gd
# Two responsibilities:
#   1. Purchase — validate cost, deduct gold, apply effect, persist.
#   2. Load/replay — on _ready(), reconstruct all stat state from
#      purchased_upgrades in the save file by calling apply() on each effect.
#
# IMPORTANT: This autoload must come AFTER SaveManager in project.godot
# so that the save is already loaded when _ready() runs here.

# skill_id -> UpgradeEffect resource
# Populated by register_effect(), which SkillNodes call on their _ready().
var _effect_registry: Dictionary = {}



func _ready() -> void:
	# Wait one frame so all SkillNodes have had their _ready() and have
	# called register_effect() to populate _effect_registry.
	await get_tree().process_frame
	_replay_upgrades()


# Called by each SkillNode on _ready() so UpgradeManager knows which
# effect resource maps to which skill_id.
func register_effect(skill_id: String, effect: UpgradeEffect) -> void:
	if skill_id == "":
		push_error("UpgradeManager: SkillNode registered with empty skill_id — fix in editor.")
		return
	_effect_registry[skill_id] = effect


# Called by SkillNode._on_pressed() after the cost check passes.
func purchase(skill_id: String, new_level: int, effect: UpgradeEffect) -> void:
	var cost_index = new_level - 1  # costs array is 0-indexed, levels are 1-indexed
	effect.apply(new_level)
	SaveManager.current_save.purchased_upgrades[skill_id] = new_level
	SaveManager.save_game()


# Iterates the save's purchased_upgrades and re-applies every effect
# in level order (level 1 first, up to the saved level) so additive
# effects accumulate correctly.
func _replay_upgrades() -> void:
	var saved: Dictionary = SaveManager.current_save.purchased_upgrades
	for skill_id in saved:
		var saved_level: int = saved[skill_id]
		if not _effect_registry.has(skill_id):
			push_warning("UpgradeManager: skill_id '%s' in save but not in registry. Scene not loaded yet?" % skill_id)
			continue
		var effect: UpgradeEffect = _effect_registry[skill_id]
		for lvl in range(1, saved_level + 1):
			effect.apply(lvl)
		# FIX: was incorrectly referencing purchased_levels — use purchased_upgrades
		SaveManager.current_save.purchased_upgrades[skill_id] = saved_level


func get_purchased_level(skill_id: String) -> int:
	return SaveManager.current_save.purchased_upgrades.get(skill_id, 0)
