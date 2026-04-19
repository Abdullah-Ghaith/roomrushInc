class_name UpgradeEffect extends Resource

# Base class. Override apply() in every subclass.
# apply() is called once per level purchased, and once per level
# during load replay — so it must be purely additive/idempotent
# relative to a single level increment.
func apply(_level: int) -> void:
	pass
