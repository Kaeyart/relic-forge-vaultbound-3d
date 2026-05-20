extends Node3D
class_name RVDropBeam3D

const VisualPaletteScript := preload("res://scripts/visual/VisualPalette3D.gd")
const PrimitiveKitScript := preload("res://scripts/visual/PrimitiveKit3D.gd")

var rarity: String = "normal"
var pulse_speed: float = 2.8
var base_height: float = 2.5
var beam: MeshInstance3D = null
var disc: MeshInstance3D = null
var label: Label3D = null


func setup(display_name: String, item_rarity: String) -> void:
	rarity = item_rarity
	_clear_children(self)

	disc = PrimitiveKitScript.ground_disc("DropRing", 0.46, Vector3.ZERO, VisualPaletteScript.rarity_mat(rarity, 0.32))
	add_child(disc)

	beam = PrimitiveKitScript.cylinder("DropBeam", 0.08, base_height, Vector3(0.0, base_height * 0.5, 0.0), VisualPaletteScript.rarity_mat(rarity, 0.45), 24)
	add_child(beam)

	label = PrimitiveKitScript.label_3d("DropLabel", display_name, Vector3(0.0, base_height + 0.28, 0.0), Color(1, 1, 1, 1))
	add_child(label)


func _process(_delta: float) -> void:
	var t: float = float(Time.get_ticks_msec()) / 1000.0
	var pulse: float = 0.75 + sin(t * pulse_speed) * 0.18
	if beam != null:
		beam.scale = Vector3(pulse, 1.0, pulse)
	if disc != null:
		disc.scale = Vector3(1.0 + pulse * 0.12, 1.0, 1.0 + pulse * 0.12)


func _clear_children(node: Node) -> void:
	for child: Node in node.get_children():
		node.remove_child(child)
		child.queue_free()
