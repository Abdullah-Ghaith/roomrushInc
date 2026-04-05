@tool
class_name BackGlow extends Sprite2D

@export var glow_color: Color = Color.WHITE:
	set(value):
		glow_color = value
		if material:
			material.set_shader_parameter("glow_color", glow_color)

@export var glow_radius: float = 0.4:
	set(value):
		glow_radius = value
		if material:
			material.set_shader_parameter("radius", glow_radius)
