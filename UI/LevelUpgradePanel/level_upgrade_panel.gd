class_name LevelUpgradePanel extends PopupPanel
# Generic per-level upgrade popup.
# Call open_for_level(scene_path) to populate and show it.
# The SkillNodes inside are pre-authored in the scene with their
# scene_path exports left blank — this script fills them at runtime.

@onready var timer_node: SkillNode = %TimerSkillNode
@onready var tick_node: SkillNode = %TickSkillNode
@onready var completion_node: SkillNode = %CompletionSkillNode
@onready var title_label: Label = %TitleLabel

var _scene_path: String = ""


func open_for_level(scene_path: String, display_name: String) -> void:
	_scene_path = scene_path
	title_label.text = display_name

	# Inject the scene_path into each effect resource at runtime.
	# The SkillNode's skill_resource is a LevelTimerReductionEffect /
	# LevelPayoutBonusEffect — we set scene_path on it before it registers.
	_inject_scene_path(timer_node)
	_inject_scene_path(tick_node)
	_inject_scene_path(completion_node)

	popup_centered()


func _inject_scene_path(node: SkillNode) -> void:
	if node.skill_resource and ("scene_path" in node.skill_resource):
		# Effect resources are plain Resources — set scene_path directly
		node.skill_resource.scene_path = _scene_path
