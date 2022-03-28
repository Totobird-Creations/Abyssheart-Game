extends CanvasLayer



var health_target        : float = 1.0

var stamina_target       : float = 1.0
var stamina_exhaust      : bool  = false

var prev_stamina_exhaust : bool  = false



func _physics_process(delta : float) -> void:
	var prev_health : float = 1.0 - $ui/bars/health/container/bar.anchor_top
	$ui/bars/health/container/bar.anchor_top = 1.0 - move_toward(prev_health, health_target,
		abs(stamina_target - prev_health) * 25.0 * delta
	)

	var prev_stamina : float = $ui/stamina/background/container/bar.anchor_right
	$ui/stamina/background/container/bar.anchor_right = move_toward(prev_stamina, stamina_target,
		abs(stamina_target - prev_stamina) * 25.0 * delta
	)
	if (stamina_exhaust && ! prev_stamina_exhaust):
		$ui/stamina/background/container/bar/colour.play('toggle')
		$ui/stamina/background/warning.play('main')
	elif (prev_stamina_exhaust && ! stamina_exhaust):
		$ui/stamina/background/container/bar/colour.play_backwards('toggle')
	prev_stamina_exhaust = stamina_exhaust
