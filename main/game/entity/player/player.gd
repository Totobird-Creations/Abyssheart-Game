extends KinematicBody
class_name PlayerEntity



export(bool)  var controlling       : bool    = false
export(float) var gravity           : float   = 75.0
export(float) var acceleration      : float   = 100.0
export(float) var friction          : float   = 75.0
export(float) var max_speed         : float   = 1.0
export(float) var jump_strength     : float   = 25.0
export(float) var mouse_sensitivity : float   = 0.002

var               velocity          : Vector3 = Vector3.ZERO



func _enter_tree() -> void:
	if (controlling):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _exit_tree() -> void:
	if (controlling):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)



func _ready() -> void:
	$camera.current                 = controlling
	$camera/viewer.requires_visuals = controlling



func _physics_process(delta : float) -> void:
	velocity = velocity.move_toward(Vector3(0.0, velocity.y, 0.0), friction * delta)

	var input : Vector3 = Vector3.ZERO
	if (controlling):
		input += (Input.get_action_strength('player_move_forward') - Input.get_action_strength('player_move_backward')) * transform.basis.z
		input += (Input.get_action_strength('player_move_left')    - Input.get_action_strength('player_move_right'))    * transform.basis.x
		input = input.normalized()

		if (Input.is_action_pressed('player_move_jump') and is_on_floor()):
			velocity.y = jump_strength

	velocity   -= input * acceleration * delta
	velocity.y -= gravity * delta

	var next_velocity : Vector3 = move_and_slide(velocity, Vector3.UP, true)

	# TODO : Push handler

	velocity = next_velocity



func _input(event : InputEvent) -> void:
	if (controlling):
		if (event is InputEventMouseMotion):
			$camera.rotation.x  = clamp($camera.rotation.x - (event.relative.y * mouse_sensitivity), -PI / 2.0, PI / 2.0)
			rotation.y         -= event.relative.x * mouse_sensitivity
		elif (event is InputEventKey and event.scancode == KEY_ESCAPE):
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _notification(what : int) -> void:
	if (controlling):
		if (what == NOTIFICATION_WM_MOUSE_ENTER):
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
