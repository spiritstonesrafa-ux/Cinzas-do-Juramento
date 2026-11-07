class_name ForestLayout
extends RefCounted
## Geometria e configurações espaciais dos setores da Floresta dos Ossos (M6-A / M6-B1).

const ROOM_SIZE: Vector2 = Vector2(960, 420)
const ORIGINS: Array[Vector2] = [
	Vector2(0, 0),
	Vector2(1200, 0),
	Vector2(2400, 0),
	Vector2(3600, 0),
	Vector2(4800, 0),
	Vector2(6000, 0),
	Vector2(7200, 0),
	Vector2(8400, 0),
	Vector2(9600, 0),
	Vector2(10800, 0)
]
const NAMES: Array[String] = [
	"Entrada da Floresta",
	"Bosque das Raízes",
	"Passagem dos Fósseis",
	"Clareira Ancestral",
	"Passagem das Raízes Profundas",
	"Galeria dos Ossos Antigos",
	"Fenda das Vértebras",
	"Bosque dos Ecos",
	"Ravina das Sombras Fósseis",
	"Clareira da Bruma Espectral"
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
	# Caminho elevado pelo dossel de raízes acessível (subida em degraus suaves de <= 26 px)
	Rect2(160, 252, 80, 8),
	Rect2(290, 244, 90, 12),
	Rect2(410, 222, 130, 14),
	Rect2(570, 224, 90, 12),
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
	# Caminho elevado pelo dossel de raízes e costelas (acessível do solo oeste e do Santuário)
	Rect2(350, 276, 90, 12),
	Rect2(475, 252, 130, 14),
	Rect2(640, 246, 80, 12),
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
	# Caminho aéreo por galhos fossilizados (acesso do solo oeste <= 24 px e livre vão sobre o desfiladeiro)
	Rect2(120, 266, 80, 12),
	Rect2(230, 244, 90, 12),
	Rect2(350, 222, 110, 14),
	Rect2(480, 200, 110, 12),
	Rect2(620, 222, 90, 12),
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
	# Plataformas elevadas sobre arcos de ruínas góticas (acesso terraço oeste <= 22 px, livre para o mirante)
	Rect2(210, 248, 80, 12),
	Rect2(320, 226, 90, 14),
	Rect2(440, 204, 100, 14),
	Rect2(570, 190, 110, 14),
]

## Setor 5: Passagem das Raízes Profundas - túnel e fenda fechada dominada por raízes gigantes e arcos ósseos
const SECTOR_5_MAIN: Array[Rect2] = [
	# Patamar de entrada seguro (alinhado a y=260 com a saída do Setor 4)
	Rect2(0, 260, 180, 160),
	# Descida suave sob raízes monumentais (y=284, degrau acessível de 24 px)
	Rect2(180, 284, 160, 136),
	# Bacia inferior sombria entre raízes ancestrais (y=308, degrau acessível de 24 px)
	Rect2(340, 308, 180, 112),
	# GAP: x: 520 -> 568 (48 px - vão sobre abismo de raízes profundas, salto livre ou dash terrestre)
	# Patamar calcificado sob arcos ósseos (y=290, subida acessível de 18 px)
	Rect2(568, 290, 160, 130),
	# Degrau de pedra e raízes (y=272, subida acessível de 18 px)
	Rect2(728, 272, 100, 148),
	# Terraço de saída com raízes antigas (y=280, descida suave de 8 px para conectar ao Setor 6)
	Rect2(828, 280, 132, 140),
]

const SECTOR_5_BRANCHES: Array[Rect2] = [
	# Caminho aéreo por raízes suspensas e arcos fósseis (acesso bidirecional solo/terraço <= 22 px)
	Rect2(110, 238, 70, 12),
	Rect2(210, 216, 90, 12),
	Rect2(330, 216, 120, 14),
	Rect2(480, 228, 110, 14),
	Rect2(620, 250, 90, 12),
]

## Setor 6: Galeria dos Ossos Antigos - grande ossuário com costelas monumentais, vértebras e ruínas góticas
const SECTOR_6_MAIN: Array[Rect2] = [
	# Patamar de entrada seguro (alinhado a y=280 com a saída do Setor 5)
	Rect2(0, 280, 180, 140),
	# Galeria inferior do ossuário (y=298, descida de 18 px)
	Rect2(180, 298, 160, 122),
	# Patamar de vértebras fossilizadas (y=278, subida suave de 20 px)
	Rect2(340, 278, 170, 142),
	# GAP: x: 510 -> 555 (45 px - vão suave entre costelas caídas)
	# Nave de ruínas góticas ancestrais (y=260, subida suave de 18 px)
	Rect2(555, 260, 150, 160),
	# Degrau do santuário ossuário (y=240, subida acessível de 20 px)
	Rect2(705, 240, 80, 180),
	# Grande Terraço Monumental dos Ossos Antigos (y=220, subida acessível de 20 px)
	Rect2(785, 220, 175, 200),
]

const SECTOR_6_BRANCHES: Array[Rect2] = [
	# Plataformas aéreas formadas por costelas fósseis e arcos ogivais (acesso solo oeste <= 24 px, terraço <= 30 px)
	Rect2(110, 256, 75, 12),
	Rect2(215, 234, 85, 12),
	Rect2(330, 212, 100, 12),
	Rect2(460, 190, 150, 14),
]

## Setor 7: Fenda das Vértebras - fenda profunda com pontes de colunas vertebrais fósseis e névoa espectral
const SECTOR_7_MAIN: Array[Rect2] = [
	# Patamar de entrada seguro (alinhado a y=220 com a saída do Setor 6)
	Rect2(0, 220, 180, 200),
	# Descida suave sob espinhas fósseis (y=240, degrau acessível de 20 px)
	Rect2(180, 240, 140, 180),
	# Patamar rochoso e vértebras (y=260, degrau acessível de 20 px)
	Rect2(320, 260, 160, 160),
	# GAP: x: 480 -> 528 (48 px - vão sobre a fenda das vértebras, salto plano e retorno simétrico)
	# Patamar de pouso calcificado (y=260, plano idêntico ao lado oeste)
	Rect2(528, 260, 150, 160),
	# Subida suave em degrau fóssil (y=240, subida acessível de 20 px)
	Rect2(678, 240, 120, 180),
	# Terraço de saída para o Setor 8 (y=240, alinhado com o próximo setor)
	Rect2(798, 240, 162, 180),
]

const SECTOR_7_BRANCHES: Array[Rect2] = [
	# Caminho aéreo por costelas suspensas sobre a fenda (acesso entrada <= 24 px, livre vão da fenda)
	Rect2(100, 196, 75, 12),
	Rect2(205, 174, 85, 12),
	Rect2(320, 154, 90, 12),
	Rect2(440, 154, 110, 14),
	Rect2(580, 170, 90, 12),
]

## Setor 8: Bosque dos Ecos - abóbada vegetal ancestral, raízes entrelaçadas e monólitos sagrados
const SECTOR_8_MAIN: Array[Rect2] = [
	# Patamar de entrada seguro (alinhado a y=240 com a saída do Setor 7)
	Rect2(0, 240, 180, 180),
	# Descida suave em direção à clareira dos ecos (y=260, degrau acessível de 20 px)
	Rect2(180, 260, 170, 160),
	# Bacia central musgosa sob o dossel cerrado (y=280, degrau acessível de 20 px)
	Rect2(350, 280, 130, 140),
	# Patamar de impulsão elevado (y=260, degrau acessível de 20 px)
	Rect2(480, 260, 40, 160),
	# GAP: x: 520 -> 566 (46 px - vão atmosférico entre raízes antigas, salto plano nivelado)
	# Patamar de recepção leste (y=260, plano nivelado)
	Rect2(566, 260, 150, 160),
	# Subida suave ao terraço monumental (y=240, subida acessível de 20 px)
	Rect2(716, 240, 110, 180),
	# Terraço culminante dos Monólitos e margem leste (y=240, sólida para futuras expansões)
	Rect2(826, 240, 134, 180),
]

const SECTOR_8_BRANCHES: Array[Rect2] = [
	# Caminho elevado por cipós e galhos fossilizados (acesso entrada <= 24 px, livre vão dos ecos)
	Rect2(100, 216, 75, 12),
	Rect2(205, 194, 85, 12),
	Rect2(320, 172, 90, 12),
	Rect2(440, 154, 110, 14),
	Rect2(580, 172, 90, 12),
]

## Setor 9: Ravina das Sombras Fósseis - desfiladeiro cavernoso profundo, escarpas ósseas e abismo central
const SECTOR_9_MAIN: Array[Rect2] = [
	# Patamar de entrada seguro (alinhado a y=240 com a saída do Setor 8)
	Rect2(0, 240, 160, 180),
	# Descida suave para a ravina fóssil (y=260, degrau acessível de 20 px)
	Rect2(160, 260, 150, 160),
	# Patamar inferior da ravina oeste (y=280, degrau acessível de 20 px)
	Rect2(310, 280, 150, 140),
	# GAP: x: 460 -> 506 (46 px - vão sobre o abismo das sombras fósseis, salto plano e retorno simétrico)
	# Patamar inferior da ravina leste (y=280, recepção plana nivelada)
	Rect2(506, 280, 150, 140),
	# Subida suave em degrau de rocha e vértebras (y=260, subida acessível de 20 px)
	Rect2(656, 260, 150, 160),
	# Terraço de saída leste (y=260, conexão direta e nivelada ao Setor 10)
	Rect2(806, 260, 154, 160),
]

const SECTOR_9_BRANCHES: Array[Rect2] = [
	# Caminho elevado por costelas e pontes fósseis suspensas sobre a ravina (acesso entrada <= 24 px, vão livre)
	Rect2(100, 216, 75, 12),
	Rect2(205, 194, 85, 12),
	Rect2(320, 172, 90, 12),
	Rect2(440, 154, 110, 14),
	Rect2(580, 176, 90, 12),
	Rect2(700, 202, 80, 12),
	Rect2(805, 234, 75, 12),
]

## Setor 10: Clareira da Bruma Espectral - santuário e grande arena da futura batalha contra o Cervo Espectral
const SECTOR_10_MAIN: Array[Rect2] = [
	# Patamar de entrada seguro (alinhado a y=260 com a saída do Setor 9)
	Rect2(0, 260, 160, 160),
	# Piso monumental da Grande Arena de Combate (y=260 contínuo, 640 px de vão plano sem degraus)
	Rect2(160, 260, 640, 160),
	# Patamar do Altar Corrompido e Pórtico Rúnico Leste (y=260, margem extrema da fase)
	Rect2(800, 260, 160, 160),
]

const SECTOR_10_BRANCHES: Array[Rect2] = [
	# Abóbada catedralícia de costelas titânicas e poleiros táticos para evasão na arena (acessíveis com salto <= 26 px)
	Rect2(140, 234, 85, 12),
	Rect2(255, 210, 90, 12),
	Rect2(375, 186, 90, 12),
	Rect2(495, 186, 90, 12),
	Rect2(615, 210, 90, 12),
	Rect2(735, 234, 85, 12),
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
		4:
			result.assign(SECTOR_5_MAIN)
			result.append_array(SECTOR_5_BRANCHES)
		5:
			result.assign(SECTOR_6_MAIN)
			result.append_array(SECTOR_6_BRANCHES)
		6:
			result.assign(SECTOR_7_MAIN)
			result.append_array(SECTOR_7_BRANCHES)
		7:
			result.assign(SECTOR_8_MAIN)
			result.append_array(SECTOR_8_BRANCHES)
		8:
			result.assign(SECTOR_9_MAIN)
			result.append_array(SECTOR_9_BRANCHES)
		9:
			result.assign(SECTOR_10_MAIN)
			result.append_array(SECTOR_10_BRANCHES)
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
		4:
			if from_right:
				return ORIGINS[4] + Vector2(912, 280)
			return ORIGINS[4] + Vector2(48, 260)
		5:
			if from_right:
				return ORIGINS[5] + Vector2(912, 220)
			return ORIGINS[5] + Vector2(48, 280)
		6:
			if from_right:
				return ORIGINS[6] + Vector2(912, 240)
			return ORIGINS[6] + Vector2(48, 220)
		7:
			if from_right:
				return ORIGINS[7] + Vector2(912, 240)
			return ORIGINS[7] + Vector2(48, 240)
		8:
			if from_right:
				return ORIGINS[8] + Vector2(912, 260)
			return ORIGINS[8] + Vector2(48, 240)
		9:
			if from_right:
				return ORIGINS[9] + Vector2(912, 260)
			return ORIGINS[9] + Vector2(48, 260)
		_:
			return ORIGINS[0] + Vector2(48, 300)

static func get_sector_2_challenge_gap() -> Rect2:
	return Rect2(200, 300, 60, 120)
