extends Node2D
# Small floating number that drifts up and fades, then frees itself.
# Reused for damage dealt (white) and XP pickups (green "+N").

var amount: int = 0
var color: Color = Color(1, 1, 1)
var prefix: String = ""

func _ready() -> void:
	var label: Label = $Label
	label.text = "%s%d" % [prefix, amount]
	label.modulate = color
	var t := create_tween()
	t.set_parallel(true)
	t.tween_property(self, "position", position + Vector2(0, -18), 0.6).set_ease(Tween.EASE_OUT)
	t.tween_property(label, "modulate:a", 0.0, 0.6).set_ease(Tween.EASE_IN)
	t.set_parallel(false)
	t.tween_callback(queue_free)
