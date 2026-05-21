extends Node

# patch_06c: runtime guard that keeps legacy UI stacks invisible.
# Canonical UI nodes are FinalGameHUD3D and FinalUIPanelRoot3D only.

const CANONICAL_NAMES: Array[String] = [
	"FinalGameHUD3D",
	"FinalUIPanelRoot3D",
	"GameHUD3D",
	"UIPanelRoot3D",
]

const LEGACY_EXACT_NAMES: Array[String] = [
	"UI",
	"Root",
	"StatusLabel",
	"HelpLabel",
	"PanelRoot",
	"PanelText",
	"HUD",
	"HUD3D",
	"SimpleHUD3D",
	"SkillLoadoutPanel",
	"SkillLoadoutPanel3D",
	"FinalUIPanelRoot",
]

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	call_deferred("enforce")

func _process(_delta: float) -> void:
	enforce()

func enforce() -> void:
	var root: Node = get_tree().root
	if root == null:
		return
	_hide_legacy(root)

func _hide_legacy(node: Node) -> void:
	if node == null:
		return
	var node_name: String = str(node.name)
	if CANONICAL_NAMES.has(node_name):
		return
	if LEGACY_EXACT_NAMES.has(node_name):
		if node is CanvasItem:
			(node as CanvasItem).visible = false
		if node is Control:
			(node as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child: Node in node.get_children():
		_hide_legacy(child)
