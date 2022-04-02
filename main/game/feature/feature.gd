extends StaticBody
class_name Feature



export(int)   var feature_seed  : int   = 0
export(float) var normal_amount : float = 1.0

var placed     : bool    = false
var floor_cast : RayCast = RayCast.new()

var active              : bool = false



func _ready() -> void:
	var rng  : RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed                         = feature_seed

	# Deactivate visuals and collision.
	deactivate()

	# Rotate mesh randomly.
	var rot  : float                 = rng.randf_range(-PI, PI)
	var mesh : Spatial               = get_meshes()
	if (mesh):
		mesh.rotation.y = rot

	# Prepare checks for floor.
	add_child(floor_cast)
	floor_cast.collision_mask = 1
	floor_cast.cast_to        = Vector3(0.0, 100.0, 0.0)
	floor_cast.enabled        = true



func _physics_process(_delta: float) -> void:
	if (not placed):
		# If there is floor, move to floor and rotate correctly.
		var position    : Vector3        = floor_cast.get_collision_point()
		var coordinates : Vector2        = Vector2(position.x, position.z)
		var generator   : VoxelGenerator = get_parent().get_parent().get_parent().generator
		if (floor_cast.is_colliding() && position.y < generator.get_elevation(coordinates) + generator.get_height(coordinates) - 1.0):
			translation.y      = position.y
			rotation           = floor_cast.get_collision_normal() * normal_amount
			floor_cast.enabled = false
			floor_cast.queue_free()
			placed = true
			activate()



func activate() -> void:
	active  = true
	visible = true
	for child in get_children():
		if (child is CollisionShape):
			child.disabled = false

func deactivate() -> void:
	active  = false
	visible = false
	for child in get_children():
		if (child is CollisionShape):
			child.disabled = true



func get_meshes() -> Node:
	return null



static func get_spawn_chance(_terroir : Spatial, _position : Vector3) -> float:
	return 1.0

static func get_required_height() -> float:
	return 1.0

static func get_required_radius() -> float:
	return 1.0

static func get_spread_count() -> int:
	return 0

static func get_spread_range() -> float:
	return 0.0
