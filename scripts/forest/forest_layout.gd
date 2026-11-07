class_name ForestLayout
extends RefCounted
## Geometria e configurações espaciais dos setores da Floresta dos Ossos (M6-A / M6-B1).

const ROOM_SIZE: Vector2 = Vector2(960, 420)
const ORIGINS: Array[Vector2] = [
	Vector2(0, 0),
	Vector2(1200, 0),
	Vector2(2400, 0),
	Vector2(3600, 0)
]
const NAMES: Array[String] = [
	"Entrada da Floresta",
	"Bosque das Raízes",
	"Passagem dos Fósseis",
	"Clareira Ancestral"
]

## Setor 1: Entrada horizontal com desníveis orgânicos, raízes baixas e caminho alto opcional
const SECTOR_1_MAIN: Array[Rect2] = [
	Rect2(0, 300, 260, 120),
	Rect2(260, 288, 120, 132),
	Rect2(380, 300, 220, 120),
	Rect2(600, 276, 140, 144),
	Rect2(740, 300, 220, 120),
]

const SECTOR_1_BRANCHES: Array[Rect2] = [
	Rect2(190, 246, 70, 12),
	Rect2(320, 222, 80, 12),
	Rect2(470, 174, 140, 14),
	Rect2(660, 220, 80, 12),
	Rect2(800, 160, 90, 12),
]

## Setor 2: Bosque das Raízes com abismo de travessia (Salto + Dash), dossel de costelas e retorno bidirecional
const SECTOR_2_MAIN: Array[Rect2] = [
	# Patamar de entrada seguro
	Rect2(0, 300, 200, 120),
	# GAP 1: x: 200 -> 260 (60 px - exige Dash no chão + Salto com momentum; salto normal cobre máx 56.7 px)
	# Patamar intermediário musgoso
	Rect2(260, 300, 170, 120),
	# Passagem inferior por tronco oco
	Rect2(430, 316, 220, 104),
	# GAP 2: x: 650 -> 704 (54 px)
	# Clareira diante do santuário
	Rect2(704, 288, 60, 132),
	# Degrau fóssil oeste do santuário (apoio intermediário: y=268, subida acessível de 20 px)
	Rect2(764, 268, 46, 152),
	# Patamar elevado do Altar do Cervo (y=246, subida acessível de 22 px)
	Rect2(810, 246, 80, 174),
	# Degrau fóssil leste do santuário (apoio intermediário: y=268, descida/subida acessível de 22 px)
	Rect2(890, 268, 44, 152),
	# Terraço de saída para o Setor 3 (y=288, descida/subida de 20 px)
	Rect2(934, 288, 26, 132),
]

const SECTOR_2_BRANCHES: Array[Rect2] = [
	# Caminho elevado pelo dossel de raízes e costelas
	Rect2(360, 238, 70, 12),
	Rect2(460, 184, 150, 14),
	Rect2(640, 210, 90, 12),
]

## Setor 3: Passagem dos Fósseis - corredor fóssil ancestral com raízes profundas e desfiladeiro
const SECTOR_3_MAIN: Array[Rect2] = [
	# Patamar de entrada (alinhado a y=288 com a saída do Setor 2)
	Rect2(0, 288, 180, 132),
	# Galeria inferior sob raízes gigantes
	Rect2(180, 312, 160, 108),
	# Patamar de pedra e vértebras fossilizadas
	Rect2(340, 290, 200, 130),
	# GAP: x: 540 -> 590 (50 px - travessia confortável com salto ou dash)
	# Patamar intermediário com dossel de arcos ósseos
	Rect2(590, 276, 170, 144),
	# Terraço de saída com raízes musgosas (y=300)
	Rect2(760, 300, 200, 120),
]

const SECTOR_3_BRANCHES: Array[Rect2] = [
	# Caminho aéreo por galhos fossilizados
	Rect2(140, 230, 80, 12),
	Rect2(260, 185, 120, 12),
	Rect2(430, 215, 90, 12),
	Rect2(650, 170, 130, 14),
	Rect2(810, 220, 90, 12),
]

## Setor 4: Clareira Ancestral - clareira gótica monumental com ruínas antigas e mirante
const SECTOR_4_MAIN: Array[Rect2] = [
	# Patamar de entrada (alinhado a y=300 com a saída do Setor 3)
	Rect2(0, 300, 200, 120),
	# Terraço elevado de rochas e ossadas semi-enterradas
	Rect2(200, 270, 180, 150),
	# Clareira central musgosa
	Rect2(380, 300, 220, 120),
	# Degraus de pedra calcificada ancestral
	Rect2(600, 280, 140, 140),
	# Mirante gótico final sobre o vale da floresta
	Rect2(740, 260, 220, 160),
]

const SECTOR_4_BRANCHES: Array[Rect2] = [
	# Plataformas elevadas sobre arcos de ruínas góticas
	Rect2(160, 210, 90, 12),
	Rect2(300, 160, 140, 14),
	Rect2(520, 195, 100, 12),
	Rect2(680, 150, 120, 14),
]

static func surfaces(id: int) -> Array[Rect2]:
	var result: Array[Rect2] = []
	match id:
		0:
			result.assign(SECTOR_1_MAIN)
			result.append_array(SECTOR_1_BRANCHES)
		1:
			result.assign(SECTOR_2_MAIN)
			result.append_array(SECTOR_2_BRANCHES)
		2:
			result.assign(SECTOR_3_MAIN)
			result.append_array(SECTOR_3_BRANCHES)
		3:
			result.assign(SECTOR_4_MAIN)
			result.append_array(SECTOR_4_BRANCHES)
		_:
			result.assign(SECTOR_2_MAIN)
			result.append_array(SECTOR_2_BRANCHES)
	return result

static func entry(id: int, from_right: bool = false) -> Vector2:
	match id:
		0:
			if from_right:
				return ORIGINS[0] + Vector2(912, 300)
			return ORIGINS[0] + Vector2(48, 300)
		1:
			if from_right:
				return ORIGINS[1] + Vector2(912, 288)
			return ORIGINS[1] + Vector2(48, 300)
		2:
			if from_right:
				return ORIGINS[2] + Vector2(912, 300)
			return ORIGINS[2] + Vector2(48, 288)
		3:
			if from_right:
				return ORIGINS[3] + Vector2(912, 260)
			return ORIGINS[3] + Vector2(48, 300)
		_:
			return ORIGINS[0] + Vector2(48, 300)

static func get_sector_2_challenge_gap() -> Rect2:
	return Rect2(200, 300, 60, 120)
