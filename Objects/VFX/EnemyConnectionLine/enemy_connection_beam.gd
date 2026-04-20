class_name ConnectionBeam extends Line2D

@onready var beam_particles_2d: GPUParticles2D = %BeamParticles2D
@onready var base_particles: GPUParticles2D = %BaseParticles
@onready var end_particles: GPUParticles2D = %EndParticles

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func set_beam_between(parent_pos: Vector2, object_pos: Vector2) -> void:
	self.points[0] = parent_pos
	self.points[1] = object_pos
	base_particles.position = parent_pos
	end_particles.position = object_pos




func _process(delta: float) -> void:
	var start = self.points[0]
	var end = self.points[1]
	var dir = end - start
	
	base_particles.rotation = dir.angle()
	end_particles.rotation = -dir.angle()
	end_particles.global_position = to_global(self.points[1])

	var midpoint = (start + end) * 0.5
	beam_particles_2d.position = midpoint
	beam_particles_2d.rotation = dir.angle()
	beam_particles_2d.process_material.emission_box_extents.x = dir.length() * 0.5
