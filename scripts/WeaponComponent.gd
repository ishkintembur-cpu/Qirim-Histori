extends Node

## Qırım Histori
## Универсальная система оружия.
## Архитектура сразу рассчитана на:
## одну саблю, две сабли, саблю + кинжал и лук.

enum WeaponType {
	SABRE,
	DAGGER,
	BOW
}

enum Hand {
	LEFT,
	RIGHT
}

@export var weapon_type: WeaponType = WeaponType.SABRE
@export var hand: Hand = Hand.RIGHT

@export var weapon_name: String = "Crimean Sabre"
@export var damage: float = 25.0
@export var stamina_cost: float = 15.0
@export var attack_speed: float = 1.0

var equipped: bool = false
var durability: float = 100.0


func equip() -> void:
	equipped = true


func unequip() -> void:
	equipped = false


func can_attack() -> bool:
	return equipped and durability > 0.0


func use_weapon() -> float:
	if not can_attack():
		return 0.0

	return damage


func damage_weapon(amount: float) -> void:
	durability = max(durability - amount, 0.0)


func repair(amount: float) -> void:
	durability = min(durability + amount, 100.0)
