extends CharacterBody3D

## Qırım Histori
## Главный герой — Devlet Giray.
## Центральный персонаж, объединяющий движение,
## здоровье, выносливость, бой, оружие и ранения.


@export var walk_speed: float = 3.0
@export var run_speed: float = 6.0
@export var acceleration: float = 12.0
@export var gravity: float = 18.0


var health_component
var stamina_component
var combat_component
var weapon_component
var injury_component


var is_running: bool = false


func _ready() -> void:
	_create_components()
	_setup_devlet()


func _create_components() -> void:
	var health_script = preload("res://scripts/HealthComponent.gd")
	var stamina_script = preload("res://scripts/StaminaComponent.gd")
	var combat_script = preload("res://scripts/CombatComponent.gd")
	var weapon_script = preload("res://scripts/WeaponComponent.gd")
	var injury_script = preload("res://scripts/InjuryComponent.gd")

	health_component = health_script.new()
	stamina_component = stamina_script.new()
	combat_component = combat_script.new()
	weapon_component = weapon_script.new()
	injury_component = injury_script.new()

	add_child(health_component)
	add_child(stamina_component)
	add_child(combat_component)
	add_child(weapon_component)
	add_child(injury_component)


func _setup_devlet() -> void:
	weapon_component.weapon_name = "Crimean Sabre"
	weapon_component.damage = 25.0
	weapon_component.stamina_cost = 15.0

	weapon_component.equip()

	print("Devlet Giray initialized.")
	print("Weapon: ", weapon_component.weapon_name)


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_handle_movement(delta)

	move_and_slide()


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0


func _handle_movement(delta: float) -> void:
	var input_vector := Input.get_vector(
		"move_left",
		"move_right",
		"move_forward",
		"move_backward"
	)

	var direction := Vector3(
		input_vector.x,
		0.0,
		input_vector.y
	)

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
		velocity.x = move_toward(
			velocity.x,
			0.0,
			acceleration * delta
		)

		velocity.z = move_toward(
			velocity.z,
			0.0,
			acceleration * delta
		)


func attack() -> void:
	if weapon_component == null:
		return

	if not weapon_component.can_attack():
		return

	var stamina_cost: float = weapon_component.stamina_cost

	if not stamina_component.consume_stamina(stamina_cost):
		print("Devlet is too exhausted to attack.")
		return

	combat_component.attack()


func start_block() -> void:
	combat_component.start_block()


func stop_block() -> void:
	combat_component.stop_block()


func take_damage(amount: float) -> void:
	health_component.take_damage(amount)


func receive_body_injury(
	body_part: InjuryComponent.BodyPart,
	damage: float
) -> void:
	injury_component.apply_injury(body_part, damage)


func restore_health(amount: float) -> void:
	health_component.heal(amount)


func restore_stamina(amount: float) -> void:
	stamina_component.restore_stamina(amount)


func is_alive() -> bool:
	return health_component.is_alive()
