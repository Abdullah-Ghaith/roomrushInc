class_name LevelUpgradePanel extends PopupPanel
# Single shared panel for all level upgrades.
# Call open_for_level(data) with a LevelUpgradeData resource.
# Dynamically builds/reconfigures three SkillNodes each time.

@onready var title_label: Label = %TitleLabel
@onready var timer_container: VBoxContainer = %TimerContainer
@onready var tick_container: VBoxContainer = %TickContainer
@onready var completion_container: VBoxContainer = %CompletionContainer

# Currently displayed data — tracked so we can clean up on next open
var _current_data: LevelUpgradeData = null
var _nodes: Dictionary = {}  # skill_id -> SkillNode

const SKILL_NODE_SCENE = preload("res://UI/Upgrades/SkillNode/skill_node.tscn")

func open_for_level(data: LevelUpgradeData) -> void:
	print("open for level entered")
	if data == null:
		return
	print("open for level data not null")
	title_label.text = data.display_name

	# Build or reconfigure each of the three upgrade nodes
	_setup_node(
		timer_container,
		data.timer_skill_id,
		data.timer_costs,
		data.timer_costs.size(),
		_make_timer_effect(data)
	)
	_setup_node(
		tick_container,
		data.tick_skill_id,
		data.tick_costs,
		data.tick_costs.size(),
		_make_tick_effect(data)
	)
	_setup_node(
		completion_container,
		data.completion_skill_id,
		data.completion_costs,
		data.completion_costs.size(),
		_make_completion_effect(data)
	)

	_current_data = data
	popup_centered()


func _setup_node(
		container: VBoxContainer,
		skill_id: String,
		costs: Array[float],
		max_lvl: int,
		effect: UpgradeEffect
) -> void:
	# Remove any existing SkillNode in this container (switching levels)
	for child in container.get_children():
		if child is SkillNode:
			child.queue_free()
			break

	var node: SkillNode = SKILL_NODE_SCENE.instantiate()

	node.skill_id = skill_id
	node.costs = costs
	node.max_lvl = max_lvl
	node.skill_resource = effect

	container.add_child(node)

	_nodes[skill_id] = node


func _make_timer_effect(data: LevelUpgradeData) -> LevelTimerReductionEffect:
	print("making timer effect node")
	var e := LevelTimerReductionEffect.new()
	e.scene_path = data.scene_path
	e.reduction_percent_per_level = data.timer_reduction_percent
	return e


func _make_tick_effect(data: LevelUpgradeData) -> LevelPayoutBonusEffect:
	print("making tick effect node")
	var e := LevelPayoutBonusEffect.new()
	print("made")
	e.scene_path = data.scene_path
	e.tick_bonus_per_level = data.tick_bonus
	e.completion_bonus_per_level = 0.0
	return e


func _make_completion_effect(data: LevelUpgradeData) -> LevelPayoutBonusEffect:
	var e := LevelPayoutBonusEffect.new()
	e.scene_path = data.scene_path
	e.tick_bonus_per_level = 0.0
	e.completion_bonus_per_level = data.completion_bonus
	return e
