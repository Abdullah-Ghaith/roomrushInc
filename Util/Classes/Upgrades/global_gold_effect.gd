class_name GlobalGoldMultiplierEffect extends UpgradeEffect

# Adds a flat multiplier bonus to CurrencyManager's global tick multiplier
# each level. The multiplier starts at 1.0 and this stacks additively.
# Example: bonus_per_level = 0.1 → at level 3, ticks pay out at 1.3x base.

@export var bonus_per_level: float = 0.1

func apply(_level: int) -> void:
	CurrencyManager.tick_multiplier += bonus_per_level
