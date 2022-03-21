extends WorldEnvironment



export(float, 0.0, 1.0) var time       : float = 0.0
export(float)           var time_scale : float = 0.075



func _ready() -> void:
	set_time(time)



#func _physics_process(delta : float) -> void:
	#time = fmod(time + delta * time_scale, 1.0)
	#set_time(time)



func sky_updated() -> void:
	$sky_texture.copy_to_environment(self.environment)



func set_time(value : float) -> void:
	time = value
	if (get_node_or_null('sky_texture')):
		$sky_texture.set_time_of_day(24.0 * time, $sun, 0.0)
