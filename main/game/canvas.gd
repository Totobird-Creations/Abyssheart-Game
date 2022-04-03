extends CanvasLayer



var health_target        : float   = 1.0
var stamina_target       : float   = 1.0
var stamina_exhaust      : bool    = false

var data_position        : Vector3 = Vector3.ZERO
var data_velocity        : Vector3 = Vector3.ZERO
var data_rotation        : Vector2 = Vector2.ZERO

var prev_stamina_exhaust : bool    = false



func _ready() -> void:
	var version : String = ""
	if (OS.has_feature("standalone")):
		version += "Release"
	else:
		version += "Development"
	$interface/debug/version.text = version



func _physics_process(delta : float) -> void:
	# Interpolate health bar to correct value
	var prev_health : float = 1.0 - $interface/bars/health/container/bar.anchor_top
	$interface/bars/health/container/bar.anchor_top = 1.0 - move_toward(prev_health, health_target,
		abs(stamina_target - prev_health) * 25.0 * delta
	)

	# Interpolate stamina bar to correct value
	var prev_stamina : float = $interface/stamina/background/container/bar.anchor_right
	$interface/stamina/background/container/bar.anchor_right = move_toward(prev_stamina, stamina_target,
		abs(stamina_target - prev_stamina) * 25.0 * delta
	)
	if (stamina_exhaust && ! prev_stamina_exhaust):
		$interface/stamina/background/container/bar/colour.play('toggle')
		$interface/stamina/background/warning.play('main')
	elif (prev_stamina_exhaust && ! stamina_exhaust):
		$interface/stamina/background/container/bar/colour.play_backwards('toggle')
	prev_stamina_exhaust = stamina_exhaust
	
	if (get_parent().render_mode == get_parent().RenderMode.Debug):
		var coordinates : Vector2 = Vector2(data_position.x, data_position.z)

		$interface/debug/left/value/position    .text = str(data_position.x) + " " + str(data_position.y) + " " + str(data_position.z)
		$interface/debug/left/value/velocity    .text = str(data_velocity.x) + " " + str(data_velocity.y) + " " + str(data_velocity.z)
		$interface/debug/left/value/rotation    .text = str(data_rotation.x / PI) + " " + str(data_rotation.y / (PI / 2.0))

		$interface/debug/left/value/temperature .text = str(get_node("../terroir").get_generator().get_temperature(coordinates))
		$interface/debug/left/value/humidity    .text = str(get_node("../terroir").get_generator().get_humidity(coordinates))
		$interface/debug/left/value/mushiness   .text = str(get_node("../terroir").get_generator().get_mushiness(coordinates))
