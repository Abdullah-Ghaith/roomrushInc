extends RichTextLabel

@onready var animation_player: AnimationPlayer = $AnimationPlayer


var elapsed_time: float = 0.0
var running: bool = false

func _ready() -> void:
	running = true
	SignalBus.level_clear.connect(_on_level_clear)

func _process(delta: float) -> void:
	if not running:
		return
	elapsed_time += delta
	_update_stopwatch_label()

func _update_stopwatch_label() -> void:
	var minutes: int = int(elapsed_time) / 60
	var seconds: int = int(elapsed_time) % 60
	var milliseconds: int = int(fmod(elapsed_time, 1.0) * 100)
	var bbcode = "[font=Assets/Fonts/zig.ttf][center][outline_color=4768cf][outline_size=15][font_size=24]%02d:%02d[color=#aaaaaa].%02d[/color][/font_size]" % [minutes, seconds, milliseconds]
	parse_bbcode(bbcode)

func _on_level_clear() -> void:
	running = false
	animation_player.play("buh_blink", -1, 0.5)
