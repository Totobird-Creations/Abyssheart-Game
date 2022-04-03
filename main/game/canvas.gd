extends CanvasLayer



var health_target        : float = 1.0

var stamina_target       : float = 1.0
var stamina_exhaust      : bool  = false

var prev_stamina_exhaust : bool  = false



func _ready() -> void:
	var version : String = ProjectSettings.get_setting("application/config/name")
	if (! OS.has_feature("standalone")):
		version += " / Development"
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
