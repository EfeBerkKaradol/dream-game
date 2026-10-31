extends Node2D
## Simitçi Halim'in rüyası: buluttan buluta zıplayıp dev simite ulaş.
## Sıradaki buluta dokun, Nil zıplar. Kaybetmek yok.
## Huysuz bulut bir "kâbus düğümü": üç kez gıdıklanınca güler ve yol açılır.

const GRUMPY := 4
const TICKLES_NEEDED := 3
const TAP_DIST := 95.0

var t := 0.0
var clouds := [
	Vector2(140, 640), Vector2(330, 560), Vector2(520, 620), Vector2(700, 500),
	Vector2(880, 410), Vector2(1030, 320), Vector2(1150, 230),
]
var star_on := {2: true, 5: true}
var current := 0
var nil_pos := Vector2.ZERO
var hopping := false
var tickles := 0
var grumpy_happy := false
var finished := false
var wobble := 0.0
var bubble: Dictionary
var layer: CanvasLayer
var star_label: Label


func _ready() -> void:
	nil_pos = _stand(0)
	layer = CanvasLayer.new()
	add_child(layer)
	bubble = UI.bubble(layer, 700.0)
	UI.say(bubble, "Pırıl", "Simit kokulu bulutlar! Parlayan buluta dokun, Nil zıplasın.")
	star_label = Label.new()
	star_label.add_theme_font_size_override("font_size", 36)
	star_label.add_theme_color_override("font_color", Color("8a5a00"))
	star_label.position = Vector2(24, 20)
	layer.add_child(star_label)
	_update_stars()


func _stand(i: int) -> Vector2:
	return clouds[i] + Vector2(0, -22)


func _unhandled_input(event: InputEvent) -> void:
	if hopping or finished:
		return
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	var m: Vector2 = event.position
	var next := current + 1
	if next >= clouds.size():
		return
	if m.distance_to(clouds[next]) > TAP_DIST:
		UI.say(bubble, "Pırıl", "Parlayan bulut bir sonraki! Ona dokun.")
		return
	if next == GRUMPY and not grumpy_happy:
		_tickle()
		return
	_hop_to(next)


func _tickle() -> void:
	tickles += 1
	wobble = 1.0
	Sfx.play("tickle")
	if tickles == 1:
		UI.say(bubble, "Huysuz Bulut", "Hıh! Kimseyi geçirmem! ...Hey, gıdıklanıyorum!")
	elif tickles < TICKLES_NEEDED:
		UI.say(bubble, "Huysuz Bulut", "Hi hi... Dur! Hi hi hi!")
	else:
		grumpy_happy = true
		Sfx.play("success")
		UI.say(bubble, "Mutlu Bulut", "Hahaha! Tamam tamam, gel üstüme zıpla!")


func _hop_to(i: int) -> void:
	hopping = true
	Sfx.play("hop")
	var from := nil_pos
	var to := _stand(i)
	var tw := create_tween()
	tw.tween_method(func(v: float):
		nil_pos = from.lerp(to, v) + Vector2(0, -sin(v * PI) * 110), 0.0, 1.0, 0.5)
	tw.tween_callback(func(): _landed(i))


func _landed(i: int) -> void:
	hopping = false
	current = i
	if star_on.get(i, false):
		star_on[i] = false
		GameState.stars += 1
		Sfx.play("pickup")
		_update_stars()
	if i == GRUMPY - 1 and not grumpy_happy:
		UI.say(bubble, "Pırıl", "Aaa, gri bir bulut yolu kesmiş. Çok huysuz görünüyor... Onu gıdıklasana!")
	elif i == clouds.size() - 1:
		finished = true
		Sfx.play("success")
		UI.say(bubble, "Simitçi Halim", "Rüyamdaki dev simit! İşte aradığım buydu!")
		var b := UI.big_button(layer, "Sıradaki rüya", Color("8f7bc0"))
		b.pressed.connect(func(): GameState.go(GameState.next_after("dream_clouds")))


func _update_stars() -> void:
	star_label.text = "Yıldız: %d" % GameState.stars


func _process(delta: float) -> void:
	t += delta
	wobble = maxf(0.0, wobble - delta * 2.0)
	queue_redraw()


func _draw() -> void:
	var size := get_viewport_rect().size
	# pastel rüya gökyüzü
	Art.gradient(self, Rect2(0, 0, size.x, size.y * 0.55), Color("e9dcf0"), Color("f8e3d6"))
	Art.gradient(self, Rect2(0, size.y * 0.55, size.x, size.y * 0.45 + 1), Color("f8e3d6"), Color("e3ecf3"))
	for i in 6:
		Art.draw_cloud(self, Vector2(fmod(i * 260 + t * 8, size.x + 200) - 100, 120 + (i % 3) * 120), 160, Color(1, 1, 1, 0.3))
	# hedef: dev simit
	Art.draw_simit(self, Vector2(1150, 110) + Vector2(0, sin(t * 1.5) * 6), 70)
	for i in clouds.size():
		var c: Vector2 = clouds[i]
		var col := Color("fbf8f3")
		if i == GRUMPY:
			col = Color("f4cfd8") if grumpy_happy else Color("a9adbd")
			c += Vector2(sin(t * 18.0) * 6.0 * wobble, 0)
		Art.draw_cloud(self, c, 170, col)
		if i == current + 1 and not hopping and not finished:
			Art.glow(self, c, 120, Art.BUTTER, 0.5 + 0.2 * sin(t * 2.0))
			draw_arc(c + Vector2(0, -6), 95 + sin(t * 2.0) * 4, 0, TAU, 64, Color(Art.BUTTER, 0.9), 4, true)
		if i == GRUMPY:
			_draw_face(c, grumpy_happy)
		if star_on.get(i, false):
			Art.draw_star(self, c + Vector2(30, -70 + sin(t * 1.5 + i) * 5), 18)
	Art.draw_nil(self, nil_pos, t, false, 1)
	Art.draw_piril(self, nil_pos + Vector2(-60, -170 + sin(t * 1.5) * 8), t)


func _draw_face(c: Vector2, happy: bool) -> void:
	Art.dot(self, c + Vector2(-20, -18), 5, Art.INK)
	Art.dot(self, c + Vector2(20, -18), 5, Art.INK)
	if happy:
		draw_arc(c + Vector2(0, -6), 16, 0.25, PI - 0.25, 14, Art.INK, 3.5, true)
		Art.dot(self, c + Vector2(-34, -6), 8, Color(Art.ROSE, 0.6))
		Art.dot(self, c + Vector2(34, -6), 8, Color(Art.ROSE, 0.6))
	else:
		draw_arc(c + Vector2(0, 8), 14, PI + 0.35, TAU - 0.35, 14, Art.INK, 3.5, true)
		draw_line(c + Vector2(-30, -32), c + Vector2(-13, -27), Art.INK, 3.5, true)
		draw_line(c + Vector2(30, -32), c + Vector2(13, -27), Art.INK, 3.5, true)
