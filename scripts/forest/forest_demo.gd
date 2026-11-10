class_name ForestDemo
extends Node2D
## Controlador dos setores da Floresta dos Ossos (M6-A / M6-B1).
## Não altera a campanha oficial nem os arquivos de save.

signal room_changed(id: int)

const ROOM_PATHS: Array[String] = [
	"res://scenes/forest/sector_01.tscn",
	"res://scenes/forest/sector_02.tscn",
	"res://scenes/forest/sector_03.tscn",
	"res://scenes/forest/sector_04.tscn",
	"res://scenes/forest/sector_05.tscn",
	"res://scenes/forest/sector_06.tscn",
	"res://scenes/forest/sector_07.tscn",
	"res://scenes/forest/sector_08.tscn",
	"res://scenes/forest/sector_09.tscn",
	"res://scenes/forest/sector_10.tscn"
]
const CP_SCENE: PackedScene = preload("res://scenes/props/respawn_checkpoint.tscn")

var room: Node2D
var current_room: int = -1
var busy: bool = false
var completed: bool = false
var transitions: int = 0
var states: Dictionary = {}
var checkpoints: Array[RespawnCheckpoint] = []

@onready var hero: KnightController = $Knight
@onready var camera: Camera2D = $Camera2D
@onready var caption: Label = $ForestHUD/Caption
@onready var subcaption: Label = $ForestHUD.get_node_or_null("SubCaption") as Label
@onready var hint: Label = $ForestHUD/Hint
@onready var subhint: Label = $ForestHUD/SubHint

func _ready() -> void:
	process_physics_priority = 2
	
	for id: int in range(ROOM_PATHS.size()):
		var cp: RespawnCheckpoint = CP_SCENE.instantiate() as RespawnCheckpoint
		cp.name = "ForestCheckpoint%d" % id
		var entry_y: float = ForestLayout.entry(id).y - ForestLayout.ORIGINS[id].y
		cp.position = ForestLayout.ORIGINS[id] + Vector2(96, entry_y)
		$Checkpoints.add_child(cp)
		checkpoints.append(cp)
	
	hero.survival.respawn_requested.connect(_respawn)
	hero.survival.died.connect(_on_death)
	$HealthHUD.bind(hero.survival)
	
	# Na Fase 3 (Floresta dos Ossos), Aren possui o Passo das Sombras (Dash)
	hero.dash_unlocked = true
	
	await switch_room(0, false)
	hero.set_default_respawn(ForestLayout.entry(0))

func _on_death() -> void:
	if is_instance_valid(room) and room.has_method("disarm"):
		room.disarm()

func switch_room(id: int, from_right: bool = false, resetting: bool = false) -> void:
	if busy or id < 0 or id >= ROOM_PATHS.size():
		return
	busy = true
	hero.process_mode = Node.PROCESS_MODE_DISABLED
	hero.sword_attack.cancel()
	hint.text = "Adentrando a Floresta dos Ossos..."
	
	if is_instance_valid(room):
		if not resetting and room.has_method("snapshot"):
			states[current_room] = room.snapshot()
		if room.has_method("disarm"):
			room.disarm()
		room.queue_free()
		room = null
		await get_tree().process_frame
	
	var scene: PackedScene = load(ROOM_PATHS[id]) as PackedScene
	room = scene.instantiate() as Node2D
	room.position = ForestLayout.ORIGINS[id]
	$Rooms.add_child(room)
	current_room = id
	
	if room.has_method("set_hero"):
		room.set_hero(hero)
	
	if not resetting and room.has_method("restore_state"):
		room.restore_state(states.get(id, {}))
	
	# Aguarda frames de física para que as colisões estejam ativas
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	hero.reset_to(ForestLayout.entry(id, from_right))
	camera.position = camera_target()
	camera.reset_smoothing()
	camera.force_update_scroll()
	
	hero.process_mode = Node.PROCESS_MODE_INHERIT
	busy = false
	transitions += 1
	room_changed.emit(id)

func _respawn() -> void:
	if busy:
		await room_changed
	states.clear()
	var target_room: int = 0
	if is_instance_valid(hero.active_checkpoint):
		var cp_idx: int = checkpoints.find(hero.active_checkpoint)
		if cp_idx >= 0:
			target_room = cp_idx
	if current_room != target_room:
		await switch_room(target_room, false, true)
	else:
		if is_instance_valid(room) and room.has_method("reset_encounters"):
			room.reset_encounters()
		await get_tree().physics_frame
	hero.respawn_at_checkpoint()

func _alive_fall() -> void:
	states.clear()
	var safe_room: int = clampi(current_room, 0, ROOM_PATHS.size() - 1)
	hero.reset_to(ForestLayout.entry(safe_room, false))

func camera_target() -> Vector2:
	var origin: Vector2 = ForestLayout.ORIGINS[maxi(0, current_room)]
	var local: Vector2 = hero.global_position - origin
	return origin + Vector2(
		clampf(local.x + hero.facing * 24.0, 160.0, 800.0),
		clampf(local.y - 40.0, 90.0, 330.0)
	)

func _physics_process(delta: float) -> void:
	if busy or current_room < 0:
		return
	
	var local: Vector2 = hero.global_position - ForestLayout.ORIGINS[current_room]
	camera.position = camera.position.move_toward(camera_target(), 600.0 * delta).round()
	
	if is_instance_valid(subcaption):
		caption.text = "FLORESTA DOS OSSOS"
		subcaption.text = "Setor %d/%d · %s" % [current_room + 1, ROOM_PATHS.size(), ForestLayout.NAMES[current_room]]
	else:
		caption.text = "FLORESTA DOS OSSOS · %d/%d · %s" % [current_room + 1, ROOM_PATHS.size(), ForestLayout.NAMES[current_room]]
	hint.text = "A/D mover · Espaço saltar · Shift Passo das Sombras (Dash) · J espada · F7 reiniciar · F1 alternar ajuda"
	
	match current_room:
		0:
			subhint.text = "Explore o chão e as raízes elevadas. Vá para a direita para alcançar o Bosque das Raízes."
		1:
			if local.x < 260.0:
				subhint.text = "Abismo de raízes à frente: combine Salto + Passo das Sombras (Shift) para atravessar!"
			elif local.x >= 700.0:
				subhint.text = "Santuário do Cervo alcançado · Prossiga à direita para a Passagem dos Fósseis."
			else:
				subhint.text = "Bosque denso: use os troncos caídos e galhos elevados para avançar."
		2:
			subhint.text = "Passagem dos Fósseis: avance entre raízes ancestrais e estruturas ósseas petrificadas."
		3:
			subhint.text = "Clareira Ancestral alcançada · Prossiga à direita para a Passagem das Raízes Profundas."
		4:
			subhint.text = "Passagem das Raízes Profundas: túneis de raízes gigantes e arcos ósseos cobrem o caminho."
		5:
			subhint.text = "Galeria dos Ossos Antigos: grande ossuário monumental · Prossiga à direita para a Fenda das Vértebras."
		6:
			subhint.text = "Fenda das Vértebras: colunas espinhais fósseis e abismos enevoados · Prossiga à direita para o Bosque dos Ecos."
		7:
			subhint.text = "Bosque dos Ecos: abóbada vegetal ancestral e monólitos · Prossiga à direita para a Ravina das Sombras Fósseis."
		8:
			subhint.text = "Ravina das Sombras Fósseis: abismo vertiginoso e costelas titânicas · Prossiga à direita para a Clareira da Bruma Espectral."
		9:
			var abbey_prog: Script = preload("res://scripts/abbey/abbey_progress.gd")
			if abbey_prog.is_flag_set("cervo_defeated"):
				subhint.text = "Clareira da Bruma Espectral: Cervo Espectral pacificado · Salto Espectral disponível · Exploração livre · F7 reinicia."
			else:
				subhint.text = "Clareira da Bruma Espectral: santuário velado · Avance para enfrentar o Cervo Espectral · F7 reinicia · Retorne à esquerda."
	
	if hero.survival.is_dead:
		return
	
	# Queda em abismo
	if local.y > 430.0:
		_alive_fall.call_deferred()
		return
	
	# Transição para a direita (avanço de setor)
	if current_room < ROOM_PATHS.size() - 1 and local.x >= 944.0 and hero.facing > 0:
		switch_room.call_deferred(current_room + 1, false)
	# Retorno bidirecional para a esquerda (regresso de setor)
	elif current_room > 0 and local.x <= 16.0 and hero.facing < 0:
		switch_room.call_deferred(current_room - 1, true)
	
	# Limites laterais da sala (só bloqueia nas extremidades absolutas do mapa)
	if current_room == 0 and local.x < 6.0:
		hero.global_position.x = ForestLayout.ORIGINS[current_room].x + 6.0
	elif current_room == ROOM_PATHS.size() - 1 and local.x > 954.0:
		hero.global_position.x = ForestLayout.ORIGINS[current_room].x + 954.0

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F7:
			get_tree().reload_current_scene()
		elif event.keycode == KEY_F6:
			var abbey_prog: Script = preload("res://scripts/abbey/abbey_progress.gd")
			abbey_prog.set_flag("cervo_defeated", false)
			abbey_prog.set_flag("spectral_jump_unlocked", false)
			if is_instance_valid(room) and room.has_node("ClearingEncounter"):
				var arena_node = room.get_node("ClearingEncounter")
				arena_node.completed = false
				arena_node.reset_encounter()
			hint.text = "Encontro do Cervo Espectral resetado para playtest!"
		elif event.keycode == KEY_F1 or event.keycode == KEY_H:
			hint.visible = not hint.visible
			subhint.visible = hint.visible
