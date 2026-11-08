class_name ForestCrawlerVisual
extends PixelCanvas
## Visual oficial em pixel-art animado do Rastejante Fóssil (M6-C1-ART-FIX03).
## Integração das spritesheets oficiais de caminhada e mordida em quadros reais desenhados.

const ForestCrawler = preload("res://scripts/enemies/forest_crawler.gd")
const ATLAS: Texture2D = preload("res://assets/art/m6c1/crawler_atlas.png")

const EYE_AMBER: Color = Color("ffb84d")
const FLASH_WHITE: Color = Color("ffffff")
const SHADE_DEAD: Color = Color(0.35, 0.32, 0.30, 0.85)

# Dimensões canônicas calibradas para a escala de gameplay:
# Célula padronizada 360 x 140 px com pés alinhados em y=130 px.
# No mundo do jogo: altura ~22 px, largura ~49 px, pés em y=0.
const DEST_NORMAL: Rect2 = Rect2(-30.6, -24.9, 68.9, 26.8)
const CELL_SIZE: Vector2 = Vector2(360, 140)

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS

func _draw() -> void:
	var crawler: ForestCrawler = get_parent() as ForestCrawler
	if crawler == null:
		return
	
	if crawler.state == ForestCrawler.State.DEAD:
		_draw_dead()
		return
	
	var is_hurt: bool = crawler.state == ForestCrawler.State.HURT
	var is_windup: bool = crawler.state == ForestCrawler.State.ATTACK and crawler.attack_phase == ForestCrawler.AttackPhase.WINDUP
	var is_active: bool = crawler.state == ForestCrawler.State.ATTACK and crawler.attack_phase == ForestCrawler.AttackPhase.ACTIVE
	var is_recovery: bool = crawler.state == ForestCrawler.State.ATTACK and crawler.attack_phase == ForestCrawler.AttackPhase.RECOVERY
	var is_moving: bool = crawler.velocity.x != 0.0
	
	# Matriz de animação oficial (4 colunas x 2 linhas):
	# Linha 0 (Caminhada): 0: Pata avançada | 1: Transição comprimida | 2: Passada oposta | 3: Recuperação
	# Linha 1 (Mordida/Ataque): 4: Windup agachado | 5: Antecipação mandíbula | 6: Bote ativo | 7: Recovery
	var frame: int = 0
	var offset: Vector2 = Vector2.ZERO
	
	if is_windup:
		# Windup tem telegrafia de 0.30s: primeira metade agachamento, segunda metade mandíbula abrindo
		if crawler._timer > 0.15:
			frame = 4 # Pose 1 de ataque: agachado preparando bote
		else:
			frame = 5 # Pose 2 de ataque: antecipação mandíbula abrindo
		var tremor: float = sin(Time.get_ticks_msec() * 0.05) * 0.5
		offset = Vector2(tremor, 0)
	elif is_active:
		# Pose 3 de ataque: investida com corpo estendido e mandíbula aberta (janela de dano ativa)
		frame = 6
		offset = Vector2(2, 0)
	elif is_recovery:
		# Pose 4 de ataque: recolhimento do corpo e retorno à postura normal
		frame = 7
		offset = Vector2(1, 0)
	elif is_hurt:
		# Reação visual de dano com recuo
		frame = 7
	elif is_moving:
		# Ciclo rítmico de 4 passadas reais sincronizado com a velocidade
		var step: int = absi(int(crawler.global_position.x / 10.0)) % 4
		frame = step
	else:
		# Pose de repouso (quadro neutro apoiado no solo)
		frame = 0
	
	var col: int = frame % 4
	var row: int = frame / 4
	var region: Rect2 = Rect2(Vector2(col, row) * CELL_SIZE, CELL_SIZE)
	
	var tint: Color = Color(2.2, 2.2, 2.2, 1.0) if is_hurt else Color(1.15, 1.15, 1.12, 1.0)
	
	draw_set_transform(offset, 0.0, Vector2.ONE)
	draw_texture_rect_region(ATLAS, DEST_NORMAL, region, tint)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	
	# Telegrafia luminosa âmbar durante o WINDUP (sem nenhum marcador azul)
	if is_windup:
		halo(Vector2(18, -9) + offset, 4, EYE_AMBER)
	elif is_active:
		l(Vector2(-20, -10), Vector2(-12, -10), Color("ded8cb", 0.5), 2)
	elif is_hurt:
		halo(Vector2(0, -11), 7, FLASH_WHITE)

func _draw_dead() -> void:
	# Carapaça tombada inerte no solo
	var region: Rect2 = Rect2(Vector2(3, 1) * CELL_SIZE, CELL_SIZE)
	draw_set_transform(Vector2(0, -2), PI * 0.95, Vector2(0.95, 0.9))
	draw_texture_rect_region(ATLAS, DEST_NORMAL, region, SHADE_DEAD)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
