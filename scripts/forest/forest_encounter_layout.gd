class_name ForestEncounterLayout
extends RefCounted
## Definição de dados dos encontros de inimigos e perigos da Floresta dos Ossos.
## Marco M6-C1: Setores 1 a 4. Marco M6-C2: Setores 5 a 8. Marco M6-C3: Setor 9.

const SECTOR_ENCOUNTERS: Dictionary = {
	0: [
		{
			"id": "E-01",
			"type": "crawler",
			"position": Vector2(450.0, 300.0),
			"patrol_left": -40.0,
			"patrol_right": 40.0,
			"facing": -1
		},
		{
			"id": "E-02",
			"type": "crawler",
			"position": Vector2(820.0, 300.0),
			"patrol_left": -45.0,
			"patrol_right": 35.0,
			"facing": -1
		}
	],
	1: [
		{
			"id": "E-03",
			"type": "crawler",
			"position": Vector2(330.0, 300.0),
			"patrol_left": -35.0,
			"patrol_right": 35.0,
			"facing": -1
		},
		{
			"id": "E-04",
			"type": "spectral_crow",
			"position": Vector2(520.0, 240.0),
			"patrol_half_width": 25.0,
			"facing": -1
		}
	],
	2: [
		{
			"id": "E-05",
			"type": "crawler",
			"position": Vector2(240.0, 312.0),
			"patrol_left": -35.0,
			"patrol_right": 35.0,
			"facing": 1
		},
		{
			"id": "E-06",
			"type": "spectral_crow",
			"position": Vector2(450.0, 200.0),
			"patrol_half_width": 25.0,
			"facing": -1
		},
		{
			"id": "E-07",
			"type": "sentinel",
			"position": Vector2(660.0, 276.0),
			"patrol_left": -30.0,
			"patrol_right": 30.0,
			"facing": -1
		},
		{
			"id": "P-01",
			"type": "fossil_spikes",
			"position": Vector2(480.0, 290.0)
		}
	],
	3: [
		{
			"id": "E-08",
			"type": "sentinel",
			"position": Vector2(480.0, 300.0),
			"patrol_left": -40.0,
			"patrol_right": 40.0,
			"facing": -1
		},
		{
			"id": "E-09",
			"type": "crawler",
			"position": Vector2(820.0, 260.0),
			"patrol_left": -40.0,
			"patrol_right": 40.0,
			"facing": -1
		}
	],
	4: [
		{
			"id": "E-10",
			"type": "crawler",
			"position": Vector2(290.0, 284.0),
			"patrol_left": -20.0,
			"patrol_right": 35.0,
			"facing": -1
		},
		{
			"id": "E-11",
			"type": "spectral_crow",
			"position": Vector2(450.0, 210.0),
			"patrol_half_width": 25.0,
			"facing": -1
		},
		{
			"id": "E-12",
			"type": "crawler",
			"position": Vector2(670.0, 290.0),
			"patrol_left": -25.0,
			"patrol_right": 35.0,
			"facing": -1
		}
	],
	5: [
		{
			"id": "E-13",
			"type": "crawler",
			"position": Vector2(290.0, 298.0),
			"patrol_left": -25.0,
			"patrol_right": 30.0,
			"facing": -1
		},
		{
			"id": "P-02",
			"type": "fossil_spikes",
			"position": Vector2(410.0, 278.0)
		},
		{
			"id": "E-14",
			"type": "sentinel",
			"position": Vector2(630.0, 260.0),
			"patrol_left": -25.0,
			"patrol_right": 25.0,
			"facing": -1
		},
		{
			"id": "E-15",
			"type": "crawler",
			"position": Vector2(750.0, 240.0),
			"patrol_left": -20.0,
			"patrol_right": 20.0,
			"facing": -1
		}
	],
	6: [
		{
			"id": "E-16",
			"type": "spectral_crow",
			"position": Vector2(250.0, 160.0),
			"patrol_half_width": 20.0,
			"facing": -1
		},
		{
			"id": "P-03",
			"type": "fossil_spikes",
			"position": Vector2(370.0, 260.0)
		},
		{
			"id": "E-18",
			"type": "sentinel",
			"position": Vector2(620.0, 260.0),
			"patrol_left": -20.0,
			"patrol_right": 35.0,
			"facing": -1
		},
		{
			"id": "E-17",
			"type": "spectral_crow",
			"position": Vector2(730.0, 170.0),
			"patrol_half_width": 25.0,
			"facing": -1
		}
	],
	7: [
		{
			"id": "E-19",
			"type": "sentinel",
			"position": Vector2(300.0, 260.0),
			"patrol_left": -20.0,
			"patrol_right": 25.0,
			"facing": -1
		},
		{
			"id": "E-20",
			"type": "crawler",
			"position": Vector2(430.0, 280.0),
			"patrol_left": -25.0,
			"patrol_right": 25.0,
			"facing": -1
		},
		{
			"id": "E-21",
			"type": "spectral_crow",
			"position": Vector2(650.0, 170.0),
			"patrol_half_width": 25.0,
			"facing": -1
		}
	],
	8: [
		{
			"id": "E-22",
			"type": "crawler",
			"position": Vector2(260.0, 260.0),
			"patrol_left": -25.0,
			"patrol_right": 25.0,
			"facing": -1
		},
		{
			"id": "P-04",
			"type": "fossil_spikes",
			"position": Vector2(360.0, 280.0)
		},
		{
			"id": "E-23",
			"type": "sentinel",
			"position": Vector2(610.0, 280.0),
			"patrol_left": -20.0,
			"patrol_right": 25.0,
			"facing": -1
		},
		{
			"id": "E-24",
			"type": "spectral_crow",
			"position": Vector2(740.0, 160.0),
			"patrol_half_width": 25.0,
			"facing": -1
		}
	]
}

static func get_encounters_for_sector(id: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if SECTOR_ENCOUNTERS.has(id):
		var raw: Array = SECTOR_ENCOUNTERS[id]
		for item: Dictionary in raw:
			result.append(item)
	return result

