@warning_ignore_start("unused_signal")
extends Node

signal boss_defeated(boss_id: StringName)
signal boss_phase_changed(boss_id: StringName, phase_index: int)
signal player_died
signal unlock_granted(unlock_id: StringName)
signal minion_killed(minion_id: StringName)

signal debug_hitboxes_toggled(enabled: bool)
signal debug_invincibility_toggled(enabled: bool)
signal debug_skip_phase_requested
