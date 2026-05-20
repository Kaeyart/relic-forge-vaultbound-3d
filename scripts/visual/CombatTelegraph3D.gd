extends Node3D
class_name RVCombatTelegraph3D

const VisualPaletteScript := preload("res://scripts/visual/VisualPalette3D.gd")
const PrimitiveKitScript := preload("res://scripts/visual/PrimitiveKit3D.gd")

var duration: float = 0.75
var elapsed: float = 0.0
var disc: MeshInstance3D = null


func setup_circle(radius: float, seconds: float = 0.75, danger_color: Color = Color(1.0, 0.14, 0.06, 1.0)) -> void:
	duration = max(0.05, seconds)
	elapsed = 0.0
	_clear_children(self)
	disc = PrimitiveKitScript.ground_disc("TelegraphCircle", radius, Vector3.ZERO, VisualPaletteScript.material("Telegraph", danger_color, true, 0.85, 0.32))
	add_child(disc)


func setup_line(length: float, width: float, seconds: float = 0.75, danger_color: Color = Color(1.0, 0.14, 0.06, 1.0)) -> void:
	duration = max(0.05, seconds)
	elapsed = 0.0
	_clear_children(self)
	disc = PrimitiveKitScript.box("TelegraphLine", Vector3(width, 0.035, length), Vector3(0.0, 0.02, -length * 0.5), VisualPaletteScript.material("Telegraph Line", danger_color, true, 0.85, 0.32))
	add_child(disc)


func _process(delta: float) -> void:
	elapsed += delta
	var ratio: float = clampf(elapsed / duration, 0.0, 1.0)
	if disc != null:
		var s: float = 0.85 + ratio * 0.25
		disc.scale = Vector3(s, 1.0, s)
	if elapsed >= duration:
		queue_free()


func _clear_children(node: Node) -> void:
	for child: Node in node.get_children():
		node.remove_child(child)
		child.queue_free()
