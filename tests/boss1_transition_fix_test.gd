extends SceneTree
## Teste oficial para BOSS1-TRANSITION-FIX01 (CAMPANHA-INTEGRACAO-01).
## Valida os Testes A a E da especificação:
## Teste A: Derrota sem transição imediata (animação inicia e não carrega Fase 2 prematuramente).
## Teste B: Cinemática reproduzida integralmente (2.6s) até conclusão dos efeitos e narrativa.
## Teste C: Recompensa única de +1 Max HP persistida, sem duplicação.
## Teste D: Permanecer na arena mantém Fase 1; atravessar a saída oriental liberada carrega a Abadia.
## Teste E: Continuidade de HP e controles na Abadia, além do teste de saída pelo cemitério.

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const ABBEY_SCENE: PackedScene = preload("res://scenes/abbey/abbey_chapter.tscn")
const ABBEY_PROGRESS: Script = preload("res://scripts/abbey/abbey_progress.gd")
const OathGuardian = preload("res://scripts/boss/guardian.gd")

var checks: int = 0
var failures: int = 0

func check(ok: bool, msg: String) -> void:
	checks += 1
	if ok:
		print("  [PASS] ", msg)
	else:
		failures += 1
		printerr("  [FAIL] ", msg)

func _frames(count: int = 3) -> void:
	for _i in range(count):
		await physics_frame
		await process_frame

func _initialize() -> void:
	var isolated: String = OS.get_environment("SAVE_SAFETY_ISOLATED_ROOT").replace("\\", "/").simplify_path()
	var actual: String = OS.get_user_data_dir().replace("\\", "/").simplify_path()
	var personal: String = OS.get_environment("USERPROFILE").path_join("AppData/Roaming/Godot/app_userdata/Cinzas do Juramento").replace("\\", "/").simplify_path()
	if isolated.is_empty() or not actual.begins_with(isolated + "/") or actual.to_lower() == personal.to_lower():
		printerr("Teste recusado: perfil isolado não confirmado.")
		quit(2)
		return

	# Limpa saves na pasta descartável
	for name: String in DirAccess.get_files_at("user://"):
		if name.begins_with("cinzas_abbey_progress_v1"):
			DirAccess.remove_absolute(ProjectSettings.globalize_path("user://" + name))

	run_tests.call_deferred()

func run_tests() -> void:
	print("==================================================================")
	print("INICIANDO SUÍTE DE TESTES: BOSS1-TRANSITION-FIX01")
	print("==================================================================")

	# -------------------------------------------------------------------------
	# 1. CARGA INICIAL E ENTRADA NO ENCONTRO
	# -------------------------------------------------------------------------
	var main_node = MAIN_SCENE.instantiate()
	root.add_child(main_node)
	await _frames(4)

	var cemetery = main_node.get_node("ForgottenCemetery")
	var hero = cemetery.get_node("Knight") as KnightController
	var encounter = main_node.get_node("GuardianEncounter")

	encounter.enter()
	await _frames(4)

	var arena = encounter.arena
	var guardian = arena.get_node("Guardian") as OathGuardian
	var conclusion = arena.get_node("Guardian/Conclusion")

	check(encounter.active == true, "Arena do Guardião ativada")
	check(is_instance_valid(guardian), "Guardião presente na arena")
	check(hero.survival.max_health == 5, "HP inicial de Aren = 5")

	# -------------------------------------------------------------------------
	# TESTE A: DERROTA SEM TRANSIÇÃO IMEDIATA
	# -------------------------------------------------------------------------
	print("\n--- TESTE A: Redução de HP a zero e início da derrota ---")
	# Reduz o HP do Guardião até 0
	guardian.awake = true
	while guardian.current_health > 0:
		while guardian.state in [OathGuardian.State.INTRO, OathGuardian.State.WAKE, OathGuardian.State.PHASE_TRANSITION, OathGuardian.State.HURT]:
			await _frames(2)
		if guardian.state == OathGuardian.State.DEFEATED:
			break
		guardian.receive_hit()
		await _frames(4)

	check(guardian.current_health == 0, "HP do Guardião reduzido a 0")
	check(guardian.state == OathGuardian.State.DEFEATED, "Guardião entrou em State.DEFEATED")
	check(conclusion.running == true, "Sequência de conclusão/morte iniciada (running == true)")
	check(not conclusion.settled, "Cinemática de derrota ainda em andamento (settled == false)")
	check(not encounter.exit_unlocked, "Passagem oriental BLOQUEADA durante a animação (exit_unlocked == false)")

	# Avança 30 frames (~0.5 segundos) e confirma que a Fase 2 NÃO FOI CARREGADA
	await _frames(30)
	check(is_instance_valid(main_node) and main_node.is_inside_tree(), "TESTE A PASS: Fase 2 NÃO carregou imediatamente após o golpe final!")
	check(is_instance_valid(cemetery) and cemetery.is_inside_tree(), "Cenário da Fase 1 continua ativo e em execução")
	check(conclusion.running == true and not conclusion.settled, "Animação de derrota segue reproduzindo normalmente")

	# -------------------------------------------------------------------------
	# TESTE B: CINEMÁTICA INTEGRAL ATÉ A CONCLUSÃO
	# -------------------------------------------------------------------------
	print("\n--- TESTE B: Cinemática reproduzida integralmente (2.6s) ---")
	# Permite que a cinemática termine seus 2.6 segundos
	while conclusion.running and conclusion.elapsed < conclusion.DURATION:
		await _frames(4)
	await _frames(6)

	check(conclusion.settled == true, "TESTE B PASS: Sequência cinematográfica concluída integralmente (settled == true)")
	check(conclusion.elapsed >= conclusion.DURATION, "Tempo de reprodução respeitou duração canônica (2.6s)")
	check(encounter.exit_unlocked == true, "Saída oriental da arena agora DESBLOQUEADA após conclusão da cinemática")

	# -------------------------------------------------------------------------
	# TESTE C: RECOMPENSA DE +1 HP MÁXIMO (UMA ÚNICA VEZ)
	# -------------------------------------------------------------------------
	print("\n--- TESTE C: Concessão e persistência do +1 HP Máximo ---")
	check(hero.survival.max_health == 6, "TESTE C PASS: HP máximo de Aren ampliado de 5 para 6")
	check(ABBEY_PROGRESS.guardian_reward_unlocked() == true, "Progresso do Guardião registrado no save seguro")

	# Tentativa de chamada duplicada de derrota não pode duplicar HP
	encounter._on_defeated()
	check(hero.survival.max_health == 6, "Chamada duplicada NÃO concede HP extra além de 6")

	# -------------------------------------------------------------------------
	# TESTE D: PERMANÊNCIA NA ARENA & TRAVESSIA DA SAÍDA
	# -------------------------------------------------------------------------
	print("\n--- TESTE D: Permanecer na arena mantém Fase 1; avançar à direita carrega Abadia ---")
	# Aren permanece parado na arena (x ~ 2650) por 20 frames
	await _frames(20)
	check(is_instance_valid(main_node) and main_node.is_inside_tree(), "TESTE D PASS: Permanecer parado na arena NÃO provoca troca de fase")
	check(not encounter.transitioning, "Nenhuma transição em andamento enquanto parado")

	# Simula travessia física da saída oriental liberada
	hero.global_position.x = arena.global_position.x + 325.0 # Ultrapassa a barreira direita (x > 2560 + 310)
	await _frames(6)
	check(not is_instance_valid(encounter) or encounter.transitioning == true or root.get_child(0).name == "AbbeyChapter", "TESTE D PASS: Transição para a Abadia ativada e Main desalocado")

	if is_instance_valid(main_node):
		main_node.queue_free()
	await _frames(4)

	# -------------------------------------------------------------------------
	# TESTE E: CONTINUIDADE NA ABADIA SILENCIOSA (FASE 2)
	# -------------------------------------------------------------------------
	print("\n--- TESTE E: Continuidade e atributos de Aren na Abadia Silenciosa ---")
	var abbey_node = ABBEY_SCENE.instantiate()
	root.add_child(abbey_node)
	while abbey_node.busy:
		await process_frame
	await _frames(4)

	var hero_abbey = abbey_node.hero as KnightController
	check(is_instance_valid(abbey_node), "Abadia Silenciosa carregada com sucesso")
	check(abbey_node.current_room == 0, "Aren surge no Átrio dos Votos (Setor 1)")
	check(hero_abbey.survival.max_health == 6, "TESTE E PASS: Aren mantém os 6 HP herdados do Guardião!")
	check(not hero_abbey.dash_unlocked, "Passo das Sombras permanece bloqueado até o Abade")
	check(abbey_node.camera != null and abbey_node.camera.is_inside_tree(), "Câmera e controles da Abadia íntegros")

	abbey_node.queue_free()
	await _frames(4)

	# -------------------------------------------------------------------------
	# TESTE ADICIONAL: SAÍDA RETORNANDO AO CEMITÉRIO E CRUZANDO O PORTÃO DA CATEDRAL
	# -------------------------------------------------------------------------
	print("\n--- TESTE COMPLEMENTAR: Saída pelo Cemitério até o Portão da Catedral ---")
	var main2 = MAIN_SCENE.instantiate()
	root.add_child(main2)
	await _frames(4)

	var cemetery2 = main2.get_node("ForgottenCemetery")
	var hero2 = cemetery2.get_node("Knight") as KnightController
	var enc2 = main2.get_node("GuardianEncounter")

	# O save já possui recompensa do Guardião desbloqueada
	check(enc2.completed == true, "Encontro reconhece vitória prévia do Guardião")
	check(hero2.survival.max_health == 6, "Aren inicializa no cemitério com 6 HP")

	# Posiciona Aren antes do Portão (x = 2296)
	hero2.position.x = 2296.0
	await _frames(4)
	check(not cemetery2.transitioning, "Aren diante do portão (x=2296) não provoca transição automática")
	check(cemetery2.hint_label.text.contains("Catedral aberto"), "HUD orienta avanço para a Abadia")

	# Aren caminha fisicamente para a direita e cruza o Portão da Catedral (x >= 2340)
	hero2.position.x = 2345.0
	await _frames(4)
	check(cemetery2.transitioning == true, "Transição para Abadia executada ao cruzar o Portão da Catedral no Cemitério")

	main2.queue_free()
	await _frames(4)

	print("\n==================================================================")
	print("RESULTADO BOSS1-TRANSITION-FIX01: %d verificações | %d PASS | %d FAIL" % [checks, checks - failures, failures])
	print("==================================================================")
	quit(1 if failures > 0 else 0)
