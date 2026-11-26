extends CanvasLayer

var show_hitboxes := false
var invincible := false

var _overlay_label: Label


func _ready() -> void:
	if not OS.is_debug_build():
		queue_free()
		return
	layer = 90
	process_mode = Node.PROCESS_MODE_ALWAYS
	_overlay_label = Label.new()
	_overlay_label.position = Vector2(16, 16)
	_overlay_label.add_theme_font_size_override("font_size", 22)
	_overlay_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_overlay_label.add_theme_constant_override("outline_size", 6)
	_overlay_label.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	add_child(_overlay_label)


func _process(_delta: float) -> void:
	if not _overlay_label.visible:
		return
	_overlay_label.text = "FPS %d  |  F1 hitboxes: %s  |  F2 invincible: %s  |  F3 skip phase  |  F4 hide" % [
		Engine.get_frames_per_second(),
		_on_off(show_hitboxes),
		_on_off(invincible),
	]


func _unhandled_key_input(event: InputEvent) -> void:
	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return
	match key_event.physical_keycode:
		KEY_F1:
			_set_hitboxes_visible(not show_hitboxes)
		KEY_F2:
			invincible = not invincible
			Events.debug_invincibility_toggled.emit(invincible)
		KEY_F3:
			Events.debug_skip_phase_requested.emit()
		KEY_F4:
			_overlay_label.visible = not _overlay_label.visible
		_:
			return
	get_viewport().set_input_as_handled()


func _set_hitboxes_visible(enabled: bool) -> void:
	show_hitboxes = enabled
	get_tree().debug_collisions_hint = enabled
	for node in get_tree().root.find_children("*", "CollisionShape2D", true, false):
		(node as CanvasItem).queue_redraw()
	for node in get_tree().root.find_children("*", "CollisionPolygon2D", true, false):
		(node as CanvasItem).queue_redraw()
	Events.debug_hitboxes_toggled.emit(enabled)


func _on_off(value: bool) -> String:
	return "ON" if value else "OFF"
