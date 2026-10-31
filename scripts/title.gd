extends Node2D
## Açılış ekranı.

var t := 0.0
var stars: Array[Vector2] = []


func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for i in 90:
		stars.append(Vector2(rng.randf_range(0, 1600), rng.randf_range(0, 500)))
	var layer := CanvasLayer.new()
	add_child(layer)
	var title := Label.new()
	title.text = "Rüya Postası"
	title.add_theme_font_size_override("font_size", 96)
	title.add_theme_color_override("font_color", Color("fff3b0"))
	title.add_theme_color_override("font_outline_color", Color("3a2d6b"))
	title.add_theme_constant_override("outline_size", 16)
	layer.add_child(title)
	title.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP, Control.PRESET_MODE_MINSIZE, 110)
	title.grow_horizontal = Control.GROW_DIRECTION_BOTH
	var sub := Label.new()
	sub.text = "Bölüm 1: Fırın Sokağı  (prototip)"
	sub.add_theme_font_size_override("font_size", 32)
	sub.add_theme_color_override("font_color", Color("cfd6ff"))
	layer.add_child(sub)
	sub.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP, Control.PRESET_MODE_MINSIZE, 240)
	sub.grow_horizontal = Control.GROW_DIRECTION_BOTH
	var play := UI.big_button(layer, "Oyna", Color("f08a3c"))
	play.pressed.connect(func():
		GameState.reset()
		GameState.go("night_town"))


func _process(delta: float) -> void:
	t += delta
	queue_redraw()


func _draw() -> void:
	var size := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, size), Color("141a40"))
	draw_rect(Rect2(0, size.y * 0.55, size.x, size.y), Color("1d2457"))
	for i in stars.size():
		var a := 0.5 + 0.5 * sin(t * 2.0 + i)
		draw_circle(stars[i], 2.0, Color(1, 1, 1, a))
	draw_circle(Vector2(size.x - 200, 140), 70, Color("fff3c4"))
	draw_circle(Vector2(size.x - 170, 125), 62, Color("141a40"))
	# tepe ve bozuk değirmen
	draw_colored_polygon(Art.ellipse(Vector2(size.x * 0.82, size.y + 140), 420, 300), Color("1f3a35"))
	Art.draw_mill(self, Vector2(size.x * 0.82, size.y - 140), true, 0.3)
	Art.draw_nil(self, Vector2(size.x * 0.22, size.y - 60), t, false, 1)
	Art.draw_piril(self, Vector2(size.x * 0.22 + 70, size.y - 230 + sin(t * 2) * 12), t)
