class_name ForestSpectralCrowVisual
extends PixelCanvas
## Visual oficial em pixel-art animado do Corvo Espectral (M6-C1-ART-FIX03).
## Integração das spritesheets oficiais de batimento contínuo de asas e ataque de mergulho.

const ForestSpectralCrow = preload("res://scripts/enemies/forest_spectral_crow.gd")
const ATLAS: Texture2D = preload("res://assets/art/m6c1/crow_atlas.png")

const FLASH_WHITE: Color = Color("ffffff")
const EYE_AMBER: Color = Color("ffb84d")
const SHADE_DEAD: Color = Color(0.35, 0.32, 0.30, 0.85)

# Dimensões canônicas calibradas para a escala de gameplay:
# Célula padronizada 280 x 320 px com centro do corpo em (140, 160).
# No mundo do jogo: envergadura ~31 px, altura ~30 px.
const DEST_NORMAL: Rect2 = Rect2(-15.0, -17.1, 30.0, 34.3)
const CELL_SIZE: Vector2 = Vector2(280, 320)

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS

func _draw() -> void:
	var crow: ForestSpectralCrow = get_parent() as ForestSpectralCrow
	if crow == null:
		return
	
	if crow.state == ForestSpectralCrow.State.DEAD:
		_draw_dead()
		return
	
	var is_hurt: bool = crow.state == ForestSpectralCrow.State.HURT
	var is_alert: bool = crow.state == ForestSpectralCrow.State.ALERT
	var is_dive: bool = crow.state == ForestSpectralCrow.State.DIVE
	var is_recover: bool = crow.state == ForestSpectralCrow.State.RECOVER
	
	# Matriz de animação oficial (4 colunas x 2 linhas):
	# Linha 0 (Voo contínuo): 0: Flap Up | 1: Flap Mid | 2: Flap Down | 3: Flap Recover / Glide
	# Linha 1 (Mergulho / Ataque): 4: Alert asas abertas | 5: Windup preparação | 6: Active dive em seta | 7: Recover
	var frame: int = 0
	var hover_y: float = 0.0
	var dive_rot: float = 0.0
	
	if is_dive:
		# Pose ativa de mergulho: asas recolhidas em seta aerodinâmica apontada pelo vetor de velocidade
		frame = 6
		dive_rot = clampf(crow.velocity.y * 0.003, -0.4, 0.5)
	elif is_alert:
		# Alerta: primeira metade asas abertas, segunda metade preparação do mergulho
		if crow._timer > 0.20:
			frame = 4 # Alert asas abertas
		else:
			frame = 5 # Windup preparação
	elif is_recover:
		frame = 7 # Recuperação pós-mergulho
		hover_y = -1.0
	elif is_hurt:
		frame = 7
	else:
		# Voo contínuo batendo asas ativamente a ~8 FPS:
		# Sequência: Flap Up (0) -> Flap Mid (1) -> Flap Down (2) -> Flap Recover (3)
		var flap_step: int = int(crow.flight_time * 8.0) % 4
		frame = flap_step
		# Ondulação vertical suave acoplada ao empuxo das asas
		hover_y = -1.5 if frame == 2 else (1.0 if frame == 0 else 0.0)
	
	var col: int = frame % 4
	var row: int = frame / 4
	var region: Rect2 = Rect2(Vector2(col, row) * CELL_SIZE, CELL_SIZE)
	
	var tint: Color = Color(2.2, 2.4, 2.4, 1.0) if is_hurt else Color(1.12, 1.12, 1.12, 1.0)
	
	draw_set_transform(Vector2(0, hover_y), dive_rot, Vector2.ONE)
	draw_texture_rect_region(ATLAS, DEST_NORMAL, region, tint)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	
	# Telegrafia sutil de alerta (halo âmbar acima da cabeça, sem pontos azuis)
	if is_alert:
		halo(Vector2(8, -8), 4, EYE_AMBER)
	elif is_hurt:
		halo(Vector2(0, 0), 7, FLASH_WHITE)

func _draw_dead() -> void:
	# Queda inerte com o frame 7
	var region: Rect2 = Rect2(Vector2(3, 1) * CELL_SIZE, CELL_SIZE)
	draw_set_transform(Vector2(0, 4), 0.25, Vector2(0.85, 0.7))
	draw_texture_rect_region(ATLAS, DEST_NORMAL, region, SHADE_DEAD)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
