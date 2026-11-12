extends SceneTree
## Teste oficial para BOSS1-TRANSITION-FIX02 (CAMPANHA-INTEGRACAO-01).
## Valida formalmente a ausência de sobreposição de cenas e nós da SceneTree:
## - Teste A: Reprodução do fluxo via playtest_guardiao.gd com transição limpa.
## - Teste B: Fluxo da campanha real a partir de main.tscn com transição limpa.
## - Teste C: Verificação estrita da SceneTree: exatamente 1 cena ativa (AbbeyChapter), Main/ForgottenCemetery totalmente desalocados.
## - Teste D: Verificação de HUD: vida máxima 6, nome da fase "ABADIA", setor 1 "Átrio dos Votos", sem labels de cemitério.
## - Teste E: Persistência de 6 HP no save isolado e ausência de duplicação.

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

	# Limpa saves na pasta de teste
	for name: String in DirAccess.get_files_at("user://"):
		if name.begins_with("cinzas_abbey_progress_v1"):
			DirAccess.remove_absolute(ProjectSettings.globalize_path("user://" + name))

	run_tests.call_deferred()

func run_tests() -> void:
	print("==================================================================")
	print("INICIANDO SUÍTE OFICIAL: BOSS1-TRANSITION-FIX02")
	print("==================================================================")

	# -------------------------------------------------------------------------
	# TESTE A: FLUXO DO SCRIPT DIRETO PLAYTEST_GUARDIAO
	# -------------------------------------------------------------------------
	print("\n--- TESTE A: Reprodução do fluxo do playtest_guardiao.gd ---")
	var main_node = MAIN_SCENE.instantiate()
	root.add_child(main_node)
	current_scene = main_node
	await _frames(4)

	var cemetery = main_node.get_node("ForgottenCemetery")
	var knight = cemetery.get_node("Knight") as KnightController
	var encounter = main_node.get_node("GuardianEncounter")
	knight.reset_to(Vector2(2300.0, 156.0))
	await _frames(2)

	encounter.enter()
	await _frames(4)

	var arena = encounter.arena
	var guardian = arena.get_node("Guardian") as OathGuardian
	var conclusion = arena.get_node("Guardian/Conclusion")

	# Derrota o Guardião
	guardian.awake = true
	while guardian.current_health > 0:
		while guardian.state in [OathGuardian.State.INTRO, OathGuardian.State.WAKE, OathGuardian.State.PHASE_TRANSITION, OathGuardian.State.HURT]:
			await _frames(2)
		if guardian.state == OathGuardian.State.DEFEATED:
			break
		guardian.receive_hit()
		await _frames(4)

	# Aguarda conclusão integral da animação (2.6s)
	while conclusion.running and conclusion.elapsed < conclusion.DURATION:
		await _frames(4)
	await _frames(6)

	check(conclusion.settled == true, "Cinemática do Guardião finalizada com sucesso")
	check(encounter.exit_unlocked == true, "Saída oriental da arena liberada após a cena")
	check(root.get_child_count() == 1, "Apenas 1 nó raiz (Main) antes da transição")

	# Aren atravessa a saída oriental
	knight.global_position.x = arena.global_position.x + 325.0
	for _i in range(8):
		await physics_frame
		await process_frame

	# -------------------------------------------------------------------------
	# TESTE C: VERIFICAÇÃO ESTRITA DA SCENETREE (PÓS-TRANSIÇÃO)
	# -------------------------------------------------------------------------
	print("\n--- TESTE C: Estado da SceneTree pós-transição ---")
	check(root.get_child_count() == 1, "TESTE C PASS: Exatamente 1 filho sob 'root' (sem nós duplicados ou vazamento)")
	var active_scene = root.get_child(0)
	check(active_scene.name == "AbbeyChapter", "TESTE C PASS: O único nó ativo é AbbeyChapter")
	check(current_scene == active_scene, "TESTE C PASS: get_tree().current_scene aponta legitimamente para AbbeyChapter")
	check(root.get_node_or_null("Main") == null, "TESTE C PASS: Cena 'Main' da Fase 1 foi completamente desalocada")
	check(root.find_child("ForgottenCemetery", true, false) == null, "TESTE C PASS: Nenhum nó do Cemitério permanece na SceneTree")
	check(root.find_child("GuardianEncounter", true, false) == null, "TESTE C PASS: Nenhum controlador do Guardião permanece ativo")

	# Aguarda conclusão do carregamento do setor 1 da Abadia
	while active_scene.busy:
		await process_frame

	# -------------------------------------------------------------------------
	# TESTE D: VERIFICAÇÃO DO HUD E ELEMENTOS VISUAIS
	# -------------------------------------------------------------------------
	print("\n--- TESTE D: Integridade do HUD e ausência de sobreposição ---")
	var abbey_hud = active_scene.get_node("ChapterHUD")
	var caption_label = abbey_hud.get_node("Caption") as Label
	var hint_label = abbey_hud.get_node("Hint") as Label
	var hero_abbey = active_scene.hero as KnightController

	check(is_instance_valid(abbey_hud), "HUD da Abadia presente")
	check(caption_label.text.contains("ABADIA"), "Cabeçalho exibe 'ABADIA'")
	check(caption_label.text.contains("Átrio dos Votos"), "Setor 1 exibido: 'Átrio dos Votos'")
	check(not caption_label.text.contains("Catedral"), "TESTE D PASS: Texto 'Portão da Catedral' ausente do cabeçalho")
	check(root.find_child("StageHUD", true, false) == null, "TESTE D PASS: StageHUD da Fase 1 inexistente")
	check(hero_abbey.survival.max_health == 6, "TESTE D PASS: Vida máxima de Aren preservada em 6 HP na Abadia")

	active_scene.queue_free()
	await _frames(4)

	# -------------------------------------------------------------------------
	# TESTE B: FLUXO COMPLETO DA CAMPANHA REAL (A PARTIR DE MAIN.TSCN)
	# -------------------------------------------------------------------------
	print("\n--- TESTE B: Fluxo da Campanha Real (iniciando em main.tscn) ---")
	# Limpa saves para testar campanha limpa
	for name: String in DirAccess.get_files_at("user://"):
		if name.begins_with("cinzas_abbey_progress_v1"):
			DirAccess.remove_absolute(ProjectSettings.globalize_path("user://" + name))

	var campaign_main = MAIN_SCENE.instantiate()
	root.add_child(campaign_main)
	current_scene = campaign_main
	await _frames(4)

	var camp_cemetery = campaign_main.get_node("ForgottenCemetery")
	var camp_knight = camp_cemetery.get_node("Knight") as KnightController
	var camp_encounter = campaign_main.get_node("GuardianEncounter")

	# Simula combate do Guardião na campanha
	camp_encounter.enter()
	await _frames(4)

	var camp_arena = camp_encounter.arena
	var camp_guardian = camp_arena.get_node("Guardian") as OathGuardian
	var camp_conclusion = camp_arena.get_node("Guardian/Conclusion")

	camp_guardian.awake = true
	while camp_guardian.current_health > 0:
		while camp_guardian.state in [OathGuardian.State.INTRO, OathGuardian.State.WAKE, OathGuardian.State.PHASE_TRANSITION, OathGuardian.State.HURT]:
			await _frames(2)
		if camp_guardian.state == OathGuardian.State.DEFEATED:
			break
		camp_guardian.receive_hit()
		await _frames(4)

	while camp_conclusion.running and camp_conclusion.elapsed < camp_conclusion.DURATION:
		await _frames(4)
	await _frames(6)

	check(camp_conclusion.settled == true, "Campanha real: cinematográfica concluída integralmente")
	check(camp_encounter.exit_unlocked == true, "Campanha real: saída oriental liberada")

	# Aren atravessa a saída oriental
	camp_knight.global_position.x = camp_arena.global_position.x + 325.0
	for _i in range(8):
		await physics_frame
		await process_frame

	check(root.get_child_count() == 1, "Campanha real: exatamente 1 filho em root após avanço")
	var camp_abbey = root.get_child(0)
	check(camp_abbey.name == "AbbeyChapter", "Campanha real: cena ativa é AbbeyChapter")
	check(camp_abbey.hero.survival.max_health == 6, "Campanha real: 6 HP preservados na Abadia")
	check(root.get_node_or_null("Main") == null, "Campanha real: 'Main' desalocado")

	camp_abbey.queue_free()
	await _frames(4)

	# -------------------------------------------------------------------------
	# TESTE E: PERSISTÊNCIA E NÃO-DUPLICAÇÃO
	# -------------------------------------------------------------------------
	print("\n--- TESTE E: Persistência do +1 HP Máximo no save isolado ---")
	check(ABBEY_PROGRESS.guardian_reward_unlocked() == true, "Progresso do Guardião salvo com sucesso")
	var reloaded_abbey = ABBEY_SCENE.instantiate()
	root.add_child(reloaded_abbey)
	current_scene = reloaded_abbey
	await _frames(4)
	check(reloaded_abbey.hero.survival.max_health == 6, "Nova instância carrega os 6 HP salvos")
	reloaded_abbey.queue_free()
	await _frames(2)

	print("\n==================================================================")
	print("RESULTADO BOSS1-TRANSITION-FIX02: %d verificações | %d PASS | %d FAIL" % [checks, checks - failures, failures])
	print("==================================================================")
	quit(1 if failures > 0 else 0)
