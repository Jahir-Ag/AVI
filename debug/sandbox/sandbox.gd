extends Control

@onready var _gamepad_label: Label = %GamepadLabel
@onready var _actions_label: Label = %ActionsLabel
@onready var _english_button: Button = %EnglishButton
@onready var _spanish_button: Button = %SpanishButton
@onready var _fullscreen_check: CheckButton = %FullscreenCheck


func _ready() -> void:
	_english_button.pressed.connect(Settings.set_locale.bind("en"))
	_spanish_button.pressed.connect(Settings.set_locale.bind("es"))
	_fullscreen_check.button_pressed = Settings.fullscreen
	_fullscreen_check.toggled.connect(Settings.set_fullscreen)
	Settings.locale_changed.connect(_on_locale_changed.unbind(1))
	_on_locale_changed()


func _process(_delta: float) -> void:
	_gamepad_label.text = _get_gamepad_text()
	_actions_label.text = tr("SANDBOX_ACTIONS") % _get_active_actions_text()


func _on_locale_changed() -> void:
	_english_button.disabled = Settings.locale == "en"
	_spanish_button.disabled = Settings.locale == "es"


func _get_gamepad_text() -> String:
	var joypads := Input.get_connected_joypads()
	if joypads.is_empty():
		return tr("SANDBOX_GAMEPAD_NONE")
	return tr("SANDBOX_GAMEPAD_CONNECTED") % Input.get_joy_name(joypads[0])


func _get_active_actions_text() -> String:
	var active: PackedStringArray = []
	for action in InputDefaults.get_actions():
		if Input.is_action_pressed(action):
			active.append(action)
	return ", ".join(active) if not active.is_empty() else tr("SANDBOX_ACTIONS_NONE")
