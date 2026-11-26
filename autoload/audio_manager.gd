extends Node

const MUSIC_FADE_TIME := 0.5

var _music_player: AudioStreamPlayer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = &"Music"
	add_child(_music_player)


func play_music(stream: AudioStream) -> void:
	if _music_player.stream == stream and _music_player.playing:
		return
	if _music_player.playing:
		await _fade_music(-80.0)
	_music_player.stream = stream
	_music_player.volume_db = 0.0
	_music_player.play()


func stop_music() -> void:
	await _fade_music(-80.0)
	_music_player.stop()


func play_sfx(stream: AudioStream, bus: StringName = &"SFX") -> void:
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.bus = bus
	player.finished.connect(player.queue_free)
	add_child(player)
	player.play()


func play_voice(stream: AudioStream) -> void:
	play_sfx(stream, &"Voice")


func _fade_music(target_db: float) -> void:
	var tween := create_tween()
	tween.tween_property(_music_player, "volume_db", target_db, MUSIC_FADE_TIME)
	await tween.finished
