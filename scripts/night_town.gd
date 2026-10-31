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
		Art.rrect(self, Rect2(0, 0, 250, 90), Color("2f2c4f", 0.6), 24, 3, Color(Art.CREAM, 0.35))
		for i in 3:
			var c := Vector2(45 + i * 80, 45)
			Art.dot(self, c, 30, Color(Art.CREAM, 0.14))
			if i < kinds.size():
				Art.draw_icon(self, kinds[i], c, 32)


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
		var b := UI.big_button(bubble.panel.get_parent(), "Postaneye git", Color("6fa27a"))
		b.pressed.connect(func(): GameState.go("envelope_table"))


func _draw() -> void:
	var cx := cam.get_screen_center_position().x if cam else nil_x
	# gökyüzü (kameraya sabit) ve yavaş parlayan yıldızlar
	Art.gradient(self, Rect2(cx - 1100, 0, 2200, 720), Art.NIGHT_TOP, Art.NIGHT_BOTTOM)
	for i in stars.size():
		var sp := stars[i] + Vector2(cx * 0.9, 0)
		Art.dot(self, sp, 1.6, Color("f3e9c6", 0.3 + 0.25 * sin(t * 0.7 + i)))
	var moon := Vector2(cx + 300, 235)
	Art.glow(self, moon, 150, Color("fbeec4"), 0.6)
	Art.dot(self, moon, 50, Color("fbeec4"))
	Art.dot(self, moon + Vector2(16, -9), 43, Art.NIGHT_TOP.lerp(Art.NIGHT_BOTTOM, 0.3))
	# uzak tepeler ve değirmen (yavaş kayar: derinlik hissi)
	var far := cx * 0.6
	Art.hills(self, far - 1000, far + WORLD_W, 470, 70, 0.003, 0.5, Color("323866"))
	Art.draw_mill(self, Vector2(1050 + far, 440), true, 0.4)
	var mid := cx * 0.3
	Art.hills(self, mid - 1000, mid + WORLD_W + 800, 520, 40, 0.005, 2.0, Color("2f4a58"))
	# deniz: yumuşak geçiş ve ay yansıması
	Art.gradient(self, Rect2(-400, 512, WORLD_W + 800, 90), Color("3a5a8a"), Color("2e4670"))
	for i in 34:
		var x := -300 + i * 100 + sin(t * 0.6 + i) * 8
		var y := 536 + (i % 3) * 18
		draw_line(Vector2(x, y), Vector2(x + 36, y), Color("f3e9c6", 0.12), 3, true)
	for k in 5:
		draw_line(Vector2(moon.x - 30 + k * 4, 530 + k * 14), Vector2(moon.x + 30 - k * 4, 530 + k * 14), Color("fbeec4", 0.25 - k * 0.04), 4, true)
	# evler: postane, simitçi, balıkçı, fenerci
	Art.draw_house(self, 260, GROUND, 220, 170, Color("8ea6d8"), Color("4f5f9a"), "zarf", true)
	Art.draw_house(self, 820, GROUND, 200, 160, Color("e6c39a"), Color("a86f58"), "simit", true)
	Art.draw_house(self, 1450, GROUND, 200, 150, Color("a9cbdc"), Color("5f86a8"), "balik", true)
	Art.draw_house(self, 1950, GROUND, 190, 200, Color("e8b9b4"), Color("a8686e"), "fener", true)
	for lx in [540.0, 1140.0, 1700.0, 2250.0]:
		Art.draw_lamp(self, lx, GROUND, true)
	# taş sokak
	Art.gradient(self, Rect2(-400, GROUND, WORLD_W + 800, 120), Color("5e5878"), Color("4e4866"))
	for i in 60:
		var bx := -380 + i * 60 + (i % 2) * 30
		Art.rrect(self, Rect2(bx, GROUND + 30 + (i % 2) * 34, 44, 18), Color("6a6486"), 9)
	# rüya parçaları
	for f in fragments:
		if f.taken:
			continue
		var p: Vector2 = f.pos + Vector2(0, sin(t * 1.3 + f.pos.x) * 8)
		Art.draw_fragment(self, f.kind, p, t, GameState.RESIDENTS[f.kind].color)
	Art.draw_nil(self, Vector2(nil_x, GROUND), t, absf(target_x - nil_x) > 4.0, facing)
	Art.draw_piril(self, piril, t, 1.3 if idle > HINT_AFTER else 1.0)
