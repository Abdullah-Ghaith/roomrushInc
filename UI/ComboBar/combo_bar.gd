extends Control

@export var max_combo_bar_time_s: float = 5.0

@onready var decay_timer: Timer = %DecayTimer
@onready var number: RichTextLabel = %Number
@onready var combo_progress_bar: TextureProgressBar = %ComboProgressBar

const MAX_PROGRESS:       float = 100.0

var combo_bar_min:        int   = 1
var combo_bar_max:        int   = 5         
var combo_bar_lvl:        int   = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	decay_timer.wait_time = max_combo_bar_time_s
	#SignalBus.player_attempt.connect(_handle_player_attempt)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Only update the combo bar meter decay when combo > 1
	var TIME_TO_COMBO_RATIO:  float = combo_progress_bar.max_value/max_combo_bar_time_s
	if combo_bar_lvl > 1:
		combo_progress_bar.set_value_no_signal(decay_timer.time_left*TIME_TO_COMBO_RATIO)
	pass

func _reset_combo_bar() -> void:
	combo_bar_lvl = 1
	#num_sprite.texture = load("res://Assets/Sprites/ComboBar/1.png")
	decay_timer.start()
	combo_progress_bar.set_value_no_signal(combo_progress_bar.max_value)

func increment_combo() -> void:
	decay_timer.start()
	combo_bar_lvl = clamp(combo_bar_lvl + 1, combo_bar_min, combo_bar_max)
	update_count_label()

func update_count_label() -> void:
	number.text = "[font=Assets/Fonts/zig.ttf][font_size=20][wave][outline_color=4768cf][outline_size=15][wave amp=5][wave freq=1][matrix qrclean=2.0 dirty=0.4 span=24]%d![/matrix]" % combo_bar_lvl


func _on_decay_timer_timeout() -> void:
	_reset_combo_bar()
