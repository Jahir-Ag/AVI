class_name InputDefaults
extends RefCounted

const JOY_DEADZONE := 0.25

const BINDINGS := {
	&"move_left": {
		"keys": [KEY_A],
		"buttons": [JOY_BUTTON_DPAD_LEFT],
		"axes": [[JOY_AXIS_LEFT_X, -1.0]],
	},
	&"move_right": {
		"keys": [KEY_D],
		"buttons": [JOY_BUTTON_DPAD_RIGHT],
		"axes": [[JOY_AXIS_LEFT_X, 1.0]],
	},
	&"look_up": {
		"keys": [KEY_W],
		"buttons": [JOY_BUTTON_DPAD_UP],
		"axes": [[JOY_AXIS_LEFT_Y, -1.0]],
	},
	&"look_down": {
		"keys": [KEY_S],
		"buttons": [JOY_BUTTON_DPAD_DOWN],
		"axes": [[JOY_AXIS_LEFT_Y, 1.0]],
	},
	&"jump": {
		"keys": [KEY_SPACE],
		"buttons": [JOY_BUTTON_A],
		"axes": [],
	},
	&"dodge": {
		"keys": [KEY_SHIFT],
		"buttons": [JOY_BUTTON_B],
		"axes": [],
	},
	&"dash": {
		"keys": [KEY_N],
		"buttons": [],
		"axes": [[JOY_AXIS_TRIGGER_RIGHT, 1.0]],
	},
	&"attack_short": {
		"keys": [KEY_K],
		"buttons": [JOY_BUTTON_X],
		"axes": [],
	},
	&"attack_medium": {
		"keys": [KEY_L],
		"buttons": [JOY_BUTTON_Y],
		"axes": [],
	},
	&"attack_long": {
		"keys": [KEY_I],
		"buttons": [JOY_BUTTON_RIGHT_SHOULDER],
		"axes": [],
	},
	&"pause": {
		"keys": [KEY_ESCAPE],
		"buttons": [JOY_BUTTON_START],
		"axes": [],
	},
}


static func apply() -> void:
	for action: StringName in BINDINGS:
		if InputMap.has_action(action):
			InputMap.erase_action(action)
		InputMap.add_action(action, JOY_DEADZONE)
		var binding: Dictionary = BINDINGS[action]
		for keycode: Key in binding["keys"]:
			var key_event := InputEventKey.new()
			key_event.physical_keycode = keycode
			InputMap.action_add_event(action, key_event)
		for button: JoyButton in binding["buttons"]:
			var button_event := InputEventJoypadButton.new()
			button_event.button_index = button
			InputMap.action_add_event(action, button_event)
		for axis_binding: Array in binding["axes"]:
			var motion_event := InputEventJoypadMotion.new()
			motion_event.axis = axis_binding[0]
			motion_event.axis_value = axis_binding[1]
			InputMap.action_add_event(action, motion_event)


static func get_actions() -> Array[StringName]:
	var actions: Array[StringName] = []
	actions.assign(BINDINGS.keys())
	return actions
