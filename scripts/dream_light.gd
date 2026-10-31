extends Node2D
## Fenerci Leyla'nın rüyası: fenerin ışığı kayıp kâğıt gemiyi arıyor.
## Aynalara dokununca dönerler; ışığı gemiye ulaştıran yolu bul.
## Işık her an ekranda görünür, oyuncu denedikçe yolun nasıl değiştiğini görür.

const CELL := 150.0
const ORIGIN := Vector2(240, 230)  # ızgaranın (0,0) hücresinin merkezi
const COLS := 6
const ROWS := 3
const LAMP := Vector2i(0, 1)
const BOAT := Vector2i(4, 2)
const TAP_DIST := 70.0

var t := 0.0
## Ayna yönü: "/" ya da "\". Başlangıç yanlış; doğru çözüm: / / \
var mirrors := {Vector2i(2, 1): "\\", Vector2i(2, 0): "\\", Vector2i(4, 0): "/"}
var angles := {}
var path: Array[Vector2] = []
var solved := false
var bubble: Dictionary
var layer: CanvasLayer


func _ready() -> void:
	for m in mirrors:
		angles[m] = _target_angle(mirrors[m])
	layer = CanvasLayer.new()
	add_child(layer)
	bubble = UI.bubble(layer, 760.0)
	UI.say(bubble, "Pırıl", "Leyla'nın feneri kayıp gemiyi arıyor. Aynalara dokun, ışığı gemiye yolla!")
	_trace()


func _cell_pos(c: Vector2i) -> Vector2:
	return ORIGIN + Vector2(c) * CELL


func _target_angle(kind: String) -> float:
	return -PI / 4 if kind == "/" else PI / 4


## Işığı fenerden başlatıp aynalarda yansıtarak izler.
func _trace() -> void:
	path.clear()
	var c := LAMP
	var dir := Vector2i(1, 0)
	path.append(_cell_pos(c) + Vector2(-60, 0))
	for step in 30:
		c += dir
		if c.x < 0 or c.y < 0 or c.x >= COLS or c.y >= ROWS:
			path.append(_cell_pos(c - dir) + Vector2(dir) * CELL * 0.5)
			break
		if c == BOAT:
			path.append(_cell_pos(c))
			_solve()
			return
		if mirrors.has(c):
			path.append(_cell_pos(c))
			# "/" sağı yukarıya, "\" sağı aşağıya çevirir (ekranda y aşağı doğru artar).
			dir = Vector2i(-dir.y, -dir.x) if mirrors[c] == "/" else Vector2i(dir.y, dir.x)


func _solve() -> void:
	if solved:
		return
	solved = true
	Sfx.play("success")
	GameState.stars += 1
	UI.say(bubble, "Fenerci Leyla", "Işık gemiyi buldu! Kâğıt gemim sonunda limana dönüyor.")
	var b := UI.big_button(layer, "Sabah oldu", Color("d98c5f"))
	b.pressed.connect(func(): GameState.go(GameState.next_after("dream_light")))


func _unhandled_input(event: InputEvent) -> void:
	if solved:
		return
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	var m: Vector2 = event.position
	for c in mirrors:
		if m.distance_to(_cell_pos(c)) < TAP_DIST:
			mirrors[c] = "/" if mirrors[c] == "\\" else "\\"
			Sfx.play("turn")
			_trace()
			return


func _process(delta: float) -> void:
	t += delta
	for c in mirrors:
		angles[c] = lerp_angle(angles[c], _target_angle(mirrors[c]), clamp(delta * 10.0, 0.0, 1.0))
	queue_redraw()


func _draw() -> void:
	var size := get_viewport_rect().size
	# yumuşak gece denizi
	Art.gradient(self, Rect2(0, 0, size.x, size.y), Color("3b4277"), Color("6a7fb0"))
	for i in 40:
		var sp := Vector2(fmod(i * 173.0, size.x), fmod(i * 97.0, 260.0))
		Art.dot(self, sp, 1.5, Color("f3e9c6", 0.3 + 0.2 * sin(t * 0.7 + i)))
	Art.gradient(self, Rect2(0, 560, size.x, size.y - 560), Color("4f6a9a"), Color("3f5888"))
	for i in 18:
		var x := fmod(i * 90.0 + t * 6.0, size.x + 60) - 30
		draw_line(Vector2(x, 590 + (i % 3) * 30), Vector2(x + 40, 590 + (i % 3) * 30), Color("f3e9c6", 0.12), 3, true)
	# ızgara noktaları: aynaların durabileceği yerler belli olsun
	for x in COLS:
		for y in ROWS:
			Art.dot(self, _cell_pos(Vector2i(x, y)), 4, Color("f3e9c6", 0.15))
	# ışık huzmesi: geniş ve saydam katmanlar
	if path.size() >= 2:
		for w in [[34.0, 0.10], [18.0, 0.22], [6.0, 0.9]]:
			draw_polyline(PackedVector2Array(path), Color("ffe39a", w[1]), w[0], true)
	Art.draw_lighthouse(self, _cell_pos(LAMP) + Vector2(-80, 278), true, t)
	for c in mirrors:
		Art.draw_mirror(self, _cell_pos(c), angles[c])
	Art.draw_paper_boat(self, _cell_pos(BOAT) + Vector2(0, 10), t, solved)
	Art.draw_piril(self, Vector2(1150, 560 + sin(t * 1.5) * 10), t)
