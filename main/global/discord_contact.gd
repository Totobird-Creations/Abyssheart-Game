extends Node



var core       : Discord.Core
var activities : Discord.ActivityManager



func _ready() -> void:
	build()


func build() -> void:
	core = Discord.Core.new()

	var result : int = core.create(
		962773221130797126,
		Discord.CreateFlags.DEFAULT
	)
	if (result != Discord.Result.OK):
		print("Failed to initialise Discord Core: ", result)
		destroy()
		return

	activities = core.get_activity_manager()

	update_activity()


func destroy() -> void:
	core       = null
	activities = null



func _process(_delta : float) -> void:
	if (core):
		var result : int = core.run_callbacks()
		if (result != Discord.Result.OK):
			print("Failed to run Discord callbacks: ", result)
			destroy()





func update_activity() -> void:
	var activity : Discord.Activity = Discord.Activity.new()

	activity.state              = "Singleplayer"
	activity.details            = "In Game"
	activity.timestamps.start   = OS.get_unix_time()
	activity.assets.large_image = "spore"

	activities.update_activity(activity)
	var result : int = yield(activities, "update_activity_callback")



func update_activity_callback(_result : int) -> void:
	pass
