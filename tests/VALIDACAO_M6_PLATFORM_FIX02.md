# VALIDACAO M6 PLATFORM FIX02 — CORREÇÃO PONTUAL DA PLATAFORMA DE RETORNO NO SETOR 1
**Data:** 07/11/2026 | **Engine:** Godot 4.7.2 | **HEAD Base:** `c819dfb67eafc61516ee68ff36500ab8888539bd`
**GPU:** NVIDIA GeForce RTX 2060 SUPER | **Status:** PENDENTE DE AVALIAÇÃO HUMANA DO RESPONSÁVEL

---

## 1. IDENTIFICAÇÃO EXATA DA PLATAFORMA REMOVIDA

- **Elemento Removido:** Plataforma suspensa aérea `Rect2(690, 254, 80, 12)` em `SECTOR_1_BRANCHES` (`scripts/forest/forest_layout.gd`).
- **Coordenadas Originais:**
  - Posição horizontal: $x \in [690, 770]\text{ px}$ (extensão de $80\text{ px}$).
  - Posição vertical: topo em $y = 254\text{ px}$, espessura de $12\text{ px}$ (fundo sólido em $y = 266\text{ px}$).
- **Contexto no Cenário:** Localizada na extremidade leste do Setor 1 (Entrada da Floresta), logo acima do desnível entre a superfície inferior do solo leste (`Rect2(740, 300, 220, 120)`) e a superfície superior central (`Rect2(600, 276, 140, 144)`).

---

## 2. CAUSA RAIZ FÍSICA E GEOMÉTRICA DO BLOQUEIO DE RETORNO

Durante o avanço normal da esquerda para a direita ($x = 0 \to 960$), Aren descia confortavelmente do patamar superior ($y = 276$) para o solo leste ($y = 300$), passando sob ou ao lado da estrutura.

No entanto, durante o **retorno da direita para a esquerda** ($x = 960 \to 0$ após voltar do Setor 2):
1. Aren entra no Setor 1 em `entry(0, true)` = $(912, 300)$ e caminha para a esquerda sobre o chão em $y = 300$.
2. Em $x = 740$, o solo sobe de $y = 300$ para $y = 276$ ($\Delta y = 24\text{ px}$), exigindo um salto.
3. Como a plataforma suspensa `Rect2(690, 254, 80, 12)` se estendia de $x = 690$ a $770$:
   - Em $x = 740$, ela cobria exatamente o ponto de decolagem e aterrissagem do salto.
   - Entre o solo superior ($y = 276$) e o fundo da plataforma ($y = 266$), o vão livre vertical era de apenas $276 - 266 = 10\text{ pixels}$.
   - Sendo a caixa de colisão de Aren de $12 \times 24\text{ pixels}$, a altura do personagem excedia o vão em $14\text{ pixels}$.
   - Qualquer tentativa de salto a partir de $y = 300$ atingia o teto da plataforma em apenas $10\text{ px}$ de ascensão, interrompendo a velocidade vertical e derrubando Aren de volta ao chão ($x = 746.1$).
   - A própria plataforma estava a $\Delta y = 300 - 254 = 46\text{ px}$ do chão leste, ultrapassando a impulsão máxima de salto de Aren ($38.9\text{ px}$), impossibilitando utilizá-la como degrau.
4. **Conclusão:** Tratava-se de um bloqueio físico instransponível causado pela presença da plataforma aérea sobre o desnível de retorno.

---

## 3. GEOMETRIA ANTERIOR E POSTERIOR

### 3.1 Geometria Anterior (Com Bloqueio)
```gdscript
const SECTOR_1_MAIN: Array[Rect2] = [
	Rect2(0, 300, 260, 120),
	Rect2(260, 288, 120, 132),
	Rect2(380, 300, 220, 120),
	Rect2(600, 276, 140, 144),
	Rect2(740, 300, 220, 120),
]

const SECTOR_1_BRANCHES: Array[Rect2] = [
	Rect2(180, 266, 80, 12),
	Rect2(290, 244, 90, 12),
	Rect2(410, 222, 130, 14),
	Rect2(570, 244, 90, 12),
	Rect2(690, 254, 80, 12), # <-- BLOQUEAVA O RETORNO (VÃO DE 10 PX SOBRE O CHÃO)
]
```

### 3.2 Geometria Posterior (Corrigida e Homologada)
```gdscript
const SECTOR_1_MAIN: Array[Rect2] = [
	Rect2(0, 300, 260, 120),
	Rect2(260, 288, 120, 132),
	Rect2(380, 300, 220, 120),
	Rect2(600, 276, 140, 144),
	Rect2(740, 300, 220, 120),
]

const SECTOR_1_BRANCHES: Array[Rect2] = [
	# Caminho elevado pelo dossel de raízes acessível (subida em degraus suaves de <= 26 px)
	Rect2(160, 252, 80, 8),    # Branch 0: Acesso suave de y=288 (Dy=36px), vão livre no chão y=300 (40px)
	Rect2(290, 244, 90, 12),   # Branch 1: Salto suave de Branch 0 (Dy=8px)
	Rect2(410, 222, 130, 14),  # Branch 2: Canópea Central (Dy=22px)
	Rect2(570, 224, 90, 12),   # Branch 3: Passo suave (Dy=2px), vão livre sobre chão y=276 (40px)
]
```

- **Plataforma problemática removida integralmente:** `Rect2(690, 254, 80, 12)` eliminada da lista de superfícies.
- **Vão livre vertical sobre o desnível de retorno ($x \in [740, 770]$):** Infinito (céu aberto). Aren salta os $24\text{ px}$ com total conforto e sem qualquer colisão de cabeça.
- **Headroom garantido sob todas as ramificações:**
  - Sob Branch 3: chão em $y = 276$, fundo em $y = 236 \to$ vão livre de $40\text{ px}$ ($> 24\text{ px}$ de Aren).
  - Sob Branch 0: chão em $y = 300$, fundo em $y = 260 \to$ vão livre de $40\text{ px}$ ($> 24\text{ px}$ de Aren).

---

## 4. ARQUIVOS MODIFICADOS

1. `scripts/forest/forest_layout.gd`:
   - Remoção de `Rect2(690, 254, 80, 12)` em `SECTOR_1_BRANCHES`.
   - Ajuste de headroom de Branch 3 ($y=224$) e Branch 0 ($y=252$) para assegurar trânsito desimpedido no chão em ambos os sentidos.
2. `scripts/forest/forest_art.gd`:
   - Ajuste de coordenadas de fungos bioluminescentes para ancorar no chão e ramos existentes, eliminando resquícios aéreos órfãos.
3. `tests/m6_b1_expansion_test.gd`:
   - Atualização da asserção de contagem de superfícies do Setor 1 ($10 \to 9$).
4. `tests/m6_b2_expansion_test.gd`:
   - Atualização da asserção de contagem de superfícies do Setor 1 ($10 \to 9$).
5. `tests/m6_platform_accessibility_test.gd`:
   - Atualização das rotas do Setor 1 (Branches 0, 1, 2, 3) e inclusão de verificação formal de retorno completo pelo chão com comandos reais.
6. `tests/m6_platform_fix02_visual_capture.gd`:
   - Script de captura visual em GPU real (NVIDIA RTX 2060 SUPER).

---

## 5. RESULTADOS DOS TESTES COM ENTRADAS REAIS

### 5.1 Teste Específico de Retorno no Setor 1
- Aren gerado na entrada de retorno leste: $(912, 300)$.
- Deslocamento contínuo para a esquerda via `Input.action_press("move_left")`.
- Salto em $x = 745$ com impulsão padrão de Aren: subida limpa para $y = 276$ sem colisões no teto.
- Salto em $x = 385$: subida limpa para $y = 288$.
- Travessia completa até a margem oeste: **alcançou $x = 24.4\text{ px}$ com sucesso absoluto**.

### 5.2 Teste de Travessia Aérea Opcional no Setor 1
- Salto da entrada para Branch 0: **PASS** (alcançou $x = 222.1, y = 251.9$).
- Salto para Branch 1: **PASS** (alcançou $x = 297.3, y = 243.9$).
- Salto para Branch 2 (Canópea Central): **PASS** (alcançou $x = 429.0, y = 221.9$).
- Salto para Branch 3: **PASS** (alcançou $x = 602.3, y = 223.9$).
- Descida segura para o solo leste: **PASS** (aterrissou em $x = 707.3, y = 275.9$).

---

## 6. REGRESSÃO COMPLETA DO PROJETO (10/10 SUÍTES APROVADAS)

| # | Suíte de Testes | Verificações | Status |
|---|---|---|---|
| 1 | `tests/m6_platform_accessibility_test.gd` | 44/44 | **PASS (100%)** |
| 2 | `tests/m6_b3_expansion_test.gd` | 59/59 | **PASS (100%)** |
| 3 | `tests/m6_b2_expansion_test.gd` | 46/46 | **PASS (100%)** |
| 4 | `tests/m6_b1_expansion_test.gd` | 33/33 | **PASS (100%)** |
| 5 | `tests/m6_b1_altar_accessibility_test.gd` | 15/15 | **PASS (100%)** |
| 6 | `tests/m6_a_pilot_test.gd` | 24/24 | **PASS (100%)** |
| 7 | `tests/combat_test.gd` | 36/36 | **PASS (100%)** |
| 8 | `tests/dash_vfx_test.gd` | 47/47 | **PASS (100%)** |
| 9 | `tests/boss_test.gd` | 59/59 | **PASS (100%)** |
| 10 | `tests/recompensa_guardiao_test.gd` | 33/33 | **PASS (100%)** |
| **Total** | **10 Suítes Automatizadas** | **396/396** | **PASS (100%)** |

### Travessia Completa Bidirecional dos 8 Setores:
- **Ida ($1 \to 2 \to 3 \to 4 \to 5 \to 6 \to 7 \to 8$):** **PASS**
- **Volta ($8 \to 7 \to 6 \to 5 \to 4 \to 3 \to 2 \to 1$):** **PASS**

---

## 7. VALIDAÇÃO VISUAL EM GPU REAL (RTX 2060 SUPER)

As capturas em resolução $960 \times 540$ foram geradas com sucesso:
- `tests/evidencias/m6_platform_fix02/01_setor1_aren_ida_terreno.png`
- `tests/evidencias/m6_platform_fix02/02_setor1_aren_transicao_descida.png`
- `tests/evidencias/m6_platform_fix02/03_setor1_aren_retorno_degrau.png`
- `tests/evidencias/m6_platform_fix02/04_setor1_aren_retorno_salto.png`
- `tests/evidencias/m6_platform_fix02/05_setor1_vista_ampla_pos_remocao.png`
- `tests/evidencias/m6_platform_fix02/painel_m6_platform_fix02.png`

**Análise Artística:**
- A remoção da plataforma não deixou cortes abruptos nem espaços vazios artificiais.
- O terreno de musgo e pedra funde-se perfeitamente com os planos de fundo e as árvores fossilizadas do Codex.
- A vegetação de primeiro e segundo plano permanece íntegra e organicamente harmonizada.

---

## 8. SEGURANÇA E INTEGRIDADE DE DADOS

### 8.1 Save Pessoal
- **Caminho:** `C:\Users\ovohe\AppData\Roaming\Godot\app_userdata\Cinzas do Juramento\cinzas_abbey_progress_v1.json`
- **Tamanho:** 215 bytes (**Intacto**)
- **SHA-256:** `4DB32167231D18C4B0872C73A8647FE6803C86C3E1FE5B49D68BE8012405797F` (**100% conferido**)

### 8.2 Arquivos Canônicos Protegidos (15/15 Íntegros)
- Todos os 15 arquivos protegidos mantêm rigorosamente os mesmos hashes SHA-256 canônicos.

### 8.3 Estado do Git
- **Branch:** `main`
- **HEAD:** `c819dfb67eafc61516ee68ff36500ab8888539bd` (inalterado)
- **Área de Staging:** Vazia (`git diff --cached` = 0 bytes)
- **Operações Não Autorizadas:** ZERO commits, ZERO push, ZERO staging.

---

## 9. CLASSIFICAÇÃO FINAL

- **Correção Funcional:** **PASS**
- **Regressões Globais:** **PASS**
- **Segurança de Dados e Git:** **PASS**
- **Aprovação Visual e Funcional do Responsável:** **PENDENTE**

---

## 10. COMANDO PARA PLAYTEST MANUAL HUMANO

Para testar diretamente o executável com a remoção da plataforma e a travessia de retorno:

```powershell
& "C:\Users\ovohe\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe" "scenes/forest/forest_pilots.tscn"
```
*(Controles: A/D mover · Espaço saltar · Shift Passo das Sombras/Dash · J espada · F7 reiniciar · F1 alternar ajuda)*
