class_name Art
## Kodla çizilen görseller. Gerçek çizimler gelince bu fonksiyonlar Sprite2D'lerle
## değiştirilebilir; oyun mantığı aynı kalır.
##
## Göz yormayan görsel kurallar (docs/GORSEL_DIL.md):
## - Saf siyah ve saf beyaz yok; kontur rengi dolgunun koyu tonu.
## - Doygunluğu düşük, pastel palet; gece sahneleri koyu değil, mürekkep mavisi.
## - Bütün kenarlar yumuşak (antialias), köşeler yuvarlak.
## - Hareketler yavaş ve küçük; hızlı yanıp sönme yok.

const INK := Color("3d3550")
const SKIN := Color("f2c6a0")
const CREAM := Color("fff6e6")

const NIGHT_TOP := Color("1f2547")
const NIGHT_BOTTOM := Color("3b4277")
const DAY_TOP := Color("a8d3e6")
const DAY_BOTTOM := Color("eef3e8")

const APRICOT := Color("f0b27a")
const ROSE := Color("e3a4a4")
const SAGE := Color("9cc5a1")
const DUSTY_BLUE := Color("7fa7c9")
const BUTTER := Color("f5d98b")
const LAVENDER := Color("b9a7d6")


# --- temel şekiller -----------------------------------------------------------

static func ellipse(c: Vector2, rx: float, ry: float, n := 32) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in n:
		var a := TAU * i / n
		pts.append(c + Vector2(cos(a) * rx, sin(a) * ry))
	return pts


## Yumuşak kenarlı çokgen: dolgu + aynı renkte antialias kenar çizgisi.
static func blob(ci: CanvasItem, pts: PackedVector2Array, col: Color, outline := 0.0) -> void:
	ci.draw_colored_polygon(pts, col)
	var closed := pts.duplicate()
	closed.append(pts[0])
	if outline > 0.0:
		ci.draw_polyline(closed, col.darkened(0.28), outline, true)
	else:
		ci.draw_polyline(closed, col, 1.5, true)


static func dot(ci: CanvasItem, c: Vector2, r: float, col: Color) -> void:
	ci.draw_circle(c, r, col, true, -1.0, true)


static func ring(ci: CanvasItem, c: Vector2, r: float, col: Color, w: float) -> void:
	ci.draw_arc(c, r, 0, TAU, maxi(24, int(r)), col, w, true)


## Yuvarlak köşeli dikdörtgen (StyleBoxFlat ile, kenarları yumuşak).
static func rrect(ci: CanvasItem, r: Rect2, col: Color, radius := 12.0, border := 0.0,
		border_col := Color.TRANSPARENT, shadow := 0.0) -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = col
	sb.set_corner_radius_all(int(radius))
	sb.anti_aliasing = true
	if border > 0.0:
		sb.set_border_width_all(int(border))
		sb.border_color = border_col if border_col.a > 0.0 else col.darkened(0.28)
	if shadow > 0.0:
		sb.shadow_size = int(shadow)
		sb.shadow_color = Color(INK, 0.18)
		sb.shadow_offset = Vector2(0, shadow * 0.4)
	sb.draw(ci.get_canvas_item(), r)


## Dikey renk geçişi.
static func gradient(ci: CanvasItem, r: Rect2, top: Color, bottom: Color) -> void:
	ci.draw_polygon(PackedVector2Array([r.position, r.position + Vector2(r.size.x, 0),
		r.end, r.position + Vector2(0, r.size.y)]),
		PackedColorArray([top, top, bottom, bottom]))


## Yumuşak ışık halesi: iç içe, çok saydam daireler.
static func glow(ci: CanvasItem, c: Vector2, r: float, col: Color, strength := 0.5) -> void:
	# Çok sayıda, çok saydam katman: halkalanma (bantlaşma) görünmesin.
	for i in 14:
		var k := 1.0 - i / 14.0
		ci.draw_circle(c, r * k, Color(col, strength * 0.045), true, -1.0, true)


static func shadow(ci: CanvasItem, c: Vector2, w: float) -> void:
	ci.draw_colored_polygon(ellipse(c, w, w * 0.18), Color(INK, 0.16))


## Yumuşak, dalgalı tepe silueti (arka plan katmanları için).
static func hills(ci: CanvasItem, x0: float, x1: float, base: float, amp: float,
		freq: float, phase: float, col: Color, bottom := 760.0) -> void:
	var pts := PackedVector2Array()
	var x := x0
	while x <= x1:
		pts.append(Vector2(x, base - amp * (0.5 + 0.5 * sin(x * freq + phase))
			- amp * 0.3 * sin(x * freq * 2.3 + phase * 1.7)))
		x += 24.0
	pts.append(Vector2(x1, bottom))
	pts.append(Vector2(x0, bottom))
	blob(ci, pts, col)


# --- karakterler --------------------------------------------------------------

static func draw_nil(ci: CanvasItem, p: Vector2, t: float, walking: bool, facing: int) -> void:
	var bob := sin(t * 9.0) * 3.0 if walking else sin(t * 1.8) * 1.5
	var leg := sin(t * 9.0) * 5.0 if walking else 0.0
	var s := facing
	var coat := Color("6f8fd6")
	shadow(ci, p + Vector2(0, 2), 34)
	# bacaklar ve ayakkabılar
	rrect(ci, Rect2(p.x - 17, p.y - 36 + leg * 0.3, 12, 34 - leg * 0.3), Color("4b4766"), 5)
	rrect(ci, Rect2(p.x + 5, p.y - 36 - leg * 0.3, 12, 34 + leg * 0.3), Color("4b4766"), 5)
	rrect(ci, Rect2(p.x - 20, p.y - 6, 18, 8), Color("8a5a44"), 4)
	rrect(ci, Rect2(p.x + 2, p.y - 6, 18, 8), Color("8a5a44"), 4)
	# palto
	blob(ci, PackedVector2Array([
		Vector2(p.x - 20, p.y - 92 + bob), Vector2(p.x + 20, p.y - 92 + bob),
		Vector2(p.x + 30, p.y - 32 + bob), Vector2(p.x + 26, p.y - 28 + bob),
		Vector2(p.x - 26, p.y - 28 + bob), Vector2(p.x - 30, p.y - 32 + bob)]), coat, 2.5)
	dot(ci, Vector2(p.x + 4 * s, p.y - 72 + bob), 3, coat.darkened(0.3))
	dot(ci, Vector2(p.x + 4 * s, p.y - 56 + bob), 3, coat.darkened(0.3))
	# çanta askısı ve çanta
	ci.draw_line(Vector2(p.x - 18 * s, p.y - 90 + bob), Vector2(p.x + 20 * s, p.y - 50 + bob), Color("9a6b4a"), 5, true)
	var bag_x := p.x + 10 if s > 0 else p.x - 38
	rrect(ci, Rect2(bag_x, p.y - 60 + bob, 28, 24), Color("c08a5c"), 6, 2)
	rrect(ci, Rect2(bag_x, p.y - 60 + bob, 28, 9), Color("a8744a"), 4)
	# saç ve at kuyruğu
	dot(ci, Vector2(p.x, p.y - 116 + bob), 28, Color("6b4a3a"))
	dot(ci, Vector2(p.x - 25 * s, p.y - 108 + bob), 11, Color("6b4a3a"))
	# kafa
	dot(ci, Vector2(p.x + 3 * s, p.y - 112 + bob), 24, SKIN)
	ring(ci, Vector2(p.x + 3 * s, p.y - 112 + bob), 24, SKIN.darkened(0.2), 1.5)
	# postacı şapkası
	rrect(ci, Rect2(p.x - 24, p.y - 146 + bob, 48, 20), Color("d97b6c"), 9, 2)
	rrect(ci, Rect2(p.x - 8 + 14 * s, p.y - 130 + bob, 24, 6), Color("b8645a"), 3)
	dot(ci, Vector2(p.x, p.y - 138 + bob), 4, BUTTER)
	# yüz: gözlerde küçük parıltı, yanaklar, gülümseme
	for ex in [-6.0, 10.0]:
		var e := Vector2(p.x + ex + 6 * s, p.y - 113 + bob)
		dot(ci, e, 3.6, INK)
		dot(ci, e + Vector2(1.2, -1.2), 1.1, CREAM)
	dot(ci, Vector2(p.x - 12 + 6 * s, p.y - 104 + bob), 5, Color(ROSE, 0.55))
	dot(ci, Vector2(p.x + 16 + 6 * s, p.y - 104 + bob), 5, Color(ROSE, 0.55))
	ci.draw_arc(Vector2(p.x + 3 + 5 * s, p.y - 104 + bob), 6, 0.35, PI - 0.35, 10, INK, 2.2, true)


static func draw_piril(ci: CanvasItem, p: Vector2, t: float, strength := 1.0) -> void:
	var pulse := 0.92 + 0.08 * sin(t * 2.2)
	glow(ci, p, 52 * pulse * strength, Color("ffe9a8"), 0.9)
	var flap := sin(t * 10.0) * 3.0
	blob(ci, ellipse(p + Vector2(-9, -12), 8, 12 + flap, 20), Color(0.86, 0.94, 0.98, 0.8))
	blob(ci, ellipse(p + Vector2(9, -12), 8, 12 + flap, 20), Color(0.86, 0.94, 0.98, 0.8))
	dot(ci, p, 13, Color("f7d774"))
	dot(ci, p + Vector2(0, 2), 9, Color("fcefc0"))
	dot(ci, p + Vector2(-4, -2), 2.2, INK)
	dot(ci, p + Vector2(4, -2), 2.2, INK)
	ci.draw_line(p + Vector2(-3, -12), p + Vector2(-7, -22), INK, 1.5, true)
	ci.draw_line(p + Vector2(3, -12), p + Vector2(7, -22), INK, 1.5, true)


## Kasabalılar: ortak gövde, farklı şapka ve renkler.
static func draw_resident(ci: CanvasItem, kind: String, p: Vector2, t: float) -> void:
	var bob := sin(t * 1.6 + p.x) * 1.5
	var body: Color
	match kind:
		"simit": body = Color("f3ece0")
		"balik": body = Color("e8c46a")
		"fener": body = Color("8fb3c9")
		_: body = SAGE
	shadow(ci, p + Vector2(0, 2), 40)
	rrect(ci, Rect2(p.x - 18, p.y - 40, 14, 40), Color("5b5670"), 6)
	rrect(ci, Rect2(p.x + 4, p.y - 40, 14, 40), Color("5b5670"), 6)
	blob(ci, ellipse(Vector2(p.x, p.y - 78 + bob), 38, 46), body, 2.5)
	var head := Vector2(p.x, p.y - 146 + bob)
	match kind:
		"fener":
			dot(ci, head + Vector2(0, -4), 31, Color("8a5a5a"))
			dot(ci, head + Vector2(-24, 18), 13, Color("8a5a5a"))
			dot(ci, head + Vector2(24, 18), 13, Color("8a5a5a"))
	dot(ci, head, 28, SKIN)
	ring(ci, head, 28, SKIN.darkened(0.2), 1.5)
	dot(ci, head + Vector2(-10, -2), 3.4, INK)
	dot(ci, head + Vector2(10, -2), 3.4, INK)
	dot(ci, head + Vector2(-17, 8), 5, Color(ROSE, 0.5))
	dot(ci, head + Vector2(17, 8), 5, Color(ROSE, 0.5))
	match kind:
		"simit":
			# aşçı şapkası, bıyık, önlük
			dot(ci, head + Vector2(-14, -28), 16, CREAM)
			dot(ci, head + Vector2(14, -28), 16, CREAM)
			dot(ci, head + Vector2(0, -38), 19, CREAM)
			rrect(ci, Rect2(head.x - 24, head.y - 30, 48, 12), CREAM, 4)
			blob(ci, ellipse(head + Vector2(0, 10), 15, 5), Color("7a5240"))
			ci.draw_arc(head + Vector2(0, 14), 7, 0.3, PI - 0.3, 8, INK, 2.2, true)
			rrect(ci, Rect2(p.x - 22, p.y - 104 + bob, 44, 58), CREAM, 10)
		"balik":
			# sarı yağmurluk şapkası ve sakal
			blob(ci, ellipse(head + Vector2(0, -20), 38, 12), Color("e8c46a"), 2)
			dot(ci, head + Vector2(0, -26), 22, Color("e8c46a"))
			blob(ci, ellipse(head + Vector2(0, 18), 22, 14), Color("b9b2a6"))
			ci.draw_arc(head + Vector2(0, 10), 6, 0.3, PI - 0.3, 8, INK, 2.2, true)
		"fener":
			# yuvarlak gözlük ve atkı
			ring(ci, head + Vector2(-10, -2), 8, INK, 2)
			ring(ci, head + Vector2(10, -2), 8, INK, 2)
			ci.draw_arc(head + Vector2(0, 12), 7, 0.3, PI - 0.3, 8, INK, 2.2, true)
			rrect(ci, Rect2(p.x - 30, p.y - 120 + bob, 60, 14), ROSE, 7)


# --- nesneler -----------------------------------------------------------------

static func draw_icon(ci: CanvasItem, kind: String, c: Vector2, size: float) -> void:
	match kind:
		"simit":
			ci.draw_arc(c, size * 0.55, 0, TAU, 40, Color("d39a5c"), size * 0.42, true)
			ci.draw_arc(c + Vector2(0, -size * 0.06), size * 0.6, PI + 0.4, TAU - 0.4, 20, Color("e8b878"), size * 0.12, true)
			for i in 10:
				var a := TAU * i / 10.0 + 0.3
				dot(ci, c + Vector2(cos(a), sin(a)) * size * 0.55, size * 0.05, CREAM)
		"balik":
			blob(ci, PackedVector2Array([
				c + Vector2(size * 0.42, 0), c + Vector2(size * 0.85, -size * 0.34),
				c + Vector2(size * 0.85, size * 0.34)]), Color("6b98c4"))
			blob(ci, ellipse(c + Vector2(-size * 0.1, 0), size * 0.6, size * 0.38), DUSTY_BLUE)
			dot(ci, c + Vector2(-size * 0.4, -size * 0.08), size * 0.08, INK)
		"fener":
			var w := size * 0.32
			blob(ci, PackedVector2Array([
				c + Vector2(-w, size * 0.8), c + Vector2(w, size * 0.8),
				c + Vector2(w * 0.6, -size * 0.35), c + Vector2(-w * 0.6, -size * 0.35)]), CREAM)
			for k in 2:
				var y := size * (0.45 - k * 0.45)
				rrect(ci, Rect2(c.x - w * 0.85, c.y + y - size * 0.09, w * 1.7, size * 0.17), ROSE, 2)
			dot(ci, c + Vector2(0, -size * 0.55), size * 0.24, BUTTER)
			rrect(ci, Rect2(c.x - w * 0.8, c.y - size * 0.84, w * 1.6, size * 0.12), ROSE, 3)
		"zarf":
			rrect(ci, Rect2(c.x - size * 0.7, c.y - size * 0.45, size * 1.4, size * 0.9), CREAM, 4)
			ci.draw_polyline(PackedVector2Array([
				c + Vector2(-size * 0.66, -size * 0.4), c + Vector2(0, size * 0.1),
				c + Vector2(size * 0.66, -size * 0.4)]), Color("c9a86a"), 3, true)


## Rüya parçası: renkli, yavaşça süzülen bir baloncuk.
static func draw_fragment(ci: CanvasItem, kind: String, p: Vector2, t: float, col: Color) -> void:
	glow(ci, p, 70, col, 0.8)
	dot(ci, p, 44, Color(col.lightened(0.35), 0.85))
	ring(ci, p, 44, Color(CREAM, 0.9), 3)
	ci.draw_arc(p, 34, PI + 0.5, PI + 1.4, 10, Color(CREAM, 0.8), 4, true)
	draw_icon(ci, kind, p, 34)
	for k in 3:
		var a := t * 0.9 + k * TAU / 3.0
		dot(ci, p + Vector2(cos(a), sin(a)) * 58, 2.5, Color(CREAM, 0.7))


static func draw_simit(ci: CanvasItem, c: Vector2, r: float) -> void:
	glow(ci, c, r * 2.0, BUTTER, 0.8)
	draw_icon(ci, "simit", c, r)


static func draw_cloud(ci: CanvasItem, c: Vector2, w: float, col: Color) -> void:
	var shade := col.darkened(0.08)
	blob(ci, ellipse(c + Vector2(0, 8), w * 0.62, w * 0.2), shade)
	dot(ci, c + Vector2(-w * 0.32, 0), w * 0.24, col)
	dot(ci, c + Vector2(w * 0.3, 2), w * 0.22, col)
	dot(ci, c + Vector2(-w * 0.02, -w * 0.12), w * 0.3, col)
	blob(ci, ellipse(c + Vector2(0, 4), w * 0.6, w * 0.16), col)
	dot(ci, c + Vector2(-w * 0.1, -w * 0.24), w * 0.1, Color(1, 1, 1, 0.35))


static func draw_house(ci: CanvasItem, x: float, ground: float, w: float, h: float,
		body: Color, roof: Color, kind: String, night: bool) -> void:
	shadow(ci, Vector2(x, ground + 4), w * 0.62)
	# baca
	rrect(ci, Rect2(x + w * 0.2, ground - h - w * 0.38, 24, w * 0.3), roof.darkened(0.15), 4)
	rrect(ci, Rect2(x - w / 2, ground - h, w, h + 4), body, 10, 2)
	blob(ci, PackedVector2Array([
		Vector2(x - w / 2 - 22, ground - h + 6), Vector2(x - w / 2 - 14, ground - h - 6),
		Vector2(x - 10, ground - h - w * 0.44), Vector2(x + 10, ground - h - w * 0.44),
		Vector2(x + w / 2 + 14, ground - h - 6), Vector2(x + w / 2 + 22, ground - h + 6)]), roof, 2.5)
	var win := Color("f7dc8f") if night else Color("cfe6f2")
	for wx in [x - w * 0.38, x + w * 0.14]:
		var r := Rect2(wx, ground - h * 0.8, w * 0.24, h * 0.26)
		if night:
			glow(ci, r.get_center(), w * 0.26, Color("ffd98a"), 0.6)
		rrect(ci, r, win, 6, 3, body.darkened(0.3))
		ci.draw_line(Vector2(r.get_center().x, r.position.y + 3), Vector2(r.get_center().x, r.end.y - 3), body.darkened(0.3), 2, true)
	var door := Rect2(x - w * 0.12, ground - h * 0.44, w * 0.24, h * 0.44)
	rrect(ci, door, Color("8a6048"), 10)
	dot(ci, door.position + Vector2(door.size.x * 0.75, door.size.y * 0.55), 3, BUTTER)
	# tabela
	dot(ci, Vector2(x, ground - h - w * 0.17), 25, CREAM)
	ring(ci, Vector2(x, ground - h - w * 0.17), 25, roof.darkened(0.2), 2.5)
	draw_icon(ci, kind, Vector2(x, ground - h - w * 0.17), 28)


static func draw_lamp(ci: CanvasItem, x: float, ground: float, night: bool) -> void:
	if night:
		glow(ci, Vector2(x, ground - 150), 110, Color("ffdc9a"), 0.7)
	rrect(ci, Rect2(x - 4, ground - 140, 8, 140), Color("5b5670"), 3)
	rrect(ci, Rect2(x - 14, ground - 168, 28, 30), Color("f7dc8f") if night else Color("e8e2d0"), 8, 3, Color("5b5670"))


static func draw_mill(ci: CanvasItem, base: Vector2, broken: bool, spin: float) -> void:
	blob(ci, PackedVector2Array([
		base + Vector2(-40, 0), base + Vector2(40, 0),
		base + Vector2(24, -150), base + Vector2(-24, -150)]), Color("e3d5bf"), 2)
	rrect(ci, Rect2(base.x - 10, base.y - 36, 20, 36), Color("8a6048"), 8)
	blob(ci, PackedVector2Array([
		base + Vector2(-34, -148), base + Vector2(34, -148), base + Vector2(0, -192)]), Color("b07a72"), 2)
	var hub := base + Vector2(0, -150)
	for i in 4:
		var a := spin + TAU * i / 4.0
		if broken and i == 1:
			a += 0.9
		var blade := 60.0 if broken and i == 3 else 110.0
		var tip := hub + Vector2(cos(a), sin(a)) * blade
		ci.draw_line(hub, tip, Color("efe6d6"), 14, true)
		ci.draw_line(hub, tip, Color("d6c8b0"), 3, true)
	dot(ci, hub, 10, Color("8a6048"))


static func draw_star(ci: CanvasItem, c: Vector2, r: float, col := BUTTER) -> void:
	var pts := PackedVector2Array()
	for k in 10:
		var a := -PI / 2 + TAU * k / 10.0
		pts.append(c + Vector2(cos(a), sin(a)) * (r if k % 2 == 0 else r * 0.48))
	blob(ci, pts, col, 2)


static func draw_whale(ci: CanvasItem, c: Vector2, t: float, singing: bool) -> void:
	var bob := sin(t * 1.2) * 6.0
	var body := Color("7f9fc4")
	c += Vector2(0, bob)
	blob(ci, PackedVector2Array([
		c + Vector2(150, -10), c + Vector2(230, -70), c + Vector2(240, -20), c + Vector2(225, 25)]), body.darkened(0.08), 2)
	blob(ci, ellipse(c, 170, 95, 48), body, 3)
	blob(ci, ellipse(c + Vector2(-10, 40), 140, 45, 40), Color("dfe7ef"))
	for i in 5:
		ci.draw_line(c + Vector2(-90 + i * 30, 12), c + Vector2(-80 + i * 30, 70), Color("c6d2de"), 2, true)
	dot(ci, c + Vector2(-95, -20), 9, INK)
	dot(ci, c + Vector2(-92, -23), 3, CREAM)
	dot(ci, c + Vector2(-110, 6), 10, Color(ROSE, 0.5))
	if singing:
		blob(ci, ellipse(c + Vector2(-145, 18), 14, 10 + 4 * sin(t * 6)), Color("4d3f5e"))
	else:
		ci.draw_arc(c + Vector2(-140, 12), 14, 0.2, PI - 0.6, 10, INK, 3, true)
	# fıskiye
	for k in 3:
		var y := c.y - 110 - k * 18 - fmod(t * 20.0, 18.0)
		dot(ci, Vector2(c.x - 20 + k * 6, y), 6 - k, Color("cfe3f0", 0.8))


static func draw_shell(ci: CanvasItem, c: Vector2, col: Color, lit: float) -> void:
	if lit > 0.0:
		glow(ci, c, 110, col.lightened(0.3), lit)
	shadow(ci, c + Vector2(0, 44), 60)
	var pts := PackedVector2Array()
	for i in 21:
		var a := PI + PI * i / 20.0
		pts.append(c + Vector2(cos(a) * 62, sin(a) * 56))
	pts.append(c + Vector2(26, 40))
	pts.append(c + Vector2(-26, 40))
	blob(ci, pts, col.lightened(lit * 0.25), 3)
	for k in 5:
		var a := PI + PI * (k + 1) / 6.0
		ci.draw_line(c + Vector2(0, 36), c + Vector2(cos(a) * 54, sin(a) * 48), col.darkened(0.2), 3, true)


static func draw_mirror(ci: CanvasItem, c: Vector2, angle: float) -> void:
	dot(ci, c, 46, Color(CREAM, 0.12))
	ring(ci, c, 46, Color(CREAM, 0.35), 2)
	var d := Vector2.from_angle(angle) * 48
	var n := Vector2.from_angle(angle + PI / 2) * 6
	blob(ci, PackedVector2Array([c - d - n, c + d - n, c + d + n, c - d + n]), Color("c7d9e8"), 2.5)
	ci.draw_line(c - d * 0.8 - n * 0.3, c + d * 0.8 - n * 0.3, Color(1, 1, 1, 0.7), 2, true)


static func draw_lighthouse(ci: CanvasItem, base: Vector2, lamp_on: bool, t: float) -> void:
	blob(ci, PackedVector2Array([
		base + Vector2(-50, 0), base + Vector2(50, 0),
		base + Vector2(30, -260), base + Vector2(-30, -260)]), CREAM, 2.5)
	for k in 3:
		var y := -40 - k * 80
		var w0 := 50 - (y * -1) / 260.0 * 20
		rrect(ci, Rect2(base.x - w0, base.y + y - 26, w0 * 2, 26), ROSE, 4)
	rrect(ci, Rect2(base.x - 38, base.y - 300, 76, 44), Color("5b5670"), 10)
	var lamp := Color("ffe39a") if lamp_on else Color("b9b0a0")
	if lamp_on:
		glow(ci, base + Vector2(0, -278), 90 + sin(t * 2) * 6, Color("ffe39a"), 0.9)
	rrect(ci, Rect2(base.x - 26, base.y - 296, 52, 36), lamp, 8)
	blob(ci, PackedVector2Array([
		base + Vector2(-44, -300), base + Vector2(44, -300), base + Vector2(0, -336)]), ROSE, 2)


static func draw_paper_boat(ci: CanvasItem, c: Vector2, t: float, lit: bool) -> void:
	c += Vector2(0, sin(t * 1.4) * 4)
	if lit:
		glow(ci, c, 90, BUTTER, 0.9)
	blob(ci, PackedVector2Array([c + Vector2(-50, -6), c + Vector2(50, -6),
		c + Vector2(34, 20), c + Vector2(-34, 20)]), Color("f3ede2"), 2)
	blob(ci, PackedVector2Array([c + Vector2(-26, -6), c + Vector2(0, -52),
		c + Vector2(26, -6)]), Color("e9e1d3"), 2)
