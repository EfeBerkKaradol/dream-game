extends Node
## Oyunun kalıcı durumu: toplanan rüyalar, teslimler, değirmen ilerlemesi.

const RESIDENTS := {
	"simit": {"name": "Simitçi Halim", "color": Color("e8a94d")},
	"balik": {"name": "Balıkçı Ruhi", "color": Color("4da3e8")},
	"fener": {"name": "Fenerci Leyla", "color": Color("f06b6b")},
}
const MILL_PARTS := 5

var collected: Array[String] = []
var delivered: Array[String] = []
var mill_progress := 0
var dream_cards: Array[String] = []
var stars := 0


func reset() -> void:
	collected.clear()
	delivered.clear()
	dream_cards.clear()
	mill_progress = 0
	stars = 0


func go(scene: String) -> void:
	get_tree().change_scene_to_file("res://scenes/%s.tscn" % scene)
