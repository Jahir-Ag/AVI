extends CanvasLayer

const FADE_TIME := 0.25

var _overlay: ColorRect
var _is_changing := false


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	_overlay = ColorRect.new()
	_overlay.color = Color(0, 0, 0, 0)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_overlay)


func change_scene(path: String) -> void:
	if _is_changing:
		return
	_is_changing = true
	_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	await _fade_to(1.0)
	var error := get_tree().change_scene_to_file(path)
	if error == OK:
		await get_tree().scene_changed
	else:
		push_error("Could not change scene to %s: %s" % [path, error_string(error)])
	await _fade_to(0.0)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_is_changing = false


func _fade_to(alpha: float) -> void:
	var tween := create_tween()
	tween.tween_property(_overlay, "color:a", alpha, FADE_TIME)
	await tween.finished
