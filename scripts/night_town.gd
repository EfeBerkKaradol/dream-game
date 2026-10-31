extends Node2D
## Gece turu: Nil sokakta yürür, saçılmış rüya parçalarını toplar.
## Kontrol: ekrana dokun, Nil oraya yürür. Pırıl, oyuncu takılınca ipucu verir.

const WORLD_W := 2600.0
const GROUND := 600.0
const SPEED := 340.0
const PICK_DIST := 110.0
const HINT_AFTER := 6.0

var t := 0.0
var nil_x := 260.0
var target_x := 260.0
var facing := 1
var piril := Vector2(330, 420)
var idle := 0.0
var fragments := [
	{"kind": "simit", "pos": Vector2(1020, 470), "taken": false},
	{"kind": "balik", "pos": Vector2(1720, 500), "taken": false},
	{"kind": "fener", "pos": Vector2(2420, 455), "taken": false},
]
var stars: Array[Vector2] = []
var cam: Camera2D
var bubble: Dictionary
var bag: BagSlots
var done := false


class BagSlots extends Control:
	var kinds: Array[String] = []

	func _draw() -> void:
		draw_rect(Rect2(0, 0, 250, 90), Color(0, 0, 0, 0.35))
		for i in 3:
			var c := Vector2(45 + i * 80, 45)
			draw_circle(c, 32, Color(1, 1, 1, 0.15))
			if i < kinds.size():
				Art.draw_icon(self, kinds[i], c, 34)


func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 3
	for i in 160:
		stars.append(Vector2(rng.randf_range(-400, WORLD_W + 400), rng.randf_range(0, 380)))
	cam = Camera2D.new()
	cam.limit_left = 0
	cam.limit_right = int(WORLD_W)
	cam.limit_top = 0
	cam.limit_bottom = 720
	cam.position_smoothing_enabled = true
	add_child(cam)
	cam.make_current()
	var layer := CanvasLayer.new()
	add_child(layer)
	bubble = UI.bubble(layer)
	UI.say(bubble, "Pırıl", "Eyvah, rüyalar sokağa saçılmış! Ekrana dokun, Nil oraya yürüsün.")
	bag = BagSlots.new()
	bag.position = Vector2(20, 610)
	layer.add_child(bag)


func _unhandled_input(event: InputEvent) -> void:
	if done:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		target_x = clamp(_world_pos(event).x, 60.0, WORLD_W - 60.0)
		idle = 0.0


## Dokunuşun dünya koordinatı (kamera kaydırmasını hesaba katar).
func _world_pos(event: InputEvent) -> Vector2:
	return (make_input_local(event) as InputEventMouse).position


func _process(delta: float) -> void:
	t += delta
	var walking := absf(target_x - nil_x) > 4.0
	if walking:
		var step := signf(target_x - nil_x) * SPEED * delta
		facing = 1 if step > 0 else -1
		nil_x = target_x if absf(step) > absf(target_x - nil_x) else nil_x + step
	else:
		idle += delta
	cam.position = Vector2(nil_x, 360)

	for f in fragments:
		if not f.taken and Vector2(nil_x, GROUND - 90).distance_to(f.pos) < PICK_DIST:
			_take(f)

	# Pırıl Nil'in yanında uçar; oyuncu uzun süre durursa en yakın parçaya gidip ipucu verir.
	var goal := Vector2(nil_x - 70 * facing, GROUND - 190 + sin(t * 2.5) * 14)
	var hint = _nearest_fragment()
	if hint != null and idle > HINT_AFTER:
		goal = hint.pos + Vector2(0, -80 + sin(t * 4) * 10)
	piril = piril.lerp(goal, clamp(delta * 3.0, 0.0, 1.0))
	queue_redraw()


func _nearest_fragment():
	var best = null
	for f in fragments:
		if not f.taken and (best == null or absf(f.pos.x - nil_x) < absf(best.pos.x - nil_x)):
			best = f
	return best


func _take(f: Dictionary) -> void:
	f.taken = true
	GameState.collected.append(f.kind)
	bag.kinds = GameState.collected
	bag.queue_redraw()
	Sfx.play("pickup")
	idle = 0.0
	var left := 3 - GameState.collected.size()
	if left > 0:
		UI.say(bubble, "Pırıl", "Bir rüya buldun! %d tane daha kaldı." % left)
	else:
		done = true
		Sfx.play("success")
		UI.say(bubble, "Pırıl", "Hepsi çantada! Şimdi postaneye dönüp zarflara koyalım.")
		var b := UI.big_button(bubble.panel.get_parent(), "Postaneye git", Color("4caf6a"))
		b.pressed.connect(func(): GameState.go("envelope_table"))


func _draw() -> void:
	# gökyüzü ve yıldızlar
	draw_rect(Rect2(-400, 0, WORLD_W + 800, 720), Color("141a40"))
	draw_rect(Rect2(-400, 300, WORLD_W + 800, 300), Color("1b2252"))
	for i in stars.size():
		draw_circle(stars[i], 1.8, Color(1, 1, 1, 0.4 + 0.4 * sin(t * 1.5 + i)))
	draw_circle(Vector2(1300, 250), 55, Color("fff3c4"))
	draw_circle(Vector2(1324, 238), 48, Color("141a40"))
	# tepe ve bozuk değirmen (arka plan)
	draw_colored_polygon(Art.ellipse(Vector2(2250, 760), 520, 330), Color("1f3a35"))
	Art.draw_mill(self, Vector2(2250, 450), true, 0.4)
	# deniz
	draw_rect(Rect2(-400, 520, WORLD_W + 800, 80), Color("23407a"))
	for i in 30:
		var x := -300 + i * 110 + sin(t + i) * 10
		draw_line(Vector2(x, 548 + (i % 3) * 14), Vector2(x + 40, 548 + (i % 3) * 14), Color(1, 1, 1, 0.15), 3)
	# evler: postane, simitçi, balıkçı, fenerci
	Art.draw_house(self, 260, GROUND, 220, 170, Color("5a7bd6"), Color("2d3f7a"), "zarf", true)
	Art.draw_house(self, 820, GROUND, 200, 160, Color("e0b07a"), Color("8a4b2b"), "simit", true)
	Art.draw_house(self, 1450, GROUND, 200, 150, Color("7ab8d6"), Color("2b5a8a"), "balik", true)
	Art.draw_house(self, 1950, GROUND, 190, 200, Color("e7a0a0"), Color("8a2b3b"), "fener", true)
	# sokak
	draw_rect(Rect2(-400, GROUND, WORLD_W + 800, 120), Color("4a3f5c"))
	for i in 40:
		draw_rect(Rect2(-380 + i * 90, GROUND + 40, 50, 8), Color(1, 1, 1, 0.08))
	# rüya parçaları
	for f in fragments:
		if f.taken:
			continue
		var p: Vector2 = f.pos + Vector2(0, sin(t * 2.0 + f.pos.x) * 10)
		var col: Color = GameState.RESIDENTS[f.kind].color
		draw_circle(p, 62, Color(col, 0.15))
		draw_circle(p, 46, Color(col, 0.35))
		draw_arc(p, 46, 0, TAU, 40, Color(1, 1, 1, 0.7), 3)
		Art.draw_icon(self, f.kind, p, 36)
		for k in 3:
			var a := t * 2.0 + k * TAU / 3.0
			draw_circle(p + Vector2(cos(a), sin(a)) * 58, 3, Color(1, 1, 1, 0.8))
	Art.draw_nil(self, Vector2(nil_x, GROUND), t, absf(target_x - nil_x) > 4.0, facing)
	Art.draw_piril(self, piril, t, 1.3 if idle > HINT_AFTER else 1.0)
