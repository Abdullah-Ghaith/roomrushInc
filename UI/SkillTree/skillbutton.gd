class_name SkillNode extends TextureButton

signal skill_up(upgrade_effect: UpgradeEffect)

@export var skill_id : String
@export var skill_resource : UpgradeEffect

@onready var panel: Panel = $Panel
@onready var label: Label = $Label
@onready var line_2d: Line2D = $Line2D


var lvl : int = 0:
	set(value):
		lvl = value
		label.text = str(lvl) + "/3"

func _ready():
	await get_tree().process_frame

	var parent_node = self.get_parent()
	if parent_node is SkillNode:
		## Draw lines between skill nodes
		var start_pos = line_2d.to_local(global_position + size / 2)
		var end_pos = line_2d.to_local(parent_node.global_position + parent_node.size / 2)

		line_2d.add_point(start_pos)
		line_2d.add_point(end_pos)

		## Disable if not root node by default
		disabled = true

	
	if lvl != 0:
		disabled = false
		panel.show_behind_parent = true
	
		line_2d.default_color = Color(0.78, 0.11, 0.086)

		# Enable children once this one is enabled
		var skill_children = self.get_children()
		for skill in skill_children:
			if skill is SkillNode:
				skill.disabled = false



func _on_pressed() -> void:
	lvl = min (lvl+1 , 3)
	panel.show_behind_parent = true
	line_2d.default_color = Color(0.78, 0.11, 0.086)

	# Enable children once this one is enabled
	var skill_children = self.get_children()
	for skill in skill_children:
		if skill is SkillNode and lvl >= 1:
			skill.disabled = false

	## Send out actual upgrade signal
	skill_up.emit(skill_resource)
