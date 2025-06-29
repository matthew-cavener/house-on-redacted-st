extends Node

var music_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer
var ui_player: AudioStreamPlayer
var investigation_track: AudioStream
var nexus_transfer_sound: AudioStream
var abyssal_mix: AudioStream
var melodys_melodies: AudioStream
var pen_click_randomizer: AudioStreamRandomizer
var correct_sound: AudioStream
var incorrect_sound: AudioStream
var current_music: String = ""
var music_fade_duration: float = 1.0

func _ready():
	_setup_audio_players()
	_load_audio_resources()
	_connect_signals()
	play_music("investigation")

func _setup_audio_players():
	var main_scene = get_tree().current_scene
	var audio_players = main_scene.get_node_or_null("AudioPlayers")
	if audio_players == null:
		print("AudioPlayers not found, creating dummy players")
		_create_dummy_players()
		return
	music_player = audio_players.get_node_or_null("MusicPlayer")
	sfx_player = audio_players.get_node_or_null("SFXPlayer")
	ui_player = audio_players.get_node_or_null("UIPlayer")

func _create_dummy_players():
	music_player = AudioStreamPlayer.new()
	sfx_player = AudioStreamPlayer.new()
	ui_player = AudioStreamPlayer.new()
	add_child(music_player)
	add_child(sfx_player)
	add_child(ui_player)

func _load_audio_resources():
	investigation_track = _load_audio_safe("res://assets/sounds/Investigation Track.wav")
	abyssal_mix = _load_audio_safe("res://assets/sounds/Melody's Melodies [Abyssal Mix].wav")
	melodys_melodies = _load_audio_safe("res://assets/sounds/Melody's Melodies [Pre-Abyss 1960's Mix].wav")
	_setup_pen_click_randomizer()
	correct_sound = _load_audio_safe("res://assets/sounds/UI sound [Correct III].wav")
	incorrect_sound = _load_audio_safe("res://assets/sounds/UI sounds [Incorrect].wav")
	nexus_transfer_sound = _load_audio_safe("res://assets/sounds/Nexus Transfer Sound.wav")

func _setup_pen_click_randomizer():
	pen_click_randomizer = AudioStreamRandomizer.new()
	pen_click_randomizer.playback_mode = AudioStreamRandomizer.PLAYBACK_RANDOM_NO_REPEATS
	pen_click_randomizer.random_pitch = 1.1
	pen_click_randomizer.random_volume_offset_db = 1.1
	var pen_click_paths = [
		"res://assets/sounds/PenClickOut_SFXB.3135.wav",
		"res://assets/sounds/PenClickOut_SFXB.3135 R.wav",
		"res://assets/sounds/PenClickIn_SFXB.3134.wav",
		"res://assets/sounds/ESM_Pen_Button_Click_1_Small_Light_Alert_Interface_Foley_Texture.wav",
		"res://assets/sounds/FF_WP_foley_pen_click_main_single.wav"
	]
	for path in pen_click_paths:
		var sound = _load_audio_safe(path)
		if sound:
			pen_click_randomizer.add_stream(0, sound)
	print("Pen click randomizer setup with %d sounds" % pen_click_randomizer.streams_count)

func _load_audio_safe(path: String) -> AudioStream:
	if ResourceLoader.exists(path):
		return load(path) as AudioStream
	else:
		print("Warning: Audio file not found: " + path)
		return null

func _connect_signals():
	EventBus.evidence_popup_requested.connect(_on_evidence_popup_requested)
	EventBus.evidence_popup_closed.connect(_on_evidence_popup_closed)
	EventBus.puzzle_solved.connect(_on_puzzle_solved)
	EventBus.puzzle_failed.connect(_on_puzzle_failed)

func play_music(track_name: String, fade_in: bool = true):
	var new_stream: AudioStream = null
	match track_name:
		"investigation":
			new_stream = investigation_track
		"abyssal":
			new_stream = abyssal_mix
		"melodys_melodies":
			new_stream = melodys_melodies
		_:
			print("Unknown music track: " + track_name)
			return
	if current_music == track_name and music_player.playing:
		return
	current_music = track_name
	if fade_in and music_player.playing:
		await _fade_out_music()
	if music_player.finished.is_connected(_on_music_finished):
		music_player.finished.disconnect(_on_music_finished)
	music_player.stream = new_stream
	music_player.finished.connect(_on_music_finished)
	music_player.play()
	if fade_in:
		_fade_in_music()

func _on_music_finished():
	print("AudioManager: Music finished - current_music: ", current_music)
	if current_music == "investigation" or current_music == "abyssal":
		print("AudioManager: Looping ", current_music, " track")
		music_player.play()
	else:
		print("AudioManager: One-time track finished, returning to investigation music")
		play_music("investigation", true)

func stop_music(fade_out: bool = true):
	if fade_out:
		await _fade_out_music()
	else:
		music_player.stop()
	current_music = ""

func _fade_out_music():
	var tween = create_tween()
	tween.tween_property(music_player, "volume_db", -80.0, music_fade_duration)
	await tween.finished
	music_player.stop()

func _fade_in_music():
	music_player.volume_db = -80.0
	var tween = create_tween()
	tween.tween_property(music_player, "volume_db", 0.0, music_fade_duration)

func play_pen_click():
	if pen_click_randomizer:
		sfx_player.stream = pen_click_randomizer
		sfx_player.play()

func play_ui_feedback(is_correct: bool):
	var sound = correct_sound if is_correct else incorrect_sound
	if sound:
		ui_player.stream = sound
		ui_player.play()

func switch_to_nexus_music():
	play_music("abyssal", true)

func switch_to_investigation_music():
	play_music("investigation", true)

func play_melodys_melodies():
	play_music("melodys_melodies", false)

func _on_evidence_popup_requested(evidence: EvidenceResource):
	play_pen_click()
	if evidence and evidence.id == "parent_room_tv_with_music":
		print("AudioManager: TV evidence detected - playing Melody's Melodies")
		play_melodys_melodies()

func _on_evidence_popup_closed():
	play_pen_click()

func _on_puzzle_solved(_puzzle_id: String):
	play_ui_feedback(true)

func _on_puzzle_failed():
	play_ui_feedback(false)

func set_music_volume(volume: float):
	var db = linear_to_db(volume)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), db)

func set_sfx_volume(volume: float):
	var db = linear_to_db(volume)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), db)

func set_ui_volume(volume: float):
	var db = linear_to_db(volume)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("UI"), db)
