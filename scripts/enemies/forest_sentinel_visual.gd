class_name ForestSentinelVisual
extends PixelCanvas
## Visual oficial em pixel-art animado do Sentinela Ósseo (M6-C1-ART-FIX03).
## Integração das spritesheets oficiais de marcha cadenciada e ataque pesado devastador.

const ForestSentinel = preload("res://scripts/enemies/forest_sentinel.gd")
const ATLAS: Texture2D = preload("res://assets/art/m6c1/sentinel_atlas.png")

const EYE_AMBER: Color = Color("ffb84d")
const FLASH_WHITE: Color = Color("ffffff")
const SHADE_DEAD: Color = Color(0.35, 0.32, 0.30, 0.85)

# Dimensões canônicas calibradas para a escala de gameplay:
# Célula padronizada 340 x 336 px com pés alinhados em y=325 px.
# No mundo do jogo: altura ~44 px, largura ~39 px, pés em y=0.
const DEST_NORMAL: Rect2 = Rect2(-23.9, -48.5, 50.7, 50.1)
const CELL_SIZE: Vector2 = Vector2(340, 336)

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS

func _draw() -> void:
	var sentinel: ForestSentinel = get_parent() as ForestSentinel
	if sentinel == null:
		return
	
	if sentinel.state == ForestSentinel.State.DEAD:
		_draw_dead()
		return
	
	var is_hurt: bool = sentinel.state == ForestSentinel.State.HURT or sentinel.is_flashing_poise()
	var is_windup: bool = sentinel.state == ForestSentinel.State.ATTACK and sentinel.attack_phase == ForestSentinel.AttackPhase.WINDUP
	var is_active: bool = sentinel.state == ForestSentinel.State.ATTACK and sentinel.attack_phase == ForestSentinel.AttackPhase.ACTIVE
	var is_recovery: bool = sentinel.state == ForestSentinel.State.ATTACK and sentinel.attack_phase == ForestSentinel.AttackPhase.RECOVERY
	var is_moving: bool = sentinel.velocity.x != 0.0
	
	# Matriz de animação oficial (4 colunas x 2 linhas):
	# Linha 0 (Marcha): 0: Passo esquerdo | 1: Transferência de peso | 2: Passo direito | 3: Retorno à postura
	# Linha 1 (Golpe Devastador): 4: Ready inicial | 5: Windup cutelo no alto | 6: Active slam no solo | 7: Recovery
	var frame: int = 0
	
	if is_windup:
		# Telegrafia de 0.45s: primeira fase preparando subida do cutelo, segunda fase lâmina no alto com poise
		if sentinel._timer > 0.30:
			frame = 4 # Ready inicial
		else:
			frame = 5 # Windup: cutelo colossal erguido acima da cabeça com as duas mãos e poise
	elif is_active:
		# Golpe descendente cravando a lâmina no solo (janela de dano ativa)
		frame = 6
	elif is_recovery:
		# Recuperação: cutelo apoiado no chão, vulnerável ao contra-ataque do jogador
		frame = 7
	elif is_hurt:
		# Recuo de atordoamento
		frame = 7
	elif is_moving:
		# Ciclo de marcha pesada com alternância das pernas a cada 12 px de deslocamento
		var step: int = absi(int(sentinel.global_position.x / 12.0)) % 4
		frame = step
	else:
		# Postura ereta de repouso (quadro 1 de marcha neutra)
		frame = 1
	
	var col: int = frame % 4
	var row: int = frame / 4
	var region: Rect2 = Rect2(Vector2(col, row) * CELL_SIZE, CELL_SIZE)
	
	var tint: Color = Color(2.4, 2.4, 2.2, 1.0) if is_hurt else Color(1.15, 1.15, 1.12, 1.0)
	
	draw_texture_rect_region(ATLAS, DEST_NORMAL, region, tint)
	
	# Telegrafia luminosa âmbar no cutelo durante o WINDUP com POISE ativo (sem marcadores azuis)
	if is_windup:
		halo(Vector2(14, -46), 6, EYE_AMBER)
		if sentinel.is_flashing_poise():
			halo(Vector2(0, -22), 10, FLASH_WHITE)
	elif is_active:
		# Impacto do cutelo contra o solo
		l(Vector2(14, 0), Vector2(30, 0), Color("ded8cb", 0.9), 2)
		l(Vector2(18, -2), Vector2(26, -8), Color("ded8cb", 0.6), 1)
	elif is_hurt:
		halo(Vector2(0, -20), 8, FLASH_WHITE)

func _draw_dead() -> void:
	# Pilha de ossos fossilizados e cutelo tombado no chão
	var region: Rect2 = Rect2(Vector2(3, 1) * CELL_SIZE, CELL_SIZE)
	draw_set_transform(Vector2(0, -3), -PI/2, Vector2(0.85, 0.85))
	draw_texture_rect_region(ATLAS, DEST_NORMAL, region, SHADE_DEAD)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
