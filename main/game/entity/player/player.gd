extends Entity
class_name PlayerEntity



export(bool)  var controlling           : bool  = false
export(float) var mouse_sensitivity     : float = 0.002

export(float) var max_floor_angle       : float = (PI / 2.0) * 0.625
export(float) var gravity               : float = 40.0
export(float) var jump_strength         : float = 10.0
export(float) var walk_speed            : float = 10.0
export(float) var sprint_speed          : float = 16.0
export(float) var acceleration          : float = 8.0
export(float) var deceleration          : float = 10.0
export(float) var air_control           : float = 0.5

export(float) var max_health            : float = 100.0
export(float) var fall_damage_threshold : float = 25.0
export(float) var fall_damage_power     : float = 2.0
export(float) var fall_damage_scale     : float = 10.0

export(float) var max_stamina           : float = 100.0
export(float) var stamina_cooldown      : float = 1.0
export(float) var stamina_regen         : float = 10.0
export(float) var sprint_stamina        : float = 10.0
export(float) var jump_stamina          : float = 15.0
export(float) var exhaust_modifier      : float = 0.375

export(float) var fov_normal            : float = 70.0
export(float) var fov_zoom              : float = 20.0

var health          : float   = max_health   setget set_health
var stamina         : float   = max_stamina  setget set_stamina
var stamina_timer   : float   = 0.0
var stamina_exhaust : bool    = false

var velocity        : Vector3 = Vector3.ZERO
var snap            : Vector3 = Vector3.ZERO





func _ready() -> void:
	if (controlling):
		$pivot/camera/camera.make_current()



func _physics_process(delta : float) -> void:
	# Modifier
	var modifier : float = 1.0
	if (stamina_exhaust):
		modifier = exhaust_modifier

	# Input
	var input  : Vector2 = Vector2.ZERO
	var jump   : bool    = false
	var sprint : bool    = false
	if (controlling):
		input = Vector2(
			Input.get_action_strength("player_move_forward") - Input.get_action_strength("player_move_backward"),
			Input.get_action_strength("player_move_right")   - Input.get_action_strength("player_move_left")
		)
		jump   = Input.is_action_just_pressed("player_move_jump")
		sprint = Input.is_action_pressed("player_move_sprint")
		var world : Spatial = get_parent().get_parent();
		if (Input.is_action_just_pressed("debug_zoom") && world.render_mode == world.RenderMode.Debug):
			$pivot/camera/camera.fov = fov_zoom
		if (Input.is_action_just_released("debug_zoom")):
			$pivot/camera/camera.fov = fov_normal

	# Input Direction
	var direction : Vector3 = Vector3.ZERO
	var aim       : Basis   = get_global_transform().basis
	if (input.x >= 0.5):
		direction -= aim.z
	if (input.x <= -0.5):
		direction += aim.z
	if (input.y >= 0.5):
		direction += aim.x
	if (input.y <= -0.5):
		direction -= aim.x
	direction.y = 0.0
	direction = direction.normalized()

	# Snapping
	if (is_on_floor()):
		snap = -get_floor_normal() - get_floor_velocity() * delta
		velocity.y = max(velocity.y, 0)

		# Jump
		if (jump && has_stamina(jump_stamina)):
			velocity.y = jump_strength
			snap = Vector3.ZERO
			self.stamina -= jump_stamina

	else:
		if (snap != Vector3.ZERO && velocity.y != 0):
			velocity.y = 0
		snap = Vector3.ZERO
		velocity.y -= gravity * delta

	# Walk / Sprint
	var speed : float = walk_speed * modifier
	if (is_on_floor() && sprint && input.x >= 0.5 && has_stamina()):
		speed = sprint_speed
		self.stamina -= sprint_stamina * delta

	# Acceleration
	var temp_velocity     : Vector3 = velocity
	var temp_acceleration : float
	var target            : Vector3 = direction * speed
	temp_velocity.y = 0.0
	if (direction.dot(temp_velocity) > 0):
		temp_acceleration = acceleration
	else:
		temp_acceleration = deceleration
	if (! is_on_floor()):
		temp_acceleration *= air_control
	temp_velocity = temp_velocity.linear_interpolate(target, temp_acceleration * delta)
	velocity.x = temp_velocity.x
	velocity.z = temp_velocity.z
	if (direction.dot(velocity) == 0):
		var velocity_clamp : float = 0.01
		if (abs(velocity.x) < velocity_clamp):
			velocity.x = 0
		if (abs(velocity.z) < velocity_clamp):
			velocity.z = 0

	# Move character
	velocity = move_and_slide_with_snap(velocity, snap, Vector3.UP, true, 4, max_floor_angle)

	# Fall Damage
	#var on_ground : bool = is_on_floor() || is_on_wall()
	#if (on_ground && (! prev_on_ground) && -prev_velocity.y - velocity.y >= fall_damage_threshold):
	#	var damage : float = -prev_velocity.y - velocity.y - fall_damage_threshold
	#	damage = pow(damage, fall_damage_power) * fall_damage_scale
	#	self.health -= damage

	# Stamina Regeneration
	if (stamina_timer <= 0):
		self.stamina += stamina_regen * delta
	stamina_timer = clamp(stamina_timer - delta, 0.0, stamina_cooldown)

	# Debug
	if (get_game_world().render_mode == get_game_world().RenderMode.Debug):
		get_interface().data_position = translation
		get_interface().data_velocity = velocity
		get_interface().data_rotation = Vector2(rotation.y, $pivot/camera.rotation.x)



func _input(event : InputEvent) -> void:
	if (controlling && get_game_world().mouse_mode == get_game_world().MouseMode.Game):
		# Rotate camera on mouse motion if controlling.
		if (event is InputEventMouseMotion):
			$pivot/camera.rotation.x  = clamp($pivot/camera.rotation.x - (event.relative.y * mouse_sensitivity), -PI / 2.0, PI / 2.0)
			rotation.y               -= event.relative.x * mouse_sensitivity
			$pivot/hands.rotation.x   = $pivot/camera.rotation.x / 4.0

		if (event is InputEventMouseButton):
			if (event.pressed):
				var collider : Spatial = $pivot/camera/camera/cast.get_collider()
				if (collider):
					if (event.button_index == BUTTON_LEFT):
						if (not get_game_world().left_clicked()):
							if (collider.has_method("left_clicked_world")):
								collider.left_clicked_world()
					if (event.button_index == BUTTON_RIGHT):
						if (not get_game_world().right_clicked()):
							if (collider.has_method("right_clicked_world")):
								collider.right_clicked_world()



func _notification(what : int) -> void:
	# Capture mouse on mouse enter window if controlling.
	if (controlling):
		if (what == NOTIFICATION_WM_MOUSE_ENTER):
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)





func set_health(value : float) -> void:
	health = clamp(value, 0.0, max_health)
	# Send value to canvas if controlling.
	if (controlling):
		get_interface().health_target = health / max_health

func set_stamina(value : float) -> void:
	if (value < stamina):
		stamina_timer = stamina_cooldown
	stamina = clamp(value, 0.0, max_stamina)
	if (stamina <= 0.0 && ! stamina_exhaust):
		stamina_exhaust = true
	elif (stamina_exhaust && stamina >= max_stamina):
		stamina_exhaust = false
	# Send value to canvas if controlling.
	if (controlling):
		get_interface().stamina_target  = stamina / max_stamina
		get_interface().stamina_exhaust = stamina_exhaust

func has_stamina(_amount : float = 0.0) -> bool:
	return (! stamina_exhaust)# && stamina > amount



func set_mainhand_item(item : Item) -> void:
	for child in $pivot/hands/right.get_children():
		child.queue_free()
	if (item != null):
		var instance : Item = load(item.filename).instance()
		instance.set_state(Item.State.Hand)
		$pivot/hands/right.add_child(instance)

func set_offhand_item(item : Item) -> void:
	for child in $pivot/hands/left.get_children():
		child.queue_free()
	if (item != null):
		var instance : Item = load(item.filename).instance()
		instance.set_state(Item.State.Hand)
		$pivot/hands/left.add_child(instance)



func get_camera() -> Node:
	return $pivot/camera/camera





func drop_item(instance : Node) -> void:
	var anchor : Vector3 = $pivot/camera/camera.get_global_transform().basis.z
	instance.state = Item.State.Ground
	instance.translation = $pivot/camera/camera.to_global($pivot/camera/camera.translation) - anchor + Vector3(rand_range(-1.0, 1.0), rand_range(-1.0, 1.0), rand_range(-1.0, 1.0) * 0.25)
	get_entities().add_child(instance)
