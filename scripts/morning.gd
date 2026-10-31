extends Node2D
## Sabah: Halim rüyasını anlatır, teşekkür eder; değirmenin bir parçası onarılır,
## Dede Yusuf'un bir anısı geri gelir. Oturum "uyku vakti" mesajıyla biter.
## Ekrana dokundukça konuşma ilerler.

var t := 0.0
var step := -1
var lines := [
	["Simitçi Halim", "Günaydın Nil! Bu gece bulutların üstünde kocaman bir simit gördüm. Ne güzel bir rüyaydı!"],
	["Simitçi Halim", "Al bakalım, değirmen için bir çuval un. Bir de rüya kartım senin olsun!"],
	["Pırıl", "Bak! Değirmenin bir kanadı tamir oldu. Dede Yusuf bir şey hatırladı..."],
	["Dede Yusuf", "\"Bu değirmeni ilk çizdiğimde ben de senin yaşındaydım, Nil...\""],
	["Pırıl", "Postacılar da uyur! Yarın gece yeni rüyalar bizi bekliyor. İyi geceler!"],
]
var bubble: Dictionary
var layer: CanvasLayer
var hint: Label
var card_shown := false
var memory: PanelContainer
var mill_spin := 0.0


func _ready() -> void:
	GameState.dream_cards.append("simit")
	layer = CanvasLayer.new()
	add_child(layer)
	bubble = UI.bubble(layer)
	hint = Label.new()
	hint.text = "dokun >"
	hint.add_theme_font_size_override("font_size", 28)
	hint.add_theme_color_override("font_color", Color("6b4f2a"))
	layer.add_child(hint)
	hint.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT, Control.PRESET_MODE_MINSIZE, 30)
	_advance()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_advance()


func _advance() -> void:
	if step >= lines.size() - 1:
		return
	step += 1
	Sfx.play("tap")
	UI.say(bubble, lines[step][0], lines[step][1])
	match step:
		1:
			card_shown = true
			Sfx.play("pickup")
		2:
			GameState.mill_progress = 1
			Sfx.play("success")
		3:
			_show_memory()
		4:
			if memory:
				memory.queue_free()
			hint.visible = false
			var b := UI.big_button(layer, "Baştan oyna", Color("5a7bd6"))
			b.pressed.connect(func(): GameState.go("title"))


func _show_memory() -> void:
	# Yetişkin katmanı: sepya tonlu, resimli bir anı karesi.
	memory = PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("e8d5b0")
	sb.border_color = Color("8a6a3a")
	sb.set_border_width_all(8)
	sb.set_corner_radius_all(6)
	sb.content_margin_left = 30
	sb.content_margin_right = 30
	sb.content_margin_top = 24
	sb.content_margin_bottom = 24
	memory.add_theme_stylebox_override("panel", sb)
	var l := Label.new()
	l.text = "[Anı çizimi]\nKüçük Yusuf, kâğıda ilk değirmenini çiziyor.\nYanında bir ateşböceği uçuyor."
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", 28)
	l.add_theme_color_override("font_color", Color("5a4020"))
	memory.add_child(l)
	memory.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(memory)
	memory.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE)
	memory.grow_horizontal = Control.GROW_DIRECTION_BOTH
	memory.grow_vertical = Control.GROW_DIRECTION_BOTH
	memory.modulate.a = 0.0
	memory.create_tween().tween_property(memory, "modulate:a", 1.0, 0.6)


func _process(delta: float) -> void:
	t += delta
	if GameState.mill_progress > 0:
		mill_spin += delta * 0.8
	queue_redraw()


func _draw() -> void:
	var size := get_viewport_rect().size
	var ground := 600.0
	draw_rect(Rect2(Vector2.ZERO, size), Color("bfe6ff"))
	draw_circle(Vector2(140, 130), 60, Color("ffe066"))
	for i in 3:
		Art.draw_cloud(self, Vector2(fmod(300 + i * 420 + t * 12, size.x + 300) - 150, 110 + i * 40), 150, Color.WHITE)
	draw_colored_polygon(Art.ellipse(Vector2(1080, ground + 160), 380, 300), Color("8cc77a"))
	Art.draw_mill(self, Vector2(1080, ground - 110), GameState.mill_progress == 0, mill_spin)
	draw_rect(Rect2(0, ground - 80, size.x, 80), Color("5aa0d6"))
	Art.draw_house(self, 520, ground, 240, 180, Color("e0b07a"), Color("8a4b2b"), "simit", false)
	draw_rect(Rect2(0, ground, size.x, size.y - ground), Color("c9b38a"))
	_draw_halim(Vector2(700, ground))
	Art.draw_nil(self, Vector2(860, ground), t, false, -1)
	Art.draw_piril(self, Vector2(930, ground - 200 + sin(t * 2.5) * 10), t)
	if card_shown and step < 3:
		_draw_card(Vector2(250, 420))
	# değirmen ilerleme çubuğu: 5 parçadan kaçı tamir edildi
	for i in GameState.MILL_PARTS:
		var r := Rect2(size.x - 330 + i * 60, size.y - 150, 50, 22)
		draw_rect(r, Color("ffcc33") if i < GameState.mill_progress else Color(1, 1, 1, 0.5))
		draw_rect(r, Art.INK, false, 2)


func _draw_halim(p: Vector2) -> void:
	draw_rect(Rect2(p.x - 20, p.y - 40, 15, 40), Color("4a4a4a"))
	draw_rect(Rect2(p.x + 5, p.y - 40, 15, 40), Color("4a4a4a"))
	draw_colored_polygon(Art.ellipse(Vector2(p.x, p.y - 80), 40, 50), Color("e8e8e8"))
	draw_rect(Rect2(p.x - 26, p.y - 100, 52, 60), Color("ffffff"))
	draw_circle(Vector2(p.x, p.y - 150), 30, Art.SKIN)
	draw_circle(Vector2(p.x - 14, p.y - 175), 18, Color.WHITE)
	draw_circle(Vector2(p.x + 14, p.y - 175), 18, Color.WHITE)
	draw_circle(Vector2(p.x, p.y - 185), 20, Color.WHITE)
	draw_circle(Vector2(p.x - 10, p.y - 152), 3.5, Art.INK)
	draw_circle(Vector2(p.x + 10, p.y - 152), 3.5, Art.INK)
	draw_colored_polygon(Art.ellipse(Vector2(p.x, p.y - 138), 16, 5), Color("5a3825"))
	draw_arc(Vector2(p.x, p.y - 134), 8, 0.3, PI - 0.3, 8, Art.INK, 2.5)


func _draw_card(c: Vector2) -> void:
	var r := Rect2(c - Vector2(80, 110), Vector2(160, 220))
	draw_rect(Rect2(r.position + Vector2(6, 6), r.size), Color(0, 0, 0, 0.2))
	draw_rect(r, Color("fff8e8"))
	draw_rect(r, Color("e8a94d"), false, 6)
	draw_rect(Rect2(r.position + Vector2(14, 14), Vector2(132, 120)), Color("ffd6e0"))
	Art.draw_cloud(self, c + Vector2(0, -20), 100, Color.WHITE)
	Art.draw_icon(self, "simit", c + Vector2(0, -60), 30)
	draw_string(ThemeDB.fallback_font, r.position + Vector2(0, 180), "Rüya Kartı", HORIZONTAL_ALIGNMENT_CENTER, 160, 22, Art.INK)
