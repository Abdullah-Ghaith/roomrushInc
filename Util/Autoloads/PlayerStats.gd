extends Node
# PlayerStats.gd
# Central store for all player stats.
# UpgradeEffect subclasses write into here via apply().

# --- Movement ---
var speed: float = 300.0
var jump_force: float = 600.0

# --- Combat ---
var max_health: float = 100.0
var damage_multiplier: float = 1.0

# --- Ability stats (numeric) ---
var dash_speed: float = 600.0
var dash_duration: float = 0.2
var dash_cooldown: float = 1.0
var double_jump_count: int = 1      # extra jumps above the base jump

# --- Ability flags (unlocked by AbilityUnlockEffect) ---
var dash_enabled: bool = true
var double_jump_enabled: bool = true
var wall_jump_enabled: bool = true
var fast_fall_enabled: bool = true
var reflector_enabled: bool = true
var vampirism_enabled: bool = false

# --- Unlock tracking (read by the upgrade table to build tabs) ---
var unlocked_abilities: Array[String] = []
var unlocked_weapons: Array[String] = ["basic_gun"]
