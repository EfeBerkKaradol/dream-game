extends Node2D
## Açılış ekranı.

var t := 0.0
var stars: Array[Vector2] = []


func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for i in 70:
		stars.append(Vector2(rng.randf_range(0, 1600), rng.randf_range(0, 420)))
	var layer := CanvasLayer.new()
	add_child(layer)
	var title := Label.new()
	title.text = "Rüya Postası"
	title.add_theme_font_size_override("font_size", 92)
	title.add_theme_color_override("font_color", Color("fcefc0"))
	title.add_theme_color_override("font_outline_color", Color("4a4278"))
	title.add_theme_constant_override("outline_size", 14)
	title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.2))
	title.add_theme_constant_override("shadow_offset_y", 6)
	layer.add_child(title)
	title.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP, Control.PRESET_MODE_MINSIZE, 100)
	title.grow_horizontal = Control.GROW_DIRECTION_BOTH
	var sub := Label.new()
	sub.text = "Bölüm 1: Fırın Sokağı"
	sub.add_theme_font_size_override("font_size", 30)
	sub.add_theme_color_override("font_color", Color("d7d9f2"))
	layer.add_child(sub)
	sub.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP, Control.PRESET_MODE_MINSIZE, 228)
	sub.grow_horizontal = Control.GROW_DIRECTION_BOTH
	var play := UI.big_button(layer, "Oyna", Color("d98c5f"))
	play.pressed.connect(func():
		GameState.reset()
		GameState.go("night_town"))


func _process(delta: float) -> void:
	t += delta
	queue_redraw()


func _draw() -> void:
	var size := get_viewport_rect().size
	Art.gradient(self, Rect2(Vector2.ZERO, size), Art.NIGHT_TOP, Art.NIGHT_BOTTOM)
	for i in stars.size():
		Art.dot(self, stars[i], 1.6, Color("f3e9c6", 0.35 + 0.3 * sin(t * 0.8 + i)))
	var moon := Vector2(size.x - 200, 130)
	Art.glow(self, moon, 150, Color("fbeec4"), 0.7)
	Art.dot(self, moon, 58, Color("fbeec4"))
	Art.dot(self, moon + Vector2(18, -10), 50, Color(Art.NIGHT_TOP.lerp(Art.NIGHT_BOTTOM, 0.25)))
	Art.hills(self, -50, size.x + 50, size.y - 170, 60, 0.004, 1.0, Color("343a6a"))
	Art.draw_mill(self, Vector2(size.x * 0.8, size.y - 170), true, 0.3)
	Art.hills(self, -50, size.x + 50, size.y - 90, 40, 0.006, 2.5, Color("2c4a4f"))
	Art.draw_nil(self, Vector2(size.x * 0.22, size.y - 50), t, false, 1)
	Art.draw_piril(self, Vector2(size.x * 0.22 + 70, size.y - 220 + sin(t * 1.5) * 10), t)
