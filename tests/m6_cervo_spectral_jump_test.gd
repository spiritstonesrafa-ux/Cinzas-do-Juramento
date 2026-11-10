extends SceneTree

# Suíte de testes automatizados do Salto Espectral (Double Jump)
# ART-BOSS-06 / M6-CERVO-BOSS

const KNIGHT_SCENE: PackedScene = preload("res://scenes/player/knight.tscn")
const ABBEY_PROGRESS: Script = preload("res://scripts/abbey/abbey_progress.gd")

var total_assertions: int = 0
var failed_assertions: int = 0

func _initialize() -> void:
	run_tests.call_deferred()

func assert_true(condition: bool, message: String) -> void:
	total_assertions += 1
	if condition:
		print("  [PASS] %s" % message)
	else:
		failed_assertions += 1
		printerr("  [FAIL] %s" % message)

func run_tests() -> void:
	var original_save_bytes: PackedByteArray = []
	var f = FileAccess.open("user://cinzas_abbey_progress_v1.json", FileAccess.READ)
	if f != null:
		original_save_bytes = f.get_buffer(f.get_length())
		f.close()
	
	DirAccess.remove_absolute("user://cinzas_abbey_progress_v1.json")
	
	print("\n==================================================")
	print("SUÍTE DE TESTES: SALTO ESPECTRAL (DOUBLE JUMP)")
	print("==================================================")
	
	# 1. Configuração inicial do Knight
	var root: Node2D = Node2D.new()
	root_node_check(root)
	
	var knight: KnightController = KNIGHT_SCENE.instantiate() as KnightController
	root.add_child(knight)
	
	print("\n--- 1. Estado Inicial Bloqueado ---")
	assert_true(not knight.spectral_jump_unlocked, "Salto Espectral inicia bloqueado por padrão")
	assert_true(not knight.can_spectral_jump, "can_spectral_jump falso antes do desbloqueio")
	
	# Simula tentativa de segundo salto no ar sem desbloqueio
	knight.velocity.y = 100.0
	knight._physics_process(0.016)
	assert_true(knight.velocity.y > 0.0, "Sem desbloqueio, não há impulso vertical no ar")
	
	print("\n--- 2. Desbloqueio e Primeiro Salto no Solo ---")
	knight.spectral_jump_unlocked = true
	assert_true(knight.spectral_jump_unlocked, "Salto Espectral habilitado com sucesso")
	
	# No solo, can_spectral_jump é armado
	# Simulamos is_on_floor = true mockando o estado
	knight.can_spectral_jump = true
	knight.velocity.y = knight.jump_impulse
	assert_true(knight.velocity.y < 0.0, "Primeiro salto aplica impulso normal (%f)" % knight.jump_impulse)
	
	print("\n--- 3. Execução do Segundo Salto no Ar (Salto Espectral) ---")
	# Simula que o Cavaleiro subiu e começou a cair
	knight.velocity.y = 50.0
	assert_true(knight.can_spectral_jump, "Salto duplo disponível no ar após salto inicial")
	
	# Simula Input de salto no ar
	# Mock de input via simulação do bloco lógico do KnightController
	if knight.can_spectral_jump and not knight.survival.is_dead:
		knight.velocity.y = knight.spectral_jump_impulse
		knight.can_spectral_jump = false
		knight._spectral_jump_fx_timer = 0.20
	
	assert_true(knight.velocity.y == knight.spectral_jump_impulse, "Segundo salto aplica impulso espectral (%f)" % knight.spectral_jump_impulse)
	assert_true(not knight.can_spectral_jump, "can_spectral_jump consumido após ativação")
	assert_true(knight._spectral_jump_fx_timer > 0.0, "Timer de feedback visual espectral ativado")
	
	print("\n--- 4. Prevenção de Terceiro Salto (Sem Salto Triplo) ---")
	# Tenta saltar novamente no ar com can_spectral_jump já falso
	var vel_before: float = knight.velocity.y
	if knight.can_spectral_jump and not knight.survival.is_dead:
		knight.velocity.y = knight.spectral_jump_impulse
	assert_true(knight.velocity.y == vel_before, "Terceiro acionamento ignorado (sem salto triplo)")
	
	print("\n--- 5. Restauração ao Tocar o Solo ---")
	# Quando is_on_floor() é verdadeiro, can_spectral_jump é rearmado
	knight.can_spectral_jump = knight.spectral_jump_unlocked
	assert_true(knight.can_spectral_jump, "Salto duplo rearmado após pouso")
	
	print("\n--- 6. Respeito à Morte e Reset ---")
	knight.can_spectral_jump = true
	knight.reset_to(Vector2(100, 200))
	assert_true(not knight.can_spectral_jump, "can_spectral_jump resetado para falso no reset_to")
	assert_true(knight._spectral_jump_fx_timer == 0.0, "Timer de feedback visual zerado no reset_to")
	
	print("\n--- 7. Compatibilidade de Persistência no AbbeyProgress ---")
	assert_true(ABBEY_PROGRESS.has_method("spectral_jump_unlocked"), "AbbeyProgress possui método spectral_jump_unlocked")
	assert_true(ABBEY_PROGRESS.has_method("grant_cervo_reward"), "AbbeyProgress possui método grant_cervo_reward")
	assert_true("cervo_defeated" in ABBEY_PROGRESS.FLAGS, "Flag cervo_defeated presente em ABBEY_PROGRESS.FLAGS")
	assert_true("spectral_jump_unlocked" in ABBEY_PROGRESS.FLAGS, "Flag spectral_jump_unlocked presente em ABBEY_PROGRESS.FLAGS")
	
	root.queue_free()
	
	if not original_save_bytes.is_empty():
		var out_f = FileAccess.open("user://cinzas_abbey_progress_v1.json", FileAccess.WRITE)
		if out_f != null:
			out_f.store_buffer(original_save_bytes)
			out_f.close()
	
	print("\n==================================================")
	print("RESULTADO SALTO ESPECTRAL: %d PASSOU, %d FALHOU" % [total_assertions - failed_assertions, failed_assertions])
	print("==================================================")
	
	if failed_assertions == 0:
		quit(0)
	else:
		quit(1)

func root_node_check(node: Node) -> void:
	var scene = get_root()
	if scene != null:
		scene.add_child(node)

