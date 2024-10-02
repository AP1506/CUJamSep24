extends AudioStreamPlayer

enum AudioState {PLAYING, LOWERING_VOLUME, RAISING_VOLUME}
enum VolumeState  {LOWERED, NORMAL}

var init_volume
var request_buffer : Array[AudioState]

var volume_state : VolumeState = VolumeState.NORMAL:
	set(value):
		match value:
			VolumeState.LOWERED:
				if playing_state == AudioState.LOWERING_VOLUME:
					volume_state = value
			VolumeState.NORMAL:
				if playing_state == AudioState.RAISING_VOLUME:
					volume_state = value

var playing_state : AudioState = AudioState.PLAYING:
	set(value):
		match value:
			AudioState.PLAYING:
				playing_state = value
			AudioState.LOWERING_VOLUME:
				if volume_state == VolumeState.NORMAL:
					playing_state = value
			AudioState.RAISING_VOLUME:
				if volume_state == VolumeState.LOWERED:
					playing_state = value

# Called when the node enters the scene tree for the first time.
func _ready():
	init_volume = volume_db


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var audioLevel = volume_db
	if (playing_state == AudioState.LOWERING_VOLUME):
		audioLevel = audioLevel - 1 * delta/0.06 # Lower the volume by 1dB every 0.06s
		volume_db = audioLevel
		if volume_db < -30:
			volume_state = VolumeState.LOWERED
			playing_state = AudioState.PLAYING
			playing = false
	elif (playing_state == AudioState.RAISING_VOLUME):
		audioLevel = audioLevel + 1 * delta/0.06 # Raise the volume by 1dB every 0.06s
		volume_db = audioLevel
		if volume_db >= init_volume:
			volume_state = VolumeState.NORMAL
			playing_state = AudioState.PLAYING
			playing = true
	
	if playing_state == AudioState.PLAYING:
		playing_state = request_buffer.pop_front() if request_buffer.size() > 0 else playing_state

func stop_playing():
	request_buffer.append(AudioState.LOWERING_VOLUME)

func restart_playing():
	request_buffer.append(AudioState.RAISING_VOLUME)
