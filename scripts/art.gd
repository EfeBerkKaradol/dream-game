class_name Art
## Geçici (placeholder) çizimler. Gerçek görseller gelince bu fonksiyonlar
## Sprite2D'lerle değiştirilecek; oyun mantığı aynı kalır.

const INK := Color("2b2340")
const SKIN := Color("f6c9a0")


static func ellipse(c: Vector2, rx: float, ry: float, n := 28) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in n:
		var a := TAU * i / n
		pts.append(c + Vector2(cos(a) * rx, sin(a) * ry))
	return pts


static func draw_nil(ci: CanvasItem, p: Vector2, t: float, walking: bool, facing: int) -> void:
	var bob := sin(t * 12.0) * 4.0 if walking else sin(t * 2.0) * 2.0
	var leg := sin(t * 12.0) * 6.0 if walking else 0.0
	var s := facing
	# bacaklar
	ci.draw_rect(Rect2(p.x - 18, p.y - 36 + leg * 0.3, 13, 36 - leg * 0.3), Color("3b3b58"))
	ci.draw_rect(Rect2(p.x + 5, p.y - 36 - leg * 0.3, 13, 36 + leg * 0.3), Color("3b3b58"))
	# palto
	ci.draw_colored_polygon(PackedVector2Array([
		Vector2(p.x - 22, p.y - 94 + bob), Vector2(p.x + 22, p.y - 94 + bob),
		Vector2(p.x + 32, p.y - 30 + bob), Vector2(p.x - 32, p.y - 30 + bob)]), Color("3f6fd8"))
	# çanta askısı ve çanta
	ci.draw_line(Vector2(p.x - 20 * s, p.y - 92 + bob), Vector2(p.x + 22 * s, p.y - 48 + bob), Color("8a5a2b"), 6)
	var bag_x := p.x + 12 if s > 0 else p.x - 40
	ci.draw_rect(Rect2(bag_x, p.y - 58 + bob, 28, 24), Color("a86b34"))
	ci.draw_rect(Rect2(bag_x, p.y - 58 + bob, 28, 8), Color("8a5a2b"))
	# saç (kafanın arkası) ve at kuyruğu
	ci.draw_circle(Vector2(p.x, p.y - 116 + bob), 29, Color("5a3825"))
	ci.draw_circle(Vector2(p.x - 26 * s, p.y - 110 + bob), 12, Color("5a3825"))
	# kafa
	ci.draw_circle(Vector2(p.x + 3 * s, p.y - 112 + bob), 25, SKIN)
	# postacı şapkası
	ci.draw_rect(Rect2(p.x - 25, p.y - 146 + bob, 50, 18), Color("d94848"))
	ci.draw_rect(Rect2(p.x - 6 + 14 * s, p.y - 132 + bob, 22, 6), Color("a83232"))
	# yüz
	ci.draw_circle(Vector2(p.x - 6 + 6 * s, p.y - 113 + bob), 3.5, INK)
	ci.draw_circle(Vector2(p.x + 10 + 6 * s, p.y - 113 + bob), 3.5, INK)
	ci.draw_circle(Vector2(p.x - 12 + 6 * s, p.y - 104 + bob), 5, Color(1, 0.55, 0.55, 0.5))
	ci.draw_arc(Vector2(p.x + 3 + 5 * s, p.y - 104 + bob), 7, 0.3, PI - 0.3, 10, INK, 2.5)


static func draw_piril(ci: CanvasItem, p: Vector2, t: float, glow := 1.0) -> void:
	var pulse := 0.85 + 0.15 * sin(t * 5.0)
	ci.draw_circle(p, 46 * pulse * glow, Color(1, 0.9, 0.35, 0.10))
	ci.draw_circle(p, 30 * pulse * glow, Color(1, 0.9, 0.35, 0.22))
	var flap := sin(t * 30.0) * 4.0
	ci.draw_colored_polygon(ellipse(p + Vector2(-9, -12 - flap * 0.5), 9, 13 + flap), Color(0.8, 0.95, 1, 0.75))
	ci.draw_colored_polygon(ellipse(p + Vector2(9, -12 - flap * 0.5), 9, 13 + flap), Color(0.8, 0.95, 1, 0.75))
	ci.draw_circle(p, 13, Color("ffe066"))
	ci.draw_circle(p + Vector2(0, 2), 9, Color("fff3b0"))
	ci.draw_circle(p + Vector2(-4, -2), 2.2, INK)
	ci.draw_circle(p + Vector2(4, -2), 2.2, INK)


static func draw_icon(ci: CanvasItem, kind: String, c: Vector2, size: float) -> void:
	match kind:
		"simit":
			ci.draw_arc(c, size * 0.55, 0, TAU, 36, Color("c98a3d"), size * 0.42)
			for i in 10:
				var a := TAU * i / 10.0 + 0.3
				ci.draw_circle(c + Vector2(cos(a), sin(a)) * size * 0.55, size * 0.05, Color("fff4d6"))
		"balik":
			ci.draw_colored_polygon(PackedVector2Array([
				c + Vector2(size * 0.45, 0), c + Vector2(size * 0.85, -size * 0.35),
				c + Vector2(size * 0.85, size * 0.35)]), Color("2f7fc4"))
			ci.draw_colored_polygon(ellipse(c + Vector2(-size * 0.1, 0), size * 0.6, size * 0.38), Color("4da3e8"))
			ci.draw_circle(c + Vector2(-size * 0.4, -size * 0.08), size * 0.08, INK)
		"fener":
			var w := size * 0.32
			ci.draw_colored_polygon(PackedVector2Array([
				c + Vector2(-w, size * 0.8), c + Vector2(w, size * 0.8),
				c + Vector2(w * 0.6, -size * 0.35), c + Vector2(-w * 0.6, -size * 0.35)]), Color("fafafa"))
			for k in 2:
				var y := size * (0.45 - k * 0.45)
				ci.draw_rect(Rect2(c.x - w * 0.85, c.y + y - size * 0.1, w * 1.7, size * 0.18), Color("e04848"))
			ci.draw_circle(c + Vector2(0, -size * 0.55), size * 0.24, Color("ffe066"))
			ci.draw_rect(Rect2(c.x - w * 0.8, c.y - size * 0.82, w * 1.6, size * 0.1), Color("e04848"))
		"zarf":
			ci.draw_rect(Rect2(c.x - size * 0.7, c.y - size * 0.45, size * 1.4, size * 0.9), Color("fff4d6"))
			ci.draw_polyline(PackedVector2Array([
				c + Vector2(-size * 0.7, -size * 0.45), c + Vector2(0, size * 0.1),
				c + Vector2(size * 0.7, -size * 0.45)]), Color("c9a86a"), 4)


static func draw_simit(ci: CanvasItem, c: Vector2, r: float) -> void:
	ci.draw_circle(c, r * 1.5, Color(1, 0.85, 0.5, 0.25))
	draw_icon(ci, "simit", c, r)


static func draw_cloud(ci: CanvasItem, c: Vector2, w: float, col: Color) -> void:
	var shade := col.darkened(0.12)
	ci.draw_colored_polygon(ellipse(c + Vector2(0, 8), w * 0.62, w * 0.2), shade)
	ci.draw_circle(c + Vector2(-w * 0.32, 0), w * 0.24, col)
	ci.draw_circle(c + Vector2(w * 0.3, 2), w * 0.22, col)
	ci.draw_circle(c + Vector2(-w * 0.02, -w * 0.12), w * 0.3, col)
	ci.draw_colored_polygon(ellipse(c + Vector2(0, 4), w * 0.6, w * 0.16), col)


static func draw_house(ci: CanvasItem, x: float, ground: float, w: float, h: float,
		body: Color, roof: Color, kind: String, night: bool) -> void:
	ci.draw_rect(Rect2(x - w / 2, ground - h, w, h), body)
	ci.draw_colored_polygon(PackedVector2Array([
		Vector2(x - w / 2 - 20, ground - h), Vector2(x + w / 2 + 20, ground - h),
		Vector2(x, ground - h - w * 0.45)]), roof)
	# baca
	ci.draw_rect(Rect2(x + w * 0.22, ground - h - w * 0.36, 22, w * 0.25), roof.darkened(0.2))
	var win := Color("ffd96b") if night else Color("bfe3ff")
	ci.draw_rect(Rect2(x - w * 0.38, ground - h * 0.78, w * 0.24, h * 0.24), win)
	ci.draw_rect(Rect2(x + w * 0.14, ground - h * 0.78, w * 0.24, h * 0.24), win)
	ci.draw_rect(Rect2(x - w * 0.12, ground - h * 0.42, w * 0.24, h * 0.42), Color("6b4226"))
	# tabela
	ci.draw_circle(Vector2(x, ground - h - w * 0.16), 26, Color("fff4d6"))
	draw_icon(ci, kind, Vector2(x, ground - h - w * 0.16), 30)


static func draw_mill(ci: CanvasItem, base: Vector2, broken: bool, spin: float) -> void:
	ci.draw_colored_polygon(PackedVector2Array([
		base + Vector2(-40, 0), base + Vector2(40, 0),
		base + Vector2(24, -150), base + Vector2(-24, -150)]), Color("d8c8b0"))
	ci.draw_colored_polygon(PackedVector2Array([
		base + Vector2(-32, -150), base + Vector2(32, -150), base + Vector2(0, -190)]), Color("8a5a5a"))
	var hub := base + Vector2(0, -150)
	for i in 4:
		var a := spin + TAU * i / 4.0
		if broken and i == 1:
			a += 0.9
		var blade := 60.0 if broken and i == 3 else 110.0
		var tip := hub + Vector2(cos(a), sin(a)) * blade
		ci.draw_line(hub, tip, Color("f2e8d8"), 14)
	ci.draw_circle(hub, 10, Color("6b4226"))
