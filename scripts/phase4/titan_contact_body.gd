extends CharacterBody2D
## Proxy body so the player's shared enemy-contact damage query detects the Titan.

var titan: Node2D

var contact_damage_enabled: bool:
	get:
		return is_instance_valid(titan) and bool(titan.call("is_contact_dangerous"))
