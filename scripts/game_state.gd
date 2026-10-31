extends Node
## Oyunun kalıcı durumu: toplanan rüyalar, teslimler, değirmen ilerlemesi.

const RESIDENTS := {
	"simit": {"name": "Simitçi Halim", "color": Art.APRICOT},
	"balik": {"name": "Balıkçı Ruhi", "color": Art.DUSTY_BLUE},
	"fener": {"name": "Fenerci Leyla", "color": Art.ROSE},
}
const MILL_PARTS := 5
## Rüyalar bu sırayla oynanır; her rüya bitince sıradakine geçilir.
const DREAMS := ["dream_clouds", "dream_whale", "dream_light"]

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


## Bir rüya bitince sıradaki rüyaya, hepsi bitince sabaha geçer.
func next_after(dream: String) -> String:
	var i := DREAMS.find(dream)
	return DREAMS[i + 1] if i >= 0 and i + 1 < DREAMS.size() else "morning"


func go(scene: String) -> void:
	get_tree().change_scene_to_file("res://scenes/%s.tscn" % scene)
