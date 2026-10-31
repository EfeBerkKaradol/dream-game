class_name UI
## Ortak arayüz parçaları: konuşma balonu ve büyük, çocuk dostu butonlar.


static func bubble(layer: CanvasLayer, width := 860.0) -> Dictionary:
	var panel := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(1, 1, 1, 0.95)
	sb.set_corner_radius_all(28)
	sb.border_color = Color("f5c84b")
	sb.set_border_width_all(5)
	sb.content_margin_left = 30
	sb.content_margin_right = 30
	sb.content_margin_top = 14
	sb.content_margin_bottom = 18
	panel.add_theme_stylebox_override("panel", sb)
	var box := VBoxContainer.new()
	panel.add_child(box)
	var who := Label.new()
	who.add_theme_font_size_override("font_size", 24)
	who.add_theme_color_override("font_color", Color("c27b00"))
	box.add_child(who)
	var text := Label.new()
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.custom_minimum_size = Vector2(width, 0)
	text.add_theme_font_size_override("font_size", 32)
	text.add_theme_color_override("font_color", Art.INK)
	box.add_child(text)
	# Balon dokunuşları yutmasın; altındaki oyun alanına geçsin.
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for c in [box, who, text]:
		c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(panel)
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP, Control.PRESET_MODE_MINSIZE, 18)
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	return {"panel": panel, "who": who, "text": text}


## Balondaki konuşmayı değiştirir. Gerçek oyunda burada seslendirme de çalacak.
static func say(b: Dictionary, who: String, text: String) -> void:
	b.who.text = who
	b.text.text = text
	var panel: PanelContainer = b.panel
	panel.modulate.a = 0.0
	panel.create_tween().tween_property(panel, "modulate:a", 1.0, 0.25)


static func big_button(layer: CanvasLayer, text: String, color: Color) -> Button:
	var b := Button.new()
	b.text = text
	b.add_theme_font_size_override("font_size", 40)
	for state in ["normal", "hover", "pressed", "focus"]:
		var sb := StyleBoxFlat.new()
		sb.bg_color = color.darkened(0.15) if state == "pressed" else color
		sb.set_corner_radius_all(40)
		sb.content_margin_left = 48
		sb.content_margin_right = 48
		sb.content_margin_top = 18
		sb.content_margin_bottom = 18
		sb.border_color = Color(1, 1, 1, 0.8)
		sb.set_border_width_all(4)
		b.add_theme_stylebox_override(state, sb)
	for c in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		b.add_theme_color_override(c, Color.WHITE)
	layer.add_child(b)
	b.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM, Control.PRESET_MODE_MINSIZE, 36)
	b.grow_horizontal = Control.GROW_DIRECTION_BOTH
	b.grow_vertical = Control.GROW_DIRECTION_BEGIN
	b.pivot_offset = b.size / 2
	var tw := b.create_tween().set_loops()
	tw.tween_property(b, "scale", Vector2(1.06, 1.06), 0.6).set_trans(Tween.TRANS_SINE)
	tw.tween_property(b, "scale", Vector2.ONE, 0.6).set_trans(Tween.TRANS_SINE)
	b.pressed.connect(func(): Sfx.play("tap"))
	return b
