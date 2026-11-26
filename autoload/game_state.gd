extends Node

const MAIN_BOSS_IDS: Array[StringName] = [&"trojan", &"phishing", &"ransomware"]
const SECRET_BOSS_ID := &"bug"
const VICTORIES_TO_UNLOCK_SECRET := 2
const STARTING_ATTACKS: Array[StringName] = [&"scan", &"firewall", &"ping"]
const STARTING_PASSIVES: Array[StringName] = [&"encryption", &"overclock", &"cache"]

var active_slot: int = -1
var victories: Dictionary[StringName, int] = {}
var unlocks: Array[StringName] = []
var equipped_attacks: Array[StringName] = []
var equipped_passives: Array[StringName] = []


func _ready() -> void:
	reset()


func reset() -> void:
	active_slot = -1
	victories.clear()
	unlocks.clear()
	unlocks.append_array(STARTING_ATTACKS)
	unlocks.append_array(STARTING_PASSIVES)
	equipped_attacks = STARTING_ATTACKS.duplicate()
	equipped_passives = STARTING_PASSIVES.duplicate()


func get_victories(boss_id: StringName) -> int:
	return victories.get(boss_id, 0)


func record_victory(boss_id: StringName) -> void:
	victories[boss_id] = get_victories(boss_id) + 1


func is_unlocked(unlock_id: StringName) -> bool:
	return unlock_id in unlocks


func grant_unlock(unlock_id: StringName) -> void:
	if is_unlocked(unlock_id):
		return
	unlocks.append(unlock_id)
	Events.unlock_granted.emit(unlock_id)


func is_secret_boss_unlocked() -> bool:
	for boss_id in MAIN_BOSS_IDS:
		if get_victories(boss_id) < VICTORIES_TO_UNLOCK_SECRET:
			return false
	return true


func to_dict() -> Dictionary:
	return {
		"victories": victories,
		"unlocks": unlocks,
		"equipped_attacks": equipped_attacks,
		"equipped_passives": equipped_passives,
	}


func from_dict(data: Dictionary) -> void:
	reset()
	var saved_victories: Dictionary = data.get("victories", {})
	for boss_id: String in saved_victories:
		victories[StringName(boss_id)] = int(saved_victories[boss_id])
	for unlock_id: String in data.get("unlocks", []):
		if not is_unlocked(unlock_id):
			unlocks.append(StringName(unlock_id))
	equipped_attacks = _to_string_names(data.get("equipped_attacks", STARTING_ATTACKS))
	equipped_passives = _to_string_names(data.get("equipped_passives", STARTING_PASSIVES))


func _to_string_names(values: Array) -> Array[StringName]:
	var result: Array[StringName] = []
	for value in values:
		result.append(StringName(value))
	return result
