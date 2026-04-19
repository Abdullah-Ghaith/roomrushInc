extends Control
# upgrade_table.gd

@onready var v_scroll_container: ScrollContainer = %VScrollContainer
@onready var entity_list: VBoxContainer = %EnemyList
@onready var category_bar: CategoryBar = %CategoryBar
@onready var tree_container: Control = %TreeContainer

@export var entity_tab_scene: PackedScene
@export var min_panels_on_screen: int = 2

@export var player_offence_tree: PackedScene
@export var player_defence_tree: PackedScene
@export var player_mobility_tree: PackedScene
@export var player_economy_tree: PackedScene

var _tabs: Dictionary = {}           # entity_id -> EntityTab
var _tree_nodes: Dictionary = {}     # entity_id -> tree node (weapons/abilities)
var _player_tree_nodes: Dictionary = {}  # category -> tree node
var _player_tree_scenes: Dictionary = {}

var _current_entity_id: String = ""
var _current_category: String = "offence"


func _ready() -> void:
	_player_tree_scenes = {
		"offence":  player_offence_tree,
		"defence":  player_defence_tree,
		"mobility": player_mobility_tree,
		"economy":  player_economy_tree,
	}

	# Player tab is always first
	_add_tab("player", "player", "Player")

	# Restore any already-unlocked weapons/abilities from save replay
	for weapon_id in PlayerStats.unlocked_weapons:
		_add_tab(weapon_id, "weapon", _display_name(weapon_id))
	for ability_id in PlayerStats.unlocked_abilities:
		_add_tab(ability_id, "ability", _display_name(ability_id))

	SignalBus.entity_unlocked.connect(_on_entity_unlocked)
	category_bar.category_selected.connect(_on_category_selected)

	_select_entity("player")


func _input(event: InputEvent) -> void:
	if entity_list.get_child_count() == 0:
		return
	if event.is_action_pressed("ui_down"):
		_select_by_index(_current_tab_index() + 1)
	if event.is_action_pressed("ui_up"):
		_select_by_index(_current_tab_index() - 1)
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_select_by_index(_current_tab_index() + 1)
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_select_by_index(_current_tab_index() - 1)


# ---------------------------------------------------------------
# Tab management
# ---------------------------------------------------------------

func _add_tab(entity_id: String, entity_type: String, display_name: String) -> void:
	if _tabs.has(entity_id):
		return
	var tab: EntityTab = entity_tab_scene.instantiate()
	entity_list.add_child(tab)
	tab.setup(entity_id, entity_type, display_name)
	tab.gui_input.connect(_on_tab_gui_input.bind(entity_id))
	_tabs[entity_id] = tab


func _on_entity_unlocked(entity_id: String, entity_type: String) -> void:
	_add_tab(entity_id, entity_type, _display_name(entity_id))


func _on_tab_gui_input(event: InputEvent, entity_id: String) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_select_entity(entity_id)


# ---------------------------------------------------------------
# Entity selection — swaps right panel content
# ---------------------------------------------------------------

func _select_entity(entity_id: String) -> void:
	_current_entity_id = entity_id

	for id in _tabs:
		_tabs[id].set_active(id == entity_id)

	category_bar.visible = (entity_id == "player")

	for child in tree_container.get_children():
		child.hide()

	if entity_id == "player":
		_show_player_category(_current_category)
	else:
		_show_entity_tree(entity_id)

	_scroll_to_tab(entity_id)


func _show_player_category(category: String) -> void:
	_current_category = category

	if not _player_tree_nodes.has(category):
		var packed: PackedScene = _player_tree_scenes.get(category)
		if packed == null:
			push_warning("upgrade_table: no scene assigned for player category '%s'" % category)
			return
		var node = packed.instantiate()
		tree_container.add_child(node)
		_player_tree_nodes[category] = node

	for cat in _player_tree_nodes:
		_player_tree_nodes[cat].visible = (cat == category)


func _show_entity_tree(entity_id: String) -> void:
	if not _tree_nodes.has(entity_id):
		for child in tree_container.get_children():
			if child.has_meta("entity_id") and child.get_meta("entity_id") == entity_id:
				_tree_nodes[entity_id] = child
				break
		if not _tree_nodes.has(entity_id):
			push_warning("upgrade_table: no tree found for entity '%s'" % entity_id)
			return
	_tree_nodes[entity_id].show()


func _on_category_selected(category: String) -> void:
	if _current_entity_id == "player":
		_show_player_category(category)


# ---------------------------------------------------------------
# Scroll (preserved exactly from UpgradeTable2.0)
# ---------------------------------------------------------------

func _select_by_index(index: int) -> void:
	var tabs = entity_list.get_children()
	index = clamp(index, 0, tabs.size() - 1)
	_select_entity(tabs[index].entity_id)


func _current_tab_index() -> int:
	var tabs = entity_list.get_children()
	for i in range(tabs.size()):
		if tabs[i].entity_id == _current_entity_id:
			return i
	return 0


func _scroll_to_tab(entity_id: String) -> void:
	var tabs = entity_list.get_children()
	var index := 0
	for i in range(tabs.size()):
		if tabs[i].entity_id == entity_id:
			index = i
			break
	if index >= tabs.size() - min_panels_on_screen:
		return
	await get_tree().process_frame
	var target: EntityTab = tabs[index]
	var target_center = target.position.y + target.size.y * 0.3
	var container_center = v_scroll_container.size.y * 0.5
	var tween = create_tween()
	tween.tween_property(v_scroll_container, "scroll_vertical", target_center - container_center, 0.2)


func _display_name(entity_id: String) -> String:
	return entity_id.replace("_", " ").capitalize()
