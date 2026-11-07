class_name ForestArt
extends Node2D
## Renderizador artístico de alta fidelidade e modularidade para a Floresta dos Ossos (M6-A / M6-B1).
## Elimina completamente colagens retangulares, recortes incorretos e duplicações.
## Utiliza assets pixel art dedicados e isolados com transparência alfa real em 320x180.

@export_range(0, 7, 1) var sector_id: int = 0

const BACKGROUNDS: Array[Texture2D] = [
	preload("res://assets/art/m6a/forest_sector1_bg.png"),
	preload("res://assets/art/m6a/forest_bosque_codex.png"),
	preload("res://assets/art/m6a/forest_sector3_bg.png"),
	preload("res://assets/art/m6a/forest_sector4_bg.png"),
	preload("res://assets/art/m6a/forest_sector5_bg.png"),
	preload("res://assets/art/m6a/forest_sector6_bg.png"),
	preload("res://assets/art/m6a/forest_sector7_bg.png"),
	preload("res://assets/art/m6a/forest_sector8_bg.png")
]
const MATERIAL: Texture2D = preload("res://assets/art/m6a/forest_materials.png")
const PROPS: Texture2D = preload("res://assets/art/m6a/forest_props.png")
const ORGANIC_GROUND: Texture2D = preload("res://assets/art/m6a/forest_ground_codex.png")
const ORGANIC_ROOT: Texture2D = preload("res://assets/art/m6a/forest_root_codex.png")

# Regiões no atlas de materiais (forest_materials.png - 1024x512)
const REG_PLATFORM_MID: Rect2 = Rect2(0, 0, 512, 48)
const REG_PLATFORM_LEFT: Rect2 = Rect2(512, 0, 128, 48)
const REG_PLATFORM_RIGHT: Rect2 = Rect2(640, 0, 128, 48)
const REG_ELEVATED_BRANCH: Rect2 = Rect2(0, 64, 512, 32)
const REG_LOAM_TILE: Rect2 = Rect2(0, 128, 128, 128)
const REG_MUSHROOM_1: Rect2 = Rect2(256, 128, 64, 64)
const REG_MUSHROOM_2: Rect2 = Rect2(320, 128, 64, 64)
const REG_BONE_SPURS: Rect2 = Rect2(448, 128, 64, 64)
const REG_LICHEN_VEIL: Rect2 = Rect2(576, 128, 64, 128)

# Regiões no atlas de adereços (forest_props.png - 1024x512)
const REG_COLOSSAL_TREE: Rect2 = Rect2(0, 0, 240, 480)
const REG_RIB_ARCH: Rect2 = Rect2(400, 0, 220, 220)
const REG_ANTLER_HORNS: Rect2 = Rect2(260, 240, 220, 180)
const REG_ALTAR_SHRINE: Rect2 = Rect2(640, 0, 280, 360)

# Paleta atmosférica gótica
const PAL_MOSS_EDGE: Color = Color("8ebc96")
const PAL_MOSS_DARK: Color = Color("233328")
const PAL_BONE_PALE: Color = Color("dcd5c2")
const PAL_BONE_SHADOW: Color = Color("5e594e")
const PAL_EARTH_DEEP: Color = Color("121a14")
const PAL_GLOW_HALO: Color = Color(0.27, 0.89, 0.58, 0.10)
const PAL_GLOW_CORE: Color = Color(0.58, 0.98, 0.81, 0.85)

var _view: Rect2 = Rect2(0, 0, 320, 180)
var _last_cell: Vector2i = Vector2i(-999, -999)
var _spore_timer: float = 0.0

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	z_index = -1

func _process(delta: float) -> void:
	_spore_timer += delta
	var camera: Camera2D = get_viewport().get_camera_2d()
	if camera == null:
		return
	var local: Vector2 = camera.get_screen_center_position() - global_position
	var cell: Vector2i = Vector2i(local.round())
	if cell != _last_cell or fmod(_spore_timer, 0.15) < delta:
		_last_cell = cell
		_view = Rect2(local.round() - Vector2(160, 90), Vector2(320, 180))
		queue_redraw()

func _draw() -> void:
	var cam_center: Vector2 = _view.get_center()
	var sector_center: Vector2 = Vector2(480, 210)
	var parallax_delta: Vector2 = cam_center - sector_center

	# Camada 1: Fundo panorâmico distante com céu tormentoso, lua e névoa
	_draw_background_panorama(parallax_delta)

	# Camada 2: Estruturas monumentais de midground (árvores de ossos petrificados com transparência real)
	_draw_midground_structures(parallax_delta)

	# Camada 3: Superfícies sólidas do plano de jogo (colisão física pixel-perfect e terreno orgânico)
	_draw_playfield_surfaces()

	# Camada 4: Cenografia específica (Altar no Setor 2, Abismo de travessia, Desfiladeiro do Setor 3, Clareira do Setor 4, Raízes Profundas do Setor 5, Ossuário do Setor 6)
	if sector_id == 1:
		_draw_sector_2_challenge_gap()
		_draw_sector_2_altar()
	elif sector_id == 2:
		_draw_sector_3_ravine()
	elif sector_id == 3:
		_draw_sector_4_clearing_features()
	elif sector_id == 4:
		_draw_sector_5_root_features()
	elif sector_id == 5:
		_draw_sector_6_ossuary_features()
	elif sector_id == 6:
		_draw_sector_7_vertebrae_features()
	elif sector_id == 7:
		_draw_sector_8_echo_features()

	# Camada 5: Acentos do cenário (fungos bioluminescentes, espículas de osso e líquens)
	_draw_ground_accents()

	# Camada 6: Esporos e bruma espectral viva
	_draw_ambient_spores(parallax_delta)

## 1. Fundo panorâmico distante
func _draw_background_panorama(delta: Vector2) -> void:
	var shift: Vector2 = delta * Vector2(0.12, 0.08)
	var bg_rect: Rect2 = Rect2(_view.position - Vector2(80, 30) - shift, Vector2(480, 240))
	var tint: Color = Color(0.90, 0.94, 0.98, 1.0)
	if sector_id == 1:
		tint = Color(0.92, 0.95, 0.98, 1.0)
	elif sector_id == 2:
		tint = Color(0.88, 0.94, 0.92, 1.0)
	elif sector_id == 3:
		tint = Color(0.90, 0.92, 0.96, 1.0)
	elif sector_id == 4:
		tint = Color(0.86, 0.95, 0.90, 1.0)
	elif sector_id == 5:
		tint = Color(0.88, 0.92, 0.96, 1.0)
	elif sector_id == 6:
		tint = Color(0.86, 0.94, 0.92, 1.0)
	elif sector_id == 7:
		tint = Color(0.85, 0.92, 0.96, 1.0)
	var bg_idx: int = clampi(sector_id, 0, BACKGROUNDS.size() - 1)
	draw_texture_rect(BACKGROUNDS[bg_idx], bg_rect, false, tint)

## 2. Árvores monumentais de marfim petrificado no plano intermediário
func _draw_midground_structures(_delta: Vector2) -> void:
	if sector_id == 0:
		# Posições das árvores colossais no Setor 1
		var trees: Array[Vector2] = [Vector2(140, 110), Vector2(480, 110), Vector2(800, 110)]
		for t_pos in trees:
			var tree_rect: Rect2 = Rect2(t_pos, Vector2(84, 190))
			if tree_rect.intersects(_view.grow(48)):
				draw_texture_rect_region(PROPS, tree_rect, REG_COLOSSAL_TREE, Color(0.72, 0.78, 0.82, 0.85))
	elif sector_id == 1:
		# Setor 2: Árvore colossal dominante no centro
		var tree_pos: Vector2 = Vector2(440, 96)
		var tree_rect: Rect2 = Rect2(tree_pos, Vector2(100, 220))
		if tree_rect.intersects(_view.grow(48)):
			draw_texture_rect_region(PROPS, tree_rect, REG_COLOSSAL_TREE, Color(0.75, 0.80, 0.85, 0.85))
	elif sector_id == 2:
		# Setor 3: Passagem dos Fósseis - árvores ancestrais retorcidas e arcos ósseos
		var trees: Array[Vector2] = [Vector2(220, 100), Vector2(680, 90)]
		for t_pos in trees:
			var tree_rect: Rect2 = Rect2(t_pos, Vector2(90, 200))
			if tree_rect.intersects(_view.grow(48)):
				draw_texture_rect_region(PROPS, tree_rect, REG_COLOSSAL_TREE, Color(0.70, 0.76, 0.80, 0.85))
		var rib_rect: Rect2 = Rect2(440, 150, 80, 80)
		if rib_rect.intersects(_view.grow(48)):
			draw_texture_rect_region(PROPS, rib_rect, REG_RIB_ARCH, Color(0.65, 0.72, 0.75, 0.70))
	elif sector_id == 3:
		# Setor 4: Clareira Ancestral - formação rochosa monumental e árvores na borda
		var trees: Array[Vector2] = [Vector2(130, 110), Vector2(780, 80)]
		for t_pos in trees:
			var tree_rect: Rect2 = Rect2(t_pos, Vector2(96, 210))
			if tree_rect.intersects(_view.grow(48)):
				draw_texture_rect_region(PROPS, tree_rect, REG_COLOSSAL_TREE, Color(0.74, 0.78, 0.82, 0.85))
	elif sector_id == 4:
		# Setor 5: Passagem das Raízes Profundas - túneis de raízes gigantes e arcos fósseis densos
		var trees: Array[Vector2] = [Vector2(160, 95), Vector2(780, 95)]
		for t_pos in trees:
			var tree_rect: Rect2 = Rect2(t_pos, Vector2(92, 205))
			if tree_rect.intersects(_view.grow(48)):
				draw_texture_rect_region(PROPS, tree_rect, REG_COLOSSAL_TREE, Color(0.68, 0.75, 0.72, 0.85))
		var rib1: Rect2 = Rect2(320, 160, 85, 85)
		if rib1.intersects(_view.grow(48)):
			draw_texture_rect_region(PROPS, rib1, REG_RIB_ARCH, Color(0.62, 0.70, 0.66, 0.75))
		var rib2: Rect2 = Rect2(650, 150, 85, 85)
		if rib2.intersects(_view.grow(48)):
			draw_texture_rect_region(PROPS, rib2, REG_RIB_ARCH, Color(0.62, 0.70, 0.66, 0.75))
	elif sector_id == 5:
		# Setor 6: Galeria dos Ossos Antigos - grande ossuário de costelas monumentais e arcos ogivais
		var tree_pos: Vector2 = Vector2(90, 85)
		var tree_rect: Rect2 = Rect2(tree_pos, Vector2(90, 215))
		if tree_rect.intersects(_view.grow(48)):
			draw_texture_rect_region(PROPS, tree_rect, REG_COLOSSAL_TREE, Color(0.70, 0.74, 0.78, 0.85))
		var ribs: Array[Vector2] = [Vector2(200, 130), Vector2(460, 120), Vector2(740, 100)]
		for r_pos in ribs:
			var rib_rect: Rect2 = Rect2(r_pos, Vector2(90, 90))
			if rib_rect.intersects(_view.grow(48)):
				draw_texture_rect_region(PROPS, rib_rect, REG_RIB_ARCH, Color(0.72, 0.76, 0.78, 0.80))
		var antlers: Rect2 = Rect2(360, 170, 70, 60)
		if antlers.intersects(_view.grow(48)):
			draw_texture_rect_region(PROPS, antlers, REG_ANTLER_HORNS, Color(0.68, 0.72, 0.74, 0.70))
	elif sector_id == 6:
		# Setor 7: Fenda das Vértebras - colunas espinhais fósseis inclinadas e arcos sobre o abismo
		var trees: Array[Vector2] = [Vector2(140, 80), Vector2(760, 85)]
		for t_pos in trees:
			var tree_rect: Rect2 = Rect2(t_pos, Vector2(94, 210))
			if tree_rect.intersects(_view.grow(48)):
				draw_texture_rect_region(PROPS, tree_rect, REG_COLOSSAL_TREE, Color(0.70, 0.75, 0.76, 0.85))
		var ribs: Array[Vector2] = [Vector2(320, 140), Vector2(540, 130)]
		for r_pos in ribs:
			var rib_rect: Rect2 = Rect2(r_pos, Vector2(96, 96))
			if rib_rect.intersects(_view.grow(48)):
				draw_texture_rect_region(PROPS, rib_rect, REG_RIB_ARCH, Color(0.72, 0.77, 0.75, 0.80))
		var antlers: Rect2 = Rect2(440, 180, 70, 60)
		if antlers.intersects(_view.grow(48)):
			draw_texture_rect_region(PROPS, antlers, REG_ANTLER_HORNS, Color(0.68, 0.74, 0.72, 0.75))
	elif sector_id == 7:
		# Setor 8: Bosque dos Ecos - abóbada natural de árvores e raízes ancestrais entrelaçadas
		var trees: Array[Vector2] = [Vector2(110, 75), Vector2(440, 70), Vector2(810, 75)]
		for t_pos in trees:
			var tree_rect: Rect2 = Rect2(t_pos, Vector2(98, 220))
			if tree_rect.intersects(_view.grow(48)):
				draw_texture_rect_region(PROPS, tree_rect, REG_COLOSSAL_TREE, Color(0.68, 0.76, 0.74, 0.85))
		var ribs: Array[Vector2] = [Vector2(260, 120), Vector2(620, 115)]
		for r_pos in ribs:
			var rib_rect: Rect2 = Rect2(r_pos, Vector2(88, 88))
			if rib_rect.intersects(_view.grow(48)):
				draw_texture_rect_region(PROPS, rib_rect, REG_RIB_ARCH, Color(0.66, 0.74, 0.72, 0.75))
		var antlers: Rect2 = Rect2(830, 160, 68, 60)
		if antlers.intersects(_view.grow(48)):
			draw_texture_rect_region(PROPS, antlers, REG_ANTLER_HORNS, Color(0.72, 0.78, 0.76, 0.80))

## 3. Superfícies sólidas do plano de jogo (Alinhamento 100% físico e orgânico)
func _draw_playfield_surfaces() -> void:
	for rect: Rect2 in ForestLayout.surfaces(sector_id):
		if not rect.intersects(_view.grow(48)):
			continue
		if rect.size.y <= 16.0:
			# Galhos elevados estreitos usam raiz sem trilho claro
			_draw_organic_surface(Rect2(rect.position, Vector2(rect.size.x, rect.size.y)))
			draw_texture_rect(ORGANIC_ROOT, Rect2(rect.position + Vector2(-2, 3), Vector2(rect.size.x + 4, 24)), false)
		else:
			_draw_organic_surface(rect)

	# Raízes ornamentais de conexão aos troncos e disfarce de repetição
	var root_positions: Array = []
	match sector_id:
		0:
			root_positions = [Vector2(112, 300), Vector2(454, 300), Vector2(774, 300)]
		1:
			root_positions = [Vector2(410, 316), Vector2(720, 288), Vector2(760, 268), Vector2(885, 268)]
		2:
			root_positions = [Vector2(80, 288), Vector2(240, 312), Vector2(420, 290), Vector2(650, 276), Vector2(820, 300)]
		3:
			root_positions = [Vector2(100, 300), Vector2(270, 270), Vector2(470, 300), Vector2(680, 280), Vector2(820, 260)]
		4:
			root_positions = [Vector2(90, 260), Vector2(240, 284), Vector2(420, 308), Vector2(620, 290), Vector2(850, 280)]
		5:
			root_positions = [Vector2(80, 280), Vector2(240, 298), Vector2(400, 278), Vector2(610, 260), Vector2(740, 240), Vector2(850, 220)]
		6:
			root_positions = [Vector2(80, 220), Vector2(240, 240), Vector2(380, 260), Vector2(580, 260), Vector2(720, 240), Vector2(850, 240)]
		7:
			root_positions = [Vector2(80, 240), Vector2(240, 260), Vector2(400, 280), Vector2(500, 260), Vector2(620, 260), Vector2(760, 240), Vector2(870, 240)]

	for root_pos: Vector2 in root_positions:
		var root_rect: Rect2 = Rect2(root_pos + Vector2(0, 1), Vector2(145, 48))
		if root_rect.intersects(_view.grow(32)):
			draw_texture_rect(ORGANIC_ROOT, root_rect, false, Color(0.8, 0.85, 0.82, 0.8))

func _draw_organic_surface(rect: Rect2) -> void:
	# Textura ancorada no mundo: a fase horizontal não reinicia a cada colisor.
	# O topo de musgo começa em y=130; a geometria física permanece autoritativa em y=0.
	var visible: Rect2 = rect.intersection(_view.grow(32))
	if not visible.has_area():
		return
	draw_rect(visible, PAL_EARTH_DEEP)
	var period: float = 384.0
	var scale_factor: float = float(ORGANIC_GROUND.get_width()) / period
	var max_depth: float = (float(ORGANIC_GROUND.get_height()) - 130.0) / scale_factor
	var material_rect: Rect2 = rect.intersection(Rect2(rect.position, Vector2(rect.size.x, minf(rect.size.y, max_depth))))
	var region: Rect2 = material_rect.intersection(visible)
	if not region.has_area():
		return
	var tile_start: int = floori(region.position.x / period)
	var tile_end: int = floori((region.end.x - 0.001) / period)
	for tile: int in range(tile_start, tile_end + 1):
		var clip: Rect2 = region.intersection(Rect2(tile * period, rect.position.y, period, max_depth))
		if not clip.has_area():
			continue
		var source: Rect2 = Rect2((clip.position.x - tile * period) * scale_factor, 130.0 + (clip.position.y - rect.position.y) * scale_factor, clip.size.x * scale_factor, clip.size.y * scale_factor)
		draw_texture_rect_region(ORGANIC_GROUND, clip, source)

## 4. Altar do Santuário do Cervo no Setor 2
func _draw_sector_2_altar() -> void:
	var altar_pos: Vector2 = Vector2(812, 196)
	var altar_size: Vector2 = Vector2(76, 52)
	if not Rect2(altar_pos, altar_size).intersects(_view.grow(32)):
		return

	draw_texture_rect_region(PROPS, Rect2(altar_pos, altar_size), REG_ALTAR_SHRINE)

	var flame_pos: Vector2 = Vector2(altar_pos.x + 38, altar_pos.y + 26)
	var pulse: float = 0.85 + 0.20 * sin(_spore_timer * 4.0)
	draw_circle(flame_pos, 8.0 * pulse, PAL_GLOW_HALO)
	draw_circle(flame_pos, 3.5 * pulse, PAL_GLOW_CORE)

	draw_string(ThemeDB.fallback_font, Vector2(810, 190), "SANTUÁRIO DO CERVO", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color("d4cfbe"))

## 5. Sinalização do desafio de travessia do abismo (Setor 2: 60 px)
func _draw_sector_2_challenge_gap() -> void:
	var gap: Rect2 = ForestLayout.get_sector_2_challenge_gap()
	if not gap.intersects(_view.grow(48)):
		return

	var mist_rect: Rect2 = Rect2(gap.position.x - 4, gap.position.y + 16, gap.size.x + 8, 80)
	draw_texture_rect_region(MATERIAL, mist_rect, REG_LICHEN_VEIL, Color(0.20, 0.50, 0.40, 0.35))

	var stake_x: float = gap.position.x - 20
	draw_line(Vector2(stake_x, gap.position.y), Vector2(stake_x, gap.position.y - 16), PAL_BONE_SHADOW, 2)
	draw_circle(Vector2(stake_x, gap.position.y - 16), 3.0, PAL_BONE_PALE)
	draw_circle(Vector2(stake_x, gap.position.y - 16), 5.0, PAL_GLOW_HALO)

## 6. Desfiladeiro fóssil do Setor 3
func _draw_sector_3_ravine() -> void:
	var ravine_pos: Vector2 = Vector2(540, 310)
	if not Rect2(ravine_pos, Vector2(50, 90)).intersects(_view.grow(48)):
		return
	var mist_rect: Rect2 = Rect2(536, 316, 58, 80)
	draw_texture_rect_region(MATERIAL, mist_rect, REG_LICHEN_VEIL, Color(0.20, 0.45, 0.38, 0.30))

## 7. Cenografia da Clareira Ancestral no Setor 4
func _draw_sector_4_clearing_features() -> void:
	var overlook_marker: Vector2 = Vector2(830, 190)
	if Rect2(overlook_marker, Vector2(64, 70)).intersects(_view.grow(32)):
		draw_texture_rect_region(PROPS, Rect2(overlook_marker, Vector2(64, 70)), REG_ANTLER_HORNS, Color(0.65, 0.70, 0.68, 0.75))
		var beacon_pos: Vector2 = overlook_marker + Vector2(32, 28)
		var pulse: float = 0.80 + 0.20 * sin(_spore_timer * 3.5)
		draw_circle(beacon_pos, 7.0 * pulse, PAL_GLOW_HALO)
		draw_circle(beacon_pos, 2.5 * pulse, PAL_GLOW_CORE)

## 8. Cenografia da Passagem das Raízes Profundas no Setor 5
func _draw_sector_5_root_features() -> void:
	# Vão entre raízes profundas (x=520 -> 568)
	var root_chasm: Rect2 = Rect2(520, 316, 48, 80)
	if root_chasm.intersects(_view.grow(48)):
		draw_texture_rect_region(MATERIAL, root_chasm, REG_LICHEN_VEIL, Color(0.18, 0.52, 0.38, 0.35))

	# Raiz fóssil transversal cruzando o alto
	var arch_rect: Rect2 = Rect2(480, 130, 100, 80)
	if arch_rect.intersects(_view.grow(32)):
		draw_texture_rect_region(PROPS, arch_rect, REG_RIB_ARCH, Color(0.60, 0.68, 0.64, 0.75))

## 9. Cenografia da Galeria dos Ossos Antigos no Setor 6
func _draw_sector_6_ossuary_features() -> void:
	# Vão do ossuário entre costelas (x=510 -> 555)
	var ossuary_gap: Rect2 = Rect2(510, 288, 45, 80)
	if ossuary_gap.intersects(_view.grow(48)):
		draw_texture_rect_region(MATERIAL, ossuary_gap, REG_LICHEN_VEIL, Color(0.20, 0.45, 0.48, 0.35))

	# Monumento do Grande Ossuário no Terraço Culminante (x=840..900, y=140)
	var monument_pos: Vector2 = Vector2(840, 130)
	if Rect2(monument_pos, Vector2(90, 90)).intersects(_view.grow(32)):
		draw_texture_rect_region(PROPS, Rect2(monument_pos, Vector2(90, 90)), REG_RIB_ARCH, Color(0.82, 0.86, 0.88, 0.85))
		draw_texture_rect_region(PROPS, Rect2(monument_pos + Vector2(18, 30), Vector2(54, 60)), REG_ANTLER_HORNS, Color(0.88, 0.90, 0.86, 0.90))
		var ember_pos: Vector2 = monument_pos + Vector2(45, 45)
		var pulse: float = 0.85 + 0.20 * sin(_spore_timer * 4.2)
		draw_circle(ember_pos, 8.0 * pulse, PAL_GLOW_HALO)
		draw_circle(ember_pos, 3.0 * pulse, PAL_GLOW_CORE)
		draw_string(ThemeDB.fallback_font, Vector2(830, 120), "GRANDE OSSUÁRIO", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color("d4cfbe"))

## 10. Cenografia da Fenda das Vértebras no Setor 7
func _draw_sector_7_vertebrae_features() -> void:
	# Vão da fenda sobre névoa espectral (x=480 -> 528)
	var fissure_gap: Rect2 = Rect2(480, 268, 48, 80)
	if fissure_gap.intersects(_view.grow(48)):
		draw_texture_rect_region(MATERIAL, fissure_gap, REG_LICHEN_VEIL, Color(0.18, 0.48, 0.44, 0.35))

	# Arcada óssea fóssil que atravessa o topo da fenda
	var spine_pos: Vector2 = Vector2(460, 140)
	if Rect2(spine_pos, Vector2(100, 90)).intersects(_view.grow(32)):
		draw_texture_rect_region(PROPS, Rect2(spine_pos, Vector2(100, 90)), REG_RIB_ARCH, Color(0.76, 0.82, 0.80, 0.85))
		var spine_light: Vector2 = spine_pos + Vector2(50, 40)
		var pulse: float = 0.80 + 0.20 * sin(_spore_timer * 3.8)
		draw_circle(spine_light, 7.5 * pulse, PAL_GLOW_HALO)
		draw_circle(spine_light, 2.8 * pulse, PAL_GLOW_CORE)

## 11. Cenografia do Bosque dos Ecos no Setor 8
func _draw_sector_8_echo_features() -> void:
	# Vão natural entre raízes ancestrais (x=520 -> 566)
	var echo_chasm: Rect2 = Rect2(520, 268, 46, 80)
	if echo_chasm.intersects(_view.grow(48)):
		draw_texture_rect_region(MATERIAL, echo_chasm, REG_LICHEN_VEIL, Color(0.16, 0.44, 0.42, 0.35))

	# Monólito e Altar dos Ecos no Terraço Culminante (x=840..900, y=150)
	var shrine_pos: Vector2 = Vector2(840, 145)
	if Rect2(shrine_pos, Vector2(85, 85)).intersects(_view.grow(32)):
		draw_texture_rect_region(PROPS, Rect2(shrine_pos, Vector2(85, 85)), REG_RIB_ARCH, Color(0.74, 0.82, 0.80, 0.85))
		draw_texture_rect_region(PROPS, Rect2(shrine_pos + Vector2(16, 26), Vector2(52, 55)), REG_ANTLER_HORNS, Color(0.80, 0.88, 0.84, 0.90))
		var echo_flame: Vector2 = shrine_pos + Vector2(42, 42)
		var pulse: float = 0.85 + 0.20 * sin(_spore_timer * 3.2)
		draw_circle(echo_flame, 9.0 * pulse, PAL_GLOW_HALO)
		draw_circle(echo_flame, 3.2 * pulse, PAL_GLOW_CORE)
		draw_string(ThemeDB.fallback_font, Vector2(835, 135), "MONÓLITO DOS ECOS", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color("d4cfbe"))

## 12. Acentos do cenário: cogumelos bioluminescentes e espículas de ossos
func _draw_ground_accents() -> void:
	var mushroom_spots: Array[Vector2] = []
	var bone_spots: Array[Vector2] = []

	match sector_id:
		0:
			mushroom_spots = [
				Vector2(110, 300), Vector2(230, 300), Vector2(350, 288),
				Vector2(490, 222), Vector2(650, 276), Vector2(820, 300), Vector2(880, 300)
			]
			bone_spots = [Vector2(170, 300), Vector2(420, 300), Vector2(710, 276)]
		1:
			mushroom_spots = [
				Vector2(80, 300), Vector2(170, 300), Vector2(310, 300),
				Vector2(510, 316), Vector2(730, 288), Vector2(945, 288)
			]
			bone_spots = [Vector2(150, 300), Vector2(380, 300), Vector2(745, 288)]
		2:
			mushroom_spots = [
				Vector2(90, 288), Vector2(210, 312), Vector2(380, 290),
				Vector2(620, 276), Vector2(800, 300), Vector2(280, 185), Vector2(680, 170)
			]
			bone_spots = [
				Vector2(130, 288), Vector2(290, 312), Vector2(480, 290),
				Vector2(710, 276), Vector2(890, 300)
			]
		3:
			mushroom_spots = [
				Vector2(70, 300), Vector2(230, 270), Vector2(420, 300),
				Vector2(520, 300), Vector2(640, 280), Vector2(790, 260),
				Vector2(320, 160), Vector2(700, 150)
			]
			bone_spots = [
				Vector2(160, 300), Vector2(310, 270), Vector2(480, 300),
				Vector2(730, 280), Vector2(860, 260)
			]
		4:
			mushroom_spots = [
				Vector2(90, 260), Vector2(220, 284), Vector2(370, 308),
				Vector2(470, 308), Vector2(610, 290), Vector2(760, 272),
				Vector2(880, 280), Vector2(280, 170), Vector2(630, 190)
			]
			bone_spots = [
				Vector2(140, 260), Vector2(300, 284), Vector2(490, 308),
				Vector2(680, 290), Vector2(850, 280)
			]
		5:
			mushroom_spots = [
				Vector2(80, 280), Vector2(230, 298), Vector2(380, 278),
				Vector2(600, 260), Vector2(730, 240), Vector2(820, 220),
				Vector2(910, 220), Vector2(270, 160), Vector2(640, 180)
			]
			bone_spots = [
				Vector2(130, 280), Vector2(280, 298), Vector2(440, 278),
				Vector2(580, 260), Vector2(720, 240), Vector2(795, 220),
				Vector2(880, 220), Vector2(940, 220)
			]
		6:
			mushroom_spots = [
				Vector2(70, 220), Vector2(220, 240), Vector2(360, 260),
				Vector2(570, 260), Vector2(720, 240), Vector2(840, 240),
				Vector2(920, 240), Vector2(280, 195), Vector2(630, 180)
			]
			bone_spots = [
				Vector2(120, 220), Vector2(270, 240), Vector2(420, 260),
				Vector2(610, 260), Vector2(750, 240), Vector2(890, 240)
			]
		7:
			mushroom_spots = [
				Vector2(80, 240), Vector2(220, 260), Vector2(390, 280),
				Vector2(500, 260), Vector2(610, 260), Vector2(750, 240),
				Vector2(860, 240), Vector2(930, 240), Vector2(310, 145), Vector2(670, 150)
			]
			bone_spots = [
				Vector2(140, 240), Vector2(290, 260), Vector2(430, 280),
				Vector2(590, 260), Vector2(780, 240), Vector2(900, 240)
			]

	for spot in mushroom_spots:
		if _view.grow(24).has_point(spot):
			var pulse: float = 0.85 + 0.15 * sin(_spore_timer * 2.8 + spot.x * 0.1)
			draw_circle(spot + Vector2(7, -6), 9.0 * pulse, PAL_GLOW_HALO)
			draw_texture_rect_region(MATERIAL, Rect2(spot + Vector2(0, -14), Vector2(14, 14)), REG_MUSHROOM_1, Color(1.0, 1.0, 1.0, pulse))

	for b_spot in bone_spots:
		if _view.grow(24).has_point(b_spot):
			draw_texture_rect_region(MATERIAL, Rect2(b_spot + Vector2(0, -12), Vector2(16, 12)), REG_BONE_SPURS, Color(0.85, 0.85, 0.82, 0.90))

## 9. Esporos bioluminescentes flutuantes
func _draw_ambient_spores(delta: Vector2) -> void:
	for i: int in range(16):
		var seed_val: int = i * 149
		var sp_x: float = fmod(float(seed_val) + _spore_timer * 12.0 - delta.x * 0.35, 960.0)
		var sp_y: float = 120.0 + fmod(float(seed_val * 23) + sin(_spore_timer * 1.5 + float(i)) * 14.0 - delta.y * 0.18, 220.0)

		var pos: Vector2 = Vector2(sp_x, sp_y)
		if _view.has_point(pos):
			var alpha: float = 0.25 + 0.20 * sin(_spore_timer * 2.2 + float(i))
			var r: float = 1.0 if (i % 2 == 0) else 1.5
			draw_circle(pos, r, Color(0.35, 0.92, 0.65, alpha))

## 10. Enquadramento de primeiro plano (Foreground)
func _draw_foreground_framing(delta: Vector2) -> void:
	var shift: Vector2 = delta * Vector2(-0.04, -0.02)
	for vx: int in range(int(_view.position.x / 120) * 120, int(_view.end.x) + 120, 120):
		var top_pos: Vector2 = Vector2(vx, _view.position.y - 4) + shift
		draw_texture_rect_region(MATERIAL, Rect2(top_pos, Vector2(32, 28)), REG_LICHEN_VEIL, Color(0.35, 0.42, 0.40, 0.55))
