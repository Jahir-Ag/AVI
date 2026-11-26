extends Node

signal locale_changed(locale: String)

const SETTINGS_PATH := "user://settings.cfg"
const SUPPORTED_LOCALES: PackedStringArray = ["en", "es"]
const FALLBACK_LOCALE := "en"
const VOLUME_BUSES: PackedStringArray = ["Master", "Music", "SFX", "Voice"]
const DEFAULT_VOLUME := 0.8

var locale: String = FALLBACK_LOCALE
var fullscreen: bool = false
var volumes: Dictionary[String, float] = {}


func _ready() -> void:
	InputDefaults.apply()
	_load()
	_apply_locale()
	_apply_window_mode()
	for bus_name in VOLUME_BUSES:
		_apply_volume(bus_name)


func set_locale(value: String) -> void:
	if value not in SUPPORTED_LOCALES or value == locale:
		return
	locale = value
	_apply_locale()
	save()
	locale_changed.emit(locale)


func set_fullscreen(value: bool) -> void:
	fullscreen = value
	_apply_window_mode()
	save()


func set_volume(bus_name: String, linear: float) -> void:
	if bus_name not in VOLUME_BUSES:
		return
	volumes[bus_name] = clampf(linear, 0.0, 1.0)
	_apply_volume(bus_name)
	save()


func get_volume(bus_name: String) -> float:
	return volumes.get(bus_name, DEFAULT_VOLUME)


func save() -> void:
	var config := ConfigFile.new()
	config.set_value("general", "locale", locale)
	config.set_value("display", "fullscreen", fullscreen)
	for bus_name in VOLUME_BUSES:
		config.set_value("audio", bus_name, get_volume(bus_name))
	var error := config.save(SETTINGS_PATH)
	if error != OK:
		push_error("Could not save settings: %s" % error_string(error))


func _load() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		locale = _detect_system_locale()
		return
	locale = config.get_value("general", "locale", _detect_system_locale())
	if locale not in SUPPORTED_LOCALES:
		locale = FALLBACK_LOCALE
	fullscreen = config.get_value("display", "fullscreen", false)
	for bus_name in VOLUME_BUSES:
		volumes[bus_name] = config.get_value("audio", bus_name, DEFAULT_VOLUME)


func _detect_system_locale() -> String:
	var system_language := OS.get_locale_language()
	return system_language if system_language in SUPPORTED_LOCALES else FALLBACK_LOCALE


func _apply_locale() -> void:
	TranslationServer.set_locale(locale)


func _apply_window_mode() -> void:
	var mode := DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED
	DisplayServer.window_set_mode(mode)


func _apply_volume(bus_name: String) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index == -1:
		push_warning("Audio bus not found: %s" % bus_name)
		return
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(get_volume(bus_name)))
