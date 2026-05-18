class_name RVVaultHub3D
extends Node3D

@onready var map_device_marker: Node3D = $MapDeviceMarker
@onready var stash_marker: Node3D = $StashMarker
@onready var forge_marker: Node3D = $ForgeMarker

func update_focus(state: RVGameState3D) -> void:
	if state == null:
		return
	var best_name := ""
	var best_dist := 9999.0
	for marker: Node3D in [map_device_marker, stash_marker, forge_marker]:
		if marker == null:
			continue
		var d := marker.global_position.distance_to(state.player_pos)
		if d < best_dist:
			best_dist = d
			best_name = marker.name
	if best_dist <= 2.2:
		state.prompt_text = "E: interact with " + best_name.replace("Marker", "")
	else:
		state.prompt_text = "T: start test map · E near stations"

func interact_primary(state: RVGameState3D) -> Dictionary:
	if state == null:
		return {}
	if map_device_marker != null and map_device_marker.global_position.distance_to(state.player_pos) <= 2.2:
		return {"kind": "map", "name": "3D Test Vault", "tier": 1, "map_level": max(1, state.level)}
	if stash_marker != null and stash_marker.global_position.distance_to(state.player_pos) <= 2.2:
		state.add_notice("Stash UI migration pending")
		return {}
	if forge_marker != null and forge_marker.global_position.distance_to(state.player_pos) <= 2.2:
		state.add_notice("Forge UI migration pending")
		return {}
	return {}
