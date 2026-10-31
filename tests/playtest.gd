extends Node
## Otomatik oynanış testi: tüm akışı oynar ve ekran görüntüsü alır.
## Çalıştırma: godot --path . res://tests/playtest.tscn

var out := "user://shots"
var n := 0


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(out)
	var d := Node.new()
	d.set_script(get_script())
	d.set_meta("driver", true)
	if not has_meta("driver"):
		get_tree().root.add_child.call_deferred(d)
		return
	_run.call_deferred()


func wait(s: float) -> void:
	await get_tree().create_timer(s).timeout


func shot(name: String) -> void:
	await RenderingServer.frame_post_draw
	n += 1
	var img := get_viewport().get_texture().get_image()
	img.save_png("%s/%02d_%s.png" % [out, n, name])
	print("SHOT ", name)


func tap(p: Vector2) -> void:
	var m := InputEventMouseMotion.new()
	m.position = p
	m.global_position = p
	Input.parse_input_event(m)
	for pressed in [true, false]:
		var b := InputEventMouseButton.new()
		b.button_index = MOUSE_BUTTON_LEFT
		b.pressed = pressed
		b.position = p
		b.global_position = p
		Input.parse_input_event(b)
		await get_tree().process_frame


func drag(a: Vector2, b: Vector2) -> void:
	var m := InputEventMouseMotion.new()
	m.position = a
	Input.parse_input_event(m)
	var e := InputEventMouseButton.new()
	e.button_index = MOUSE_BUTTON_LEFT
	e.pressed = true
	e.position = a
	Input.parse_input_event(e)
	await get_tree().process_frame
	for i in 10:
		var mm := InputEventMouseMotion.new()
		mm.position = a.lerp(b, (i + 1) / 10.0)
		mm.button_mask = MOUSE_BUTTON_MASK_LEFT
		Input.parse_input_event(mm)
		await get_tree().process_frame
	var r := InputEventMouseButton.new()
	r.button_index = MOUSE_BUTTON_LEFT
	r.pressed = false
	r.position = b
	Input.parse_input_event(r)
	await get_tree().process_frame


func press_button() -> void:
	var btns := get_tree().current_scene.find_children("*", "Button", true, false)
	assert(btns.size() > 0, "buton yok")
	btns[-1].pressed.emit()
	await wait(0.6)


func scene_name() -> String:
	return get_tree().current_scene.name


func _run() -> void:
	get_tree().change_scene_to_file("res://scenes/title.tscn")
	await wait(1.0)
	await shot("title")
	await press_button()
	print("scene: ", scene_name())
	await wait(0.5)
	await shot("night_start")
	var took_mid := false
	for i in 40:
		await tap(Vector2(1250, 400))
		await wait(0.3)
		if not took_mid and GameState.collected.size() == 1:
			took_mid = true
			await shot("night_first_pickup")
		if GameState.collected.size() == 3:
			break
	print("collected: ", GameState.collected)
	await wait(0.5)
	await shot("night_done")
	await press_button()
	print("scene: ", scene_name())
	await shot("envelopes")
	# yanlış zarf: fener parçası (400,260) -> balık zarfı (330,520)
	await drag(Vector2(400, 260), Vector2(330, 520))
	await wait(0.4)
	await shot("envelope_wrong")
	await drag(Vector2(400, 260), Vector2(950, 520))
	await drag(Vector2(640, 260), Vector2(640, 520))
	await wait(0.2)
	await shot("envelope_two")
	await drag(Vector2(880, 260), Vector2(330, 520))
	await wait(0.5)
	print("delivered: ", GameState.delivered)
	await shot("envelopes_done")
	await press_button()
	print("scene: ", scene_name())
	await shot("dream_start")
	var s = get_tree().current_scene
	await tap(Vector2(1150, 230))  # yanlış bulut: ipucu
	await wait(0.2)
	for i in range(1, 4):
		await tap(s.clouds[i])
		await wait(0.7)
	await shot("dream_grumpy")
	for k in 3:
		await tap(s.clouds[4])
		await wait(0.2)
	await shot("dream_grumpy_happy")
	for i in range(4, 7):
		await tap(s.clouds[i])
		await wait(0.7)
	print("stars: ", GameState.stars, " current: ", s.current)
	await shot("dream_done")
	await press_button()
	print("scene: ", scene_name())
	await wait(0.4)
	await shot("morning_1")
	for i in 4:
		await tap(Vector2(640, 400))
		await wait(0.8)
		await shot("morning_%d" % (i + 2))
	print("mill: ", GameState.mill_progress)
	print("PLAYTEST OK")
	get_tree().quit()
