extends Node2D
## Sabah: kasabalılar rüyalarını anlatır, teşekkür eder; değirmenin bir parçası
## onarılır, Dede Yusuf'un bir anısı geri gelir. Oturum "uyku vakti" mesajıyla biter.
## Ekrana dokundukça konuşma ilerler.

const SPEAKERS := {"Simitçi Halim": "simit", "Balıkçı Ruhi": "balik", "Fenerci Leyla": "fener"}

var t := 0.0
var step := -1
var lines := [
	["Simitçi Halim", "Günaydın Nil! Bu gece bulutların üstünde kocaman bir simit gördüm. Ne güzel bir rüyaydı!"],
	["Balıkçı Ruhi", "Ben de rüyamda bir balinayla şarkı söyledim. Babamın şarkısıydı, yıllardır unutmuştum."],
	["Fenerci Leyla", "Benim fenerim de kayıp bir kâğıt gemiyi eve getirdi. Sağ ol Nil!"],
	["Simitçi Halim", "Değirmen için hepimizden bir hediye! Rüya kartlarımız da senin olsun."],
	["Pırıl", "Bak! Değirmenin bir kanadı tamir oldu. Dede Yusuf bir şey hatırladı..."],
	["Dede Yusuf", "\"Bu değirmeni ilk çizdiğimde ben de senin yaşındaydım, Nil...\""],
	["Pırıl", "Postacılar da uyur! Yarın gece yeni rüyalar bizi bekliyor. İyi geceler!"],
]
var bubble: Dictionary
var layer: CanvasLayer
var hint: Label
var cards_shown := false
var memory: PanelContainer
var mill_spin := 0.0
var speaking := ""


func _ready() -> void:
	layer = CanvasLayer.new()
	add_child(layer)
	bubble = UI.bubble(layer)
	hint = Label.new()
	hint.text = "dokun ›"
	hint.add_theme_font_size_override("font_size", 28)
	hint.add_theme_color_override("font_color", Color("8a6a4a"))
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
	speaking = lines[step][0]
	UI.say(bubble, lines[step][0], lines[step][1])
	match step:
		3:
			cards_shown = true
			GameState.dream_cards.assign(["simit", "balik", "fener"])
			Sfx.play("pickup")
		4:
			GameState.mill_progress = 1
			Sfx.play("success")
		5:
			_show_memory()
		6:
			if memory:
				memory.queue_free()
			hint.visible = false
			var b := UI.big_button(layer, "Baştan oyna", Color("6f8fc4"))
			b.pressed.connect(func(): GameState.go("title"))


func _show_memory() -> void:
	# Yetişkin katmanı: sepya tonlu, resimli bir anı karesi.
	memory = PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("efe0c4")
	sb.border_color = Color("b39672")
	sb.set_border_width_all(8)
	sb.set_corner_radius_all(14)
	sb.anti_aliasing = true
	sb.shadow_color = Color(Art.INK, 0.25)
	sb.shadow_size = 14
	sb.content_margin_left = 34
	sb.content_margin_right = 34
	sb.content_margin_top = 26
	sb.content_margin_bottom = 26
	memory.add_theme_stylebox_override("panel", sb)
	var l := Label.new()
	l.text = "[Anı çizimi]\nKüçük Yusuf, kâğıda ilk değirmenini çiziyor.\nYanında bir ateşböceği uçuyor."
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", 28)
	l.add_theme_color_override("font_color", Color("6b5236"))
	memory.add_child(l)
	memory.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(memory)
	memory.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE)
	memory.grow_horizontal = Control.GROW_DIRECTION_BOTH
	memory.grow_vertical = Control.GROW_DIRECTION_BOTH
	memory.modulate.a = 0.0
	memory.create_tween().tween_property(memory, "modulate:a", 1.0, 0.8)


func _process(delta: float) -> void:
	t += delta
	if GameState.mill_progress > 0:
		mill_spin += delta * 0.5
	queue_redraw()


func _draw() -> void:
	var size := get_viewport_rect().size
	var ground := 600.0
	Art.gradient(self, Rect2(Vector2.ZERO, size), Art.DAY_TOP, Art.DAY_BOTTOM)
	Art.glow(self, Vector2(130, 120), 160, Color("fff0b0"), 0.8)
	Art.dot(self, Vector2(130, 120), 52, Color("fbe3a0"))
	for i in 3:
		Art.draw_cloud(self, Vector2(fmod(300 + i * 420 + t * 6, size.x + 300) - 150, 220 + i * 30), 150, Color("fbf8f3"))
	Art.hills(self, -50, size.x + 50, ground - 100, 50, 0.004, 0.8, Color("b9d8b0"))
	Art.draw_mill(self, Vector2(1100, ground - 110), GameState.mill_progress == 0, mill_spin)
	Art.hills(self, -50, size.x + 50, ground - 60, 24, 0.007, 2.4, Color("9cc5a1"))
	Art.gradient(self, Rect2(0, ground - 52, size.x, 52), Color("8fb8d6"), Color("7aa6c8"))
	Art.draw_house(self, 380, ground, 230, 170, Color("e6c39a"), Color("a86f58"), "simit", false)
	Art.gradient(self, Rect2(0, ground, size.x, size.y - ground), Color("ddc9a3"), Color("cdb68c"))
	var people := {"simit": 560.0, "balik": 690.0, "fener": 820.0}
	for kind in people:
		var x: float = people[kind]
		var p := Vector2(x, ground + 8)
		if SPEAKERS.get(speaking, "") == kind:
			Art.glow(self, p + Vector2(0, -90), 120, Color("fff3c8"), 0.6)
		Art.draw_resident(self, kind, p, t)
	Art.draw_nil(self, Vector2(960, ground + 8), t, false, -1)
	Art.draw_piril(self, Vector2(1030, ground - 190 + sin(t * 1.5) * 8), t)
	if cards_shown and step < 5:
		# her kart, sahibinin başının üstünde
		for kind in people:
			_draw_card(Vector2(people[kind], 300), kind)
	# değirmen ilerleme çubuğu: 5 parçadan kaçı tamir edildi
	for i in GameState.MILL_PARTS:
		var r := Rect2(40 + i * 60, size.y - 60, 50, 22)
		Art.rrect(self, r, Art.BUTTER if i < GameState.mill_progress else Color(Art.CREAM, 0.7), 8, 2, Color("b39672"))


func _draw_card(c: Vector2, kind: String) -> void:
	var r := Rect2(c - Vector2(60, 84), Vector2(120, 168))
	var col: Color = GameState.RESIDENTS[kind].color
	Art.rrect(self, r, Color("fffaf0"), 12, 5, col, 8)
	Art.rrect(self, Rect2(r.position + Vector2(12, 12), Vector2(96, 96)), col.lightened(0.45), 8)
	Art.draw_icon(self, kind, c + Vector2(0, -24), 30)
	draw_string(preload("res://assets/fonts/nunito_bold.tres"), r.position + Vector2(0, 144), "Rüya Kartı",
		HORIZONTAL_ALIGNMENT_CENTER, 120, 18, Art.INK)
