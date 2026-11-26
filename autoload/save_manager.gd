extends Node

const SAVE_VERSION := 1
const SLOT_COUNT := 3
const SAVE_DIR := "user://saves"


func get_slot_path(slot: int) -> String:
	return "%s/slot_%d.json" % [SAVE_DIR, slot]


func slot_exists(slot: int) -> bool:
	return _is_valid_slot(slot) and FileAccess.file_exists(get_slot_path(slot))


func save_slot(slot: int) -> Error:
	if not _is_valid_slot(slot):
		return ERR_INVALID_PARAMETER
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	var file := FileAccess.open(get_slot_path(slot), FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	var payload := {
		"version": SAVE_VERSION,
		"saved_at": Time.get_datetime_string_from_system(true),
		"state": GameState.to_dict(),
	}
	file.store_string(JSON.stringify(payload, "\t"))
	GameState.active_slot = slot
	return OK


func load_slot(slot: int) -> Error:
	if not slot_exists(slot):
		return ERR_FILE_NOT_FOUND
	var payload: Variant = JSON.parse_string(FileAccess.get_file_as_string(get_slot_path(slot)))
	if not payload is Dictionary:
		return ERR_PARSE_ERROR
	var data: Dictionary = _migrate(payload)
	GameState.from_dict(data.get("state", {}))
	GameState.active_slot = slot
	return OK


func delete_slot(slot: int) -> Error:
	if not slot_exists(slot):
		return ERR_FILE_NOT_FOUND
	if GameState.active_slot == slot:
		GameState.reset()
	return DirAccess.remove_absolute(get_slot_path(slot))


func _migrate(payload: Dictionary) -> Dictionary:
	var version := int(payload.get("version", 0))
	if version > SAVE_VERSION:
		push_warning("Save file version %d is newer than supported %d" % [version, SAVE_VERSION])
	return payload


func _is_valid_slot(slot: int) -> bool:
	return slot >= 0 and slot < SLOT_COUNT
