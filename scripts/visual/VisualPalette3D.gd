extends RefCounted

static func material(name: String, color: Color, emission: bool = false, emission_energy: float = 0.0, alpha: float = 1.0) -> StandardMaterial3D:
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.resource_name = name
	var c: Color = color
	c.a = alpha
	mat.albedo_color = c
	mat.roughness = 0.82
	mat.metallic = 0.0
	if alpha < 1.0:
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_ALWAYS
	if emission:
		mat.emission_enabled = true
		mat.emission = color
		mat.emission_energy_multiplier = emission_energy
	return mat


static func floor_mat() -> StandardMaterial3D:
	return material("Ash Floor", Color(0.115, 0.115, 0.125, 1.0))


static func grid_mat() -> StandardMaterial3D:
	return material("Dim Grid", Color(0.24, 0.22, 0.20, 1.0), false, 0.0, 0.72)


static func wall_mat() -> StandardMaterial3D:
	return material("Soot Wall", Color(0.16, 0.15, 0.15, 1.0))


static func brass_mat() -> StandardMaterial3D:
	return material("Dull Brass", Color(0.55, 0.42, 0.20, 1.0))


static func ember_mat(alpha: float = 1.0) -> StandardMaterial3D:
	return material("Ember", Color(1.0, 0.34, 0.11, alpha), true, 1.7, alpha)


static func blue_mat(alpha: float = 1.0) -> StandardMaterial3D:
	return material("Rift Blue", Color(0.24, 0.50, 1.0, alpha), true, 1.25, alpha)


static func green_mat(alpha: float = 1.0) -> StandardMaterial3D:
	return material("Gem Green", Color(0.24, 1.0, 0.48, alpha), true, 1.0, alpha)


static func violet_mat(alpha: float = 1.0) -> StandardMaterial3D:
	return material("Void Violet", Color(0.62, 0.26, 1.0, alpha), true, 1.2, alpha)


static func white_mat(alpha: float = 1.0) -> StandardMaterial3D:
	return material("White", Color(0.92, 0.92, 0.88, alpha), false, 0.0, alpha)


static func rarity_mat(rarity: String, alpha: float = 1.0) -> StandardMaterial3D:
	match rarity.strip_edges().to_lower():
		"normal":
			return material("Rarity Normal", Color(0.92, 0.92, 0.88, alpha), false, 0.0, alpha)
		"magic":
			return material("Rarity Magic", Color(0.34, 0.54, 1.0, alpha), true, 0.75, alpha)
		"rare":
			return material("Rarity Rare", Color(1.0, 0.82, 0.22, alpha), true, 0.8, alpha)
		"unique":
			return material("Rarity Unique", Color(1.0, 0.43, 0.10, alpha), true, 1.0, alpha)
		_:
			return white_mat(alpha)
