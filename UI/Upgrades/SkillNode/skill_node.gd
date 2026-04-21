class_name SkillNode extends TextureButton

@export var skill_id: String = ""
@export var skill_resource: UpgradeEffect
@export var max_lvl: int = 1
@export var costs: Array[float] = []  # one entry per level, e.g. [10.0, 25.0, 50.0]

@onready var panel: Panel = $Panel
@onready var label: Label = $Label
@onready var line_2d: Line2D = $Line2D

var lvl: int = 0:
	set(value):
		lvl = value
		label.text = str(lvl) + "/" + str(max_lvl)


func _ready() -> void:
	get_viewport().size_changed.connect(_redraw_line)

	# Register this node's effect with UpgradeManager so load/replay works
	if skill_resource and skill_id != "":
		UpgradeManager.register_effect(skill_id, skill_resource)

	# Restore purchased level from save so UI reflects existing progress
	lvl = UpgradeManager.get_purchased_level(skill_id)
	label.text = str(lvl) + "/" + str(max_lvl)

	await get_tree().process_frame

	var parent_node = self.get_parent()
	if parent_node is SkillNode:
		# Draw connecting line to parent
		var start_pos = line_2d.to_local(global_position + size / 2)
		var end_pos = line_2d.to_local(parent_node.global_position + parent_node.size / 2)
		line_2d.add_point(start_pos)
		line_2d.add_point(end_pos)
		# Child nodes start disabled unless parent is already purchased
		disabled = parent_node.lvl < 1

	# If already purchased (loaded from save), show active visual state
	if lvl > 0:
		disabled = false
		panel.show_behind_parent = true
		line_2d.default_color = Color(0.78, 0.11, 0.086)
		_enable_children()


func _on_pressed() -> void:
	# Guard: already maxed
	if lvl >= max_lvl:
		button_pressed = false  # reset toggle since we're using toggle_mode
		return

	# Guard: no cost defined for this level
	if costs.size() < lvl + 1:
		push_error("SkillNode '%s': costs array too short. Expected %d entries." % [skill_id, max_lvl])
		button_pressed = false
		return

	var cost = costs[lvl]  # lvl is current level, so costs[lvl] = cost to reach lvl+1

	# Guard: can't afford
	if CurrencyManager.money < cost:
		button_pressed = false
		_flash_insufficient_funds()
		return

	# Deduct gold
	CurrencyManager.money -= cost

	# Advance level and update visuals
	lvl += 1
	panel.show_behind_parent = true
	line_2d.default_color = Color(0.78, 0.11, 0.086)

	# Unlock children if this is now level 1+
	if lvl >= 1:
		_enable_children()

	# Persist and apply effect via UpgradeManager
	UpgradeManager.purchase(skill_id, lvl, skill_resource)


func _enable_children() -> void:
	for child in get_children():
		if child is SkillNode:
			child.disabled = false


func _flash_insufficient_funds() -> void:
	# Brief red modulate flash to signal can't afford
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1.5, 0.3, 0.3), 0.05)
	tween.tween_property(self, "modulate", Color(1, 1, 1), 0.15)

func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED and is_visible_in_tree():
		_redraw_line()

func _redraw_line() -> void:
	var parent_node = get_parent()
	if not parent_node is SkillNode:
		return
	# Wait for layout to settle before measuring positions
	await get_tree().process_frame
	await get_tree().process_frame
	line_2d.clear_points()
	var start_pos = line_2d.to_local(global_position + size / 2)
	var end_pos = line_2d.to_local(parent_node.global_position + parent_node.size / 2)
	line_2d.add_point(start_pos)
	line_2d.add_point(end_pos)
