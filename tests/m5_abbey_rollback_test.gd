extends SceneTree
## Teste de validação técnica do MAPAS-ROLLBACK-01 (Abadia Silenciosa).
## Comprova a restauração dos Setores 3 e 9 e a ausência completa de artefatos experimentais.

const CHAPTER_SCENE: PackedScene = preload("res://scenes/abbey/abbey_chapter.tscn")

var checks: int = 0
var failures: int = 0

func check(ok: bool, msg: String) -> void:
	checks += 1
	if ok:
		print("PASS: ", msg)
	else:
		failures += 1
		printerr("FAIL: ", msg)

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	print("==================================================================")
	print("INICIANDO VALIDAÇÃO DO ROLLBACK (MAPAS-ROLLBACK-01)")
	print("==================================================================")

	var chapter = CHAPTER_SCENE.instantiate()
	root.add_child(chapter)

	while chapter.busy:
		await process_frame
	await process_frame
	await process_frame

	check(is_instance_valid(chapter), "Capítulo da Abadia instancia sem erros")

	# 1. Verifica os 12 setores e navegação básica
	check(AbbeyChapterLayout.NAMES.size() == 12, "Abadia possui exatamente 12 setores canônicos")

	# 2. Testa restauração do Setor 3 (Escadaria dos Contrapesos, id=2)
	await chapter.switch_room(2, false, true)
	while chapter.busy:
		await process_frame
	for i in range(6):
		await physics_frame

	check(chapter.current_room == 2, "Setor 3 carregado com sucesso (current_room == 2)")
	var sector3_node: Node2D = chapter.room
	check(is_instance_valid(sector3_node), "Node do Setor 3 ativo")
	check(sector3_node.get_node_or_null("CounterweightPortals") == null, "Setor 3 NÃO possui CounterweightPortals (portal experimental removido)")
	check(not ("in_counterweight_complex" in chapter), "Chapter NÃO possui variável in_counterweight_complex")

	# 3. Testa restauração do Setor 9 (Arquivo dos Juramentos, id=8)
	await chapter.switch_room(8, false, true)
	while chapter.busy:
		await process_frame
	for i in range(6):
		await physics_frame

	check(chapter.current_room == 8, "Setor 9 carregado com sucesso (current_room == 8)")
	var sector9_node: Node2D = chapter.room
	check(is_instance_valid(sector9_node), "Node do Setor 9 ativo")
	check(sector9_node.get_node_or_null("ScriptoriumEntrance") == null, "Setor 9 NÃO possui ScriptoriumEntrance (portal experimental removido)")
	check(sector9_node.get_node_or_null("UnsignedRecordGallery") != null, "Setor 9 preserva UnsignedRecordGallery canônica intacta")
	check(not ("in_scriptorium" in chapter), "Chapter NÃO possui variável in_scriptorium")

	# 4. Testa integridade dos atalhos M5-E
	check(chapter.SHORTCUTS != null, "Sistema de atalhos M5-E preservado")
	check(chapter.SHORTCUTS.LINKS.size() == 3, "Três atalhos de serviço M5-E cadastrados (real: %d)" % chapter.SHORTCUTS.LINKS.size())

	# 5. Testa integridade da arena do Abade (Setor 12, id=11)
	await chapter.switch_room(11, false, true)
	while chapter.busy:
		await process_frame
	for i in range(6):
		await physics_frame

	check(chapter.current_room == 11, "Setor 12 carregado com sucesso (current_room == 11)")
	check(is_instance_valid(chapter.ABBOT_ARENA), "Cena da Arena do Abade carregada e íntegra")

	chapter.queue_free()

	print("==================================================================")
	print("RESULTADO DO ROLLBACK: %d verificações | %d PASS | %d FAIL" % [checks, checks - failures, failures])
	print("==================================================================")
	quit(1 if failures > 0 else 0)
