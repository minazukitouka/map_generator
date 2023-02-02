extends Node2D

@export var scroll_speed := 500
@onready var screen_width := ProjectSettings.get_setting('display/window/size/viewport_width')
@onready var screen_height := ProjectSettings.get_setting('display/window/size/viewport_height')
@onready var camera_2d: Camera2D = $Camera2D

func _process(delta: float) -> void:
	camera_2d.position.x += Input.get_axis("ui_left", "ui_right") * delta * scroll_speed
	camera_2d.position.y += Input.get_axis("ui_up", "ui_down") * delta * scroll_speed

	var mouse_position = get_viewport().get_mouse_position()

	if mouse_position.x <= 10:
		camera_2d.position.x += delta * -scroll_speed
	if mouse_position.x >= screen_width - 10:
		camera_2d.position.x += delta * scroll_speed
	if mouse_position.y <= 10:
		camera_2d.position.y += delta * -scroll_speed
	if mouse_position.y >= screen_height - 10:
		camera_2d.position.y += delta * scroll_speed

	camera_2d.position.x = clamp(
		camera_2d.position.x,
		camera_2d.limit_left + screen_width / 2,
		camera_2d.limit_right - screen_width / 2
	)
	camera_2d.position.y = clamp(
		camera_2d.position.y,
		camera_2d.limit_top + screen_height / 2,
		camera_2d.limit_bottom - screen_height / 2
	)

func set_camera_limit(limit: Rect2) -> void:
	camera_2d.limit_top = limit.position.y
	camera_2d.limit_bottom = limit.end.y
	camera_2d.limit_left = limit.position.x
	camera_2d.limit_right = limit.end.x
