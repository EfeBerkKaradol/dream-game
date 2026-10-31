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
	UI.say(bubble, "Pırıl", "Bütün zarflar hazır! Ama Simitçi Halim'in rüyası çok karışık. Hadi içine girip düzeltelim!")
	var b := UI.big_button(layer, "Rüyaya gir", Color("9b6be0"))
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
	# postane odası ve masa
	draw_rect(Rect2(Vector2.ZERO, size), Color("2c2348"))
	draw_circle(Vector2(size.x / 2, 0), 520, Color(1, 0.85, 0.5, 0.06))
	draw_rect(Rect2(0, 380, size.x, size.y - 380), Color("7a4e2d"))
	draw_rect(Rect2(0, 380, size.x, 16), Color("94623a"))
	for e in envelopes:
		_draw_envelope(e)
	for p in pieces:
		if p.placed:
			continue
		var pos: Vector2 = p.pos
		if p != dragging:
			pos += Vector2(0, sin(t * 2.0 + pos.x) * 6)
		var col: Color = GameState.RESIDENTS[p.kind].color
		draw_circle(pos, 56, Color(col, 0.25))
		draw_circle(pos, 44, Color(col, 0.5))
		draw_arc(pos, 44, 0, TAU, 40, Color.WHITE, 3)
		Art.draw_icon(self, p.kind, pos, 34)
	for s in sparkles:
		draw_circle(s.pos, 5 * s.life / 0.7 + 1, Color("fff3b0"))
	Art.draw_piril(self, Vector2(1150, 200 + sin(t * 2) * 12), t)


func _draw_envelope(e: Dictionary) -> void:
	var c: Vector2 = e.pos
	var r := Rect2(c - ENV_SIZE / 2, ENV_SIZE)
	draw_rect(Rect2(r.position + Vector2(6, 8), r.size), Color(0, 0, 0, 0.25))
	draw_rect(r, Color("fff4d6"))
	var tl := r.position
	var tr := r.position + Vector2(r.size.x, 0)
	if e.filled:
		draw_colored_polygon(PackedVector2Array([tl, tr, c + Vector2(0, 10)]), Color("f0dcae"))
		draw_circle(c + Vector2(0, 10), 18, Color("c43b3b"))
		draw_circle(c + Vector2(0, 10), 10, Color("e05555"))
	else:
		draw_polyline(PackedVector2Array([tl, c + Vector2(0, 10), tr]), Color("c9a86a"), 4)
	# pul: zarfın kime gideceğini gösteren resim
	var stamp := Rect2(tr + Vector2(-78, 10), Vector2(66, 66))
	draw_rect(stamp, Color.WHITE)
	draw_rect(stamp, GameState.RESIDENTS[e.kind].color, false, 4)
	Art.draw_icon(self, e.kind, stamp.get_center(), 26)
