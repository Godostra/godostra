extends Camera

var direction = Vector3(0.0, 0.0, 0.0)
var win_size
var mouse_pos = Vector2(0,0)
var camera_pos
const offset = 100
const speed = 15

var margins = Vector2(0,0)

func _ready():
	get_tree().get_root().connect("size_changed", self, "window_resized")
	window_resized()
	get_viewport().warp_mouse(win_size/Vector2(2,2))
	set_process(true)

func _process(delta):
	mouse_pos = get_viewport().get_mouse_position()
	camera_pos = get_translation()
	
	if mouse_pos.x < offset and camera_pos.x > -margins.x:
		direction = Vector3(-speed * delta,0,0)
		update_camera()
	
	elif mouse_pos.x > win_size.x-offset and camera_pos.x < margins.x:
		direction = Vector3(speed * delta,0,0)
		update_camera()
	
	if mouse_pos.y < offset  and camera_pos.z > -margins.y+margins.y/8:
		direction = Vector3(0,speed * delta,-speed * delta)
		update_camera()
	
	elif mouse_pos.y > win_size.y-offset and camera_pos.z < margins.y:
		direction = Vector3(0,-speed * delta,speed * delta)
		update_camera()

func update_camera():
	translate(direction)

func window_resized():
	win_size = OS.get_window_size()