extends Node
## Ses dosyası olmadan, kodla üretilen basit ses efektleri.
## Gerçek sesler hazır olunca burası AudioStream dosyalarıyla değiştirilebilir.

const RATE := 22050

var _sounds := {}
var _players: Array[AudioStreamPlayer] = []
var _next := 0


func _ready() -> void:
	for i in 4:
		var p := AudioStreamPlayer.new()
		add_child(p)
		_players.append(p)
	_sounds["pickup"] = _tones([880.0, 1320.0], 0.09)
	_sounds["success"] = _tones([523.0, 659.0, 784.0, 1047.0], 0.1)
	_sounds["wrong"] = _tones([330.0, 262.0], 0.12)
	_sounds["hop"] = _tones([500.0, 750.0], 0.07)
	_sounds["tickle"] = _tones([700.0, 950.0, 700.0, 950.0], 0.05)
	_sounds["tap"] = _tones([660.0], 0.05)
	_sounds["turn"] = _tones([520.0, 780.0], 0.06)
	# balinanın şarkısı için üç yumuşak nota (do, mi, sol)
	for i in 3:
		_sounds["note%d" % i] = _tones([[523.0, 659.0, 784.0][i]], 0.4)


func play(name: String) -> void:
	if not _sounds.has(name):
		return
	var p := _players[_next]
	_next = (_next + 1) % _players.size()
	p.stream = _sounds[name]
	p.play()


func _tones(freqs: Array, dur: float) -> AudioStreamWAV:
	var data := PackedByteArray()
	var n := int(RATE * dur)
	for f in freqs:
		for i in n:
			var t := float(i) / RATE
			# kısa yükseliş + yumuşak sönüş: tıkırtısız, kulağı yormayan ses
			var env := minf(1.0, t / 0.01) * pow(1.0 - float(i) / n, 2.0)
			var v := int(clamp(sin(TAU * f * t) * 0.22 * env, -1.0, 1.0) * 32767.0)
			data.append(v & 0xff)
			data.append((v >> 8) & 0xff)
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = RATE
	w.stereo = false
	w.data = data
	return w
