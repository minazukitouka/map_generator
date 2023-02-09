extends Camera3D

var original_x := 0.0
var original_rotation := 0.0

func _process(delta: float) -> void:
	var velocity := Vector3(
		Input.get_axis('ui_left', 'ui_right'),
		0,
		Input.get_axis('ui_up', 'ui_down')
	)
	velocity = velocity.rotated(Vector3.UP, rotation.y)
	position += velocity * delta * 20

func _unhandled_input(event: InputEvent) -> void:
	var current_x = get_viewport().get_mouse_position().x
	if Input.is_action_just_pressed('rotate_camera'):
		original_x = current_x
		original_rotation = rotation.y
	if Input.is_action_pressed('rotate_camera'):
		rotation.y = original_rotation + (current_x - original_x) * 0.01
