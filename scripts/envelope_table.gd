extends Node2D
## Zarf masası: her rüya parçası, üstündeki resmi aynı olan zarfa sürüklenir.
## 6-8 yaş için okuma gerektirmez; eşleşme resimle yapılır.

const ENV_SIZE := Vector2(230, 150)
const GRAB_DIST := 70.0

var t := 0.0
var envelopes := [
	{"kind": "balik", "pos": Vector2(330, 520), "filled": false},
	{"kind": "simit", "pos": Vector2(640, 520), "filled": false},
	{"kind": "fener", "pos": Vector2(950, 520), "filled": false},
]
var pieces := []
var dragging = null
var drag_offset := Vector2.ZERO
var bubble: Dictionary
var layer: CanvasLayer
var sparkles := []


func _ready() -> void:
	# Toplanan parçalar üst sırada, zarflardan farklı bir sırayla durur.
	var order := ["fener", "simit", "balik"]
	for i in order.size():
		var home := Vector2(400 + i * 240, 260)
		pieces.append({"kind": order[i], "pos": home, "home": home, "placed": false})
	layer = CanvasLayer.new()
	add_child(layer)
	bubble = UI.bubble(layer)
	UI.say(bubble, "Pırıl", "Her rüyayı, resmi aynı olan zarfa sürükle.")


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var m: Vector2 = event.position
		if event.pressed:
			for p in pieces:
				if not p.placed and m.distance_to(p.pos) < GRAB_DIST:
					dragging = p
					drag_offset = p.pos - m
					Sfx.play("tap")
					break
		elif dragging != null:
			_drop(dragging, m)
			dragging = null
	elif event is InputEventMouseMotion and dragging != null:
		dragging.pos = event.position + drag_offset


func _drop(p: Dictionary, m: Vector2) -> void:
	for e in envelopes:
		var r := Rect2(e.pos - ENV_SIZE / 2, ENV_SIZE).grow(30)
		if not r.has_point(m):
			continue
		if e.kind == p.kind and not e.filled:
			e.filled = true
			p.placed = true
			p.pos = e.pos
			GameState.delivered.append(p.kind)
			Sfx.play("success")
			for k in 12:
				sparkles.append({"pos": e.pos, "vel": Vector2.from_angle(TAU * k / 12.0) * 220, "life": 0.7})
			_check_done()
			return
		Sfx.play("wrong")
		UI.say(bubble, "Pırıl", "Hımm, bu zarf değil galiba. Resimlere bir daha bak!")
		break
	_slide_home(p)


func _slide_home(p: Dictionary) -> void:
	var from: Vector2 = p.pos
	var to: Vector2 = p.home
	create_tween().tween_method(func(v: float): p.pos = from.lerp(to, v), 0.0, 1.0, 0.25) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _check_done() -> void:
	if GameState.delivered.size() < envelopes.size():
		UI.say(bubble, "Pırıl", "Doğru zarf! Çok güzel.")
		return
	UI.say(bubble, "Pırıl", "Bütün zarflar hazır! Ama rüyalar çok karışık. Hadi tek tek içlerine girip düzeltelim!")
	var b := UI.big_button(layer, "Rüyaya gir", Color("8f7bc0"))
	b.pressed.connect(func(): GameState.go("dream_clouds"))


func _process(delta: float) -> void:
	t += delta
	for s in sparkles:
		s.pos += s.vel * delta
		s.life -= delta
	sparkles = sparkles.filter(func(s): return s.life > 0)
	queue_redraw()


func _draw() -> void:
	var size := get_viewport_rect().size
	# postane odası: sıcak lamba ışığı, raflar ve ahşap masa
	Art.gradient(self, Rect2(0, 0, size.x, 400), Color("3a3560"), Color("4d4672"))
	Art.glow(self, Vector2(size.x / 2, 40), 620, Color("ffdca0"), 0.5)
	for k in 3:
		var sx := 80 + k * 400
		Art.rrect(self, Rect2(sx, 90 + k * 14, 220, 12), Color("6b5a7a"), 6)
		for j in 4:
			Art.rrect(self, Rect2(sx + 14 + j * 50, 50 + k * 14, 36, 40), [Art.ROSE, Art.BUTTER, Art.SAGE, Art.DUSTY_BLUE][(j + k) % 4].darkened(0.25), 6)
	Art.gradient(self, Rect2(0, 380, size.x, size.y - 380), Color("a8774f"), Color("8c6142"))
	Art.rrect(self, Rect2(-20, 372, size.x + 40, 22), Color("b98a60"), 10)
	for k in 5:
		draw_line(Vector2(0, 430 + k * 60), Vector2(size.x, 430 + k * 60), Color(Art.INK, 0.06), 2, true)
	for e in envelopes:
		_draw_envelope(e)
	for p in pieces:
		if p.placed:
			continue
		var pos: Vector2 = p.pos
		if p != dragging:
			pos += Vector2(0, sin(t * 1.3 + pos.x) * 5)
		Art.draw_fragment(self, p.kind, pos, t, GameState.RESIDENTS[p.kind].color)
	for sp in sparkles:
		Art.draw_star(self, sp.pos, 8 * sp.life / 0.7 + 2)
	Art.draw_piril(self, Vector2(1150, 220 + sin(t * 1.5) * 10), t)


func _draw_envelope(e: Dictionary) -> void:
	var c: Vector2 = e.pos
	var r := Rect2(c - ENV_SIZE / 2, ENV_SIZE)
	Art.rrect(self, r, Art.CREAM, 12, 2, Color("e0cfae"), 10)
	var tl := r.position + Vector2(6, 6)
	var tr := r.position + Vector2(r.size.x - 6, 6)
	if e.filled:
		Art.blob(self, PackedVector2Array([tl, tr, c + Vector2(0, 14)]), Color("f1e3c6"), 2)
		Art.dot(self, c + Vector2(0, 14), 18, Color("c97a72"))
		Art.dot(self, c + Vector2(0, 14), 10, Color("dd948b"))
	else:
		draw_polyline(PackedVector2Array([tl, c + Vector2(0, 14), tr]), Color("d5bf94"), 3, true)
	# pul: zarfın kime gideceğini gösteren resim
	var col: Color = GameState.RESIDENTS[e.kind].color
	var stamp := Rect2(tr + Vector2(-72, 6), Vector2(64, 64))
	Art.rrect(self, stamp, Color("fffaf0"), 8, 4, col)
	Art.draw_icon(self, e.kind, stamp.get_center(), 24)
