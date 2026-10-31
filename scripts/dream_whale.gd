extends Node2D
## Balıkçı Ruhi'nin rüyası: denizin dibinde şarkı söyleyen bir balina.
## Balina deniz kabuklarını sırayla parlatıp bir şarkı söyler; oyuncu aynı
## sırayla kabuklara dokunur. Üç tur: 2, 3 ve 3 nota. Yanlışta ceza yok,
## balina şarkıyı yavaşça tekrar söyler.

const SHELL_COLORS := [Color("e8a0a0"), Color("f2d38a"), Color("9fcaa6")]
const ROUNDS := [[0, 2], [1, 0, 2], [2, 1, 0]]
const TAP_DIST := 80.0

var t := 0.0
var shells: Array[Vector2] = [Vector2(480, 580), Vector2(740, 610), Vector2(1000, 580)]
var lit := [0.0, 0.0, 0.0]
var round_i := 0
var input_i := 0
var listening := false
var singing := false
var finished := false
var bubbles := []
var bubble: Dictionary
var layer: CanvasLayer


func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	for i in 26:
		bubbles.append(Vector2(rng.randf_range(0, 1400), rng.randf_range(0, 720)))
	layer = CanvasLayer.new()
	add_child(layer)
	bubble = UI.bubble(layer, 760.0)
	UI.say(bubble, "Pırıl", "Ruhi'nin rüyasında bir balina var! Şarkısını dinle, sonra aynı kabuklara sırayla dokun.")
	await get_tree().create_timer(2.0).timeout
	_sing()


func _sing() -> void:
	singing = true
	listening = false
	input_i = 0
	for k in ROUNDS[round_i]:
		await get_tree().create_timer(0.35).timeout
		_light(k)
		await get_tree().create_timer(0.55).timeout
	singing = false
	listening = true


func _light(k: int) -> void:
	lit[k] = 1.0
	Sfx.play("note%d" % k)


func _unhandled_input(event: InputEvent) -> void:
	if not listening or finished:
		return
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	var m: Vector2 = event.position
	for k in shells.size():
		if m.distance_to(shells[k]) < TAP_DIST:
			_pick(k)
			return


func _pick(k: int) -> void:
	_light(k)
	var song: Array = ROUNDS[round_i]
	if song[input_i] != k:
		listening = false
		UI.say(bubble, "Balina", "Mmm... Bir daha dinler misin? Yavaşça söylüyorum.")
		await get_tree().create_timer(1.2).timeout
		_sing()
		return
	input_i += 1
	if input_i < song.size():
		return
	listening = false
	round_i += 1
	if round_i < ROUNDS.size():
		Sfx.play("pickup")
		UI.say(bubble, "Balina", ["Ne güzel söyledin! Bir şarkı daha.", "Harika! Son şarkı geliyor."][round_i - 1])
		await get_tree().create_timer(1.6).timeout
		_sing()
	else:
		finished = true
		Sfx.play("success")
		GameState.stars += 1
		UI.say(bubble, "Balıkçı Ruhi", "Bu şarkıyı hatırlıyorum! Babam denizde hep bunu söylerdi.")
		var b := UI.big_button(layer, "Sıradaki rüya", Color("8f7bc0"))
		b.pressed.connect(func(): GameState.go(GameState.next_after("dream_whale")))


func _process(delta: float) -> void:
	t += delta
	for k in lit.size():
		lit[k] = maxf(0.0, lit[k] - delta * 1.6)
	queue_redraw()


func _draw() -> void:
	var size := get_viewport_rect().size
	# su: yukarıda açık, dipte derin ama yumuşak
	Art.gradient(self, Rect2(0, 0, size.x, size.y), Color("bfe0e3"), Color("5f8fae"))
	# yukarıdan süzülen ışık huzmeleri
	for k in 4:
		var x := 200 + k * 320 + sin(t * 0.3 + k) * 30
		draw_colored_polygon(PackedVector2Array([Vector2(x - 30, 0), Vector2(x + 30, 0),
			Vector2(x + 140, size.y), Vector2(x + 20, size.y)]), Color(1, 1, 1, 0.07))
	# yükselen kabarcıklar
	for i in bubbles.size():
		var b: Vector2 = bubbles[i]
		var y := fposmod(b.y - t * (20 + i % 4 * 6), size.y + 40) - 20
		Art.ring(self, Vector2(b.x + sin(t + i) * 8, y), 4 + i % 3 * 2, Color(1, 1, 1, 0.35), 1.5)
	# kum ve deniz otları
	Art.hills(self, -50, size.x + 50, size.y - 120, 30, 0.006, 1.2, Color("e6d6b4"))
	for k in 7:
		var bx := 80 + k * 190
		for j in 3:
			var top := Vector2(bx + j * 14 + sin(t * 0.8 + k + j) * 10, size.y - 230 - j * 20)
			draw_line(Vector2(bx + j * 14, size.y - 100), top, Color("7fb08a"), 8, true)
	Art.draw_whale(self, Vector2(330, 300), t, singing)
	for k in shells.size():
		Art.draw_shell(self, shells[k], SHELL_COLORS[k], lit[k])
	# notalar: balina şarkı söylerken yükselen küçük notalar
	if singing:
		for k in 3:
			var p := Vector2(170 + k * 26, 260 - fmod(t * 40 + k * 30, 90))
			Art.dot(self, p, 6, Color(Art.INK, 0.6))
			draw_line(p + Vector2(5, 0), p + Vector2(5, -18), Color(Art.INK, 0.6), 2, true)
	# tur göstergesi
	for k in ROUNDS.size():
		Art.dot(self, Vector2(size.x - 120 + k * 34, size.y - 40), 10,
			Art.BUTTER if k < round_i else Color(Art.CREAM, 0.5))
	Art.draw_piril(self, Vector2(1150, 330 + sin(t * 1.5) * 10), t)
