extends Node

## Qırım Histori
## Система выносливости.
## Используется для бега, атак, блока,
## парирования и боя двумя оружиями.

signal stamina_changed(current_stamina: float, max_stamina: float)
signal stamina_depleted


@export var max_stamina: float = 100.0
@export var regeneration_rate: float = 15.0

var current_stamina: float
var regeneration_enabled: bool = true


func _ready() -> void:
	current_stamina = max_stamina


func _process(delta: float) -> void:
	if regeneration_enabled and current_stamina < max_stamina:
		restore_stamina(regeneration_rate * delta)


func consume_stamina(amount: float) -> bool:
	if amount <= 0.0:
		return true

	if current_stamina < amount:
		stamina_depleted.emit()
		return false

	current_stamina -= amount
	stamina_changed.emit(current_stamina, max_stamina)

	return true


func restore_stamina(amount: float) -> void:
	if amount <= 0.0:
		return

	current_stamina = min(
		current_stamina + amount,
		max_stamina
	)

	stamina_changed.emit(current_stamina, max_stamina)


func set_regeneration_enabled(enabled: bool) -> void:
	regeneration_enabled = enabled


func is_exhausted() -> bool:
	return current_stamina <= 0.0


func get_stamina_percent() -> float:
	if max_stamina <= 0.0:
		return 0.0

	return current_stamina / max_stamina
