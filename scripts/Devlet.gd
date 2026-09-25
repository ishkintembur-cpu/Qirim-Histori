extends CharacterBody3D

## Qırım Histori
## Главный герой — Devlet Giray

@export var walk_speed: float = 3.0
@export var run_speed: float = 6.0
@export var acceleration: float = 12.0
@export var gravity: float = 18.0

var is_running: bool = false
var health: float = 100.0
var stamina: float = 100.0


func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	handle_movement(delta)
	move_and_slide()


func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0


func handle_movement(delta: float) -> void:
	var input_vector := Input.get_vector(
		"move_left",
		"move_right",
		"move_forward",
		"move_backward"
	)

	var direction := Vector3(input_vector.x, 0.0, input_vector.y)

	is_running = Input.is_action_pressed("run")

	var current_speed := run_speed if is_running else walk_speed

	if direction.length() > 0.0:
		direction = direction.normalized()
		velocity.x = move_toward(
			velocity.x,
			direction.x * current_speed,
			acceleration * delta
		)
		velocity.z = move_toward(
			velocity.z,
			direction.z * current_speed,
			acceleration * delta
		)
	else:
		velocity.x = move_toward(velocity.x, 0.0, acceleration * delta)
		velocity.z = move_toward(velocity.z, 0.0, acceleration * delta)


func take_damage(amount: float) -> void:
	health = max(health - amount, 0.0)

	if health <= 0.0:
		die()


func die() -> void:
	print("Devlet Giray has fallen.")


func restore_stamina(amount: float) -> void:
	stamina = min(stamina + amount, 100.0)
