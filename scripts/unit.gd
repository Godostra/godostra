extends Spatial

var unit_type = 0
var selectable = false
var aab
var z = 0

func _ready():
	aab = get_node("Scene Root/Empty").get_children()[0].get_aabb()

	if selectable and unit_type != 1:
		var sel = $selection.get_mesh().duplicate(true)
		var mat = SpatialMaterial.new()
		var tex = ImageTexture.new()
		tex.load("res://misc/water_simple.png")
		mat.albedo_texture = tex
		mat.flags_transparent = true
		sel.set_material(mat)
		$selection.set_mesh(sel)
		$selection.translate(Vector3(0,abs(aab.position.z/2.0),0)-Vector3(0,2,0))
		$selection.get_mesh().set_size(Vector3(aab.size.x,aab.size.z,aab.size.y))
		
		var col = $collision.get_shape().duplicate(true)
		col.set_extents(Vector3(aab.size.x/2,aab.size.z/2,aab.size.y/2))
		$collision.translate(Vector3(0,abs(aab.position.z/2),0)-Vector3(0,2,0))
		$collision.set_shape(col)
		
		
	elif unit_type != 1:
		$selection.free()
		$collision.free()

func _input_event(camera, event, pos, normal, shape):
	if event is InputEventMouseButton:
		print(z)
		if selectable and event.button_index == 1 and event.is_pressed():
			get_node("/root/game").clear_selection()
			$selection.set_visible(true)