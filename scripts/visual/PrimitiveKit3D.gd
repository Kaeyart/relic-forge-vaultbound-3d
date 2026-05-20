extends RefCounted

static func box(name: String, size: Vector3, position: Vector3, mat: Material = null) -> MeshInstance3D:
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = size

	var node: MeshInstance3D = MeshInstance3D.new()
	node.name = name
	node.mesh = mesh
	node.position = position
	if mat != null:
		node.set_surface_override_material(0, mat)
	return node


static func cylinder(name: String, radius: float, height: float, position: Vector3, mat: Material = null, segments: int = 32) -> MeshInstance3D:
	var mesh: CylinderMesh = CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = max(8, segments)

	var node: MeshInstance3D = MeshInstance3D.new()
	node.name = name
	node.mesh = mesh
	node.position = position
	if mat != null:
		node.set_surface_override_material(0, mat)
	return node


static func sphere(name: String, radius: float, position: Vector3, mat: Material = null) -> MeshInstance3D:
	var mesh: SphereMesh = SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 24
	mesh.rings = 12

	var node: MeshInstance3D = MeshInstance3D.new()
	node.name = name
	node.mesh = mesh
	node.position = position
	if mat != null:
		node.set_surface_override_material(0, mat)
	return node


static func ground_disc(name: String, radius: float, position: Vector3, mat: Material = null) -> MeshInstance3D:
	return cylinder(name, radius, 0.035, position + Vector3(0.0, 0.018, 0.0), mat, 48)


static func label_3d(name: String, text: String, position: Vector3, color: Color = Color(1, 1, 1, 1)) -> Label3D:
	var label: Label3D = Label3D.new()
	label.name = name
	label.text = text
	label.position = position
	label.font_size = 28
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.modulate = color
	return label


static func add_light(name: String, position: Vector3, color: Color, energy: float, range: float) -> OmniLight3D:
	var light: OmniLight3D = OmniLight3D.new()
	light.name = name
	light.position = position
	light.light_color = color
	light.light_energy = energy
	light.omni_range = range
	return light
