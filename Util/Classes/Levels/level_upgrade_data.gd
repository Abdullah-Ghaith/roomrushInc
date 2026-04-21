class_name LevelUpgradeData extends Resource

#todo: make the strings only require 1 z1l1

# Human-readable name shown in the panel title
@export var display_name: String = ""

# Must match the level scene's resource_path exactly
# e.g. "res://Scenes/Zone1/Level1/zone_1_level_1.tscn"
@export var scene_path: String = ""

# Unique IDs for each upgrade node — must be globally unique across all levels
@export var timer_skill_id: String = ""       # e.g. "z1l1_timer"
@export var tick_skill_id: String = ""        # e.g. "z1l1_tick"
@export var completion_skill_id: String = ""  # e.g. "z1l1_completion"

# Costs per level for each node [lvl1_cost, lvl2_cost, lvl3_cost]
@export var timer_costs: Array[float] = [15.0, 35.0, 60.0]
@export var tick_costs: Array[float] = [10.0, 25.0, 50.0]
@export var completion_costs: Array[float] = [20.0, 45.0, 80.0]

# Effect tuning
@export var timer_reduction_percent: float = 0.05   # per level
@export var tick_bonus: float = 0.1                 # per level
@export var completion_bonus: float = 0.5           # per level
