# RELATÓRIO TÉCNICO DE VALIDAÇÃO — REFINAMENTO VISUAL DO DASH DE AREN (PASSO DAS SOMBRAS)
**Projeto:** Cinzas do Juramento<br>
**Engine:** Godot 4.7.2 (Windows, GPU NVIDIA RTX 2060 SUPER)<br>
**Resolução Lógica Interna:** 320 × 180 (Escala Inteira 960 × 540)<br>
**Data:** 06/11/2026<br>
**Responsável Técnico:** Google Antigravity (Engenheiro Sênior Godot 4 / GDScript)

---

## 1. Resumo da Melhoria Visual Implementada

O dash de Aren (*Passo das Sombras*), recompensa permanente assimilada após a vitória sobre o Abade das Correntes (M5-G), contava com uma representação preliminar rudimentar baseada em 4 retângulos cinzas opacos e pós-imagens de cor única.

Nesta intervenção, o efeito foi reformulado visualmente em conformidade direta com a **direção visual fornecida na imagem de referência** (painel triplo de estética gótica pixel art com energia arcana violeta):
- **Origem e Lançamento:** Sigilo gótico ornamental em cruz floriada com halo concêntrico e arco etéreo crescente projetando-se atrás da silhueta de Aren, acompanhado de faíscas radiais no chão e dispersão física de cascalho e poeira lilás.
- **Deslocamento / Trilha:** Rastro linear duplo de raspagem no chão (*laser floor scrape*) com faíscas horizontais de atrito, emissão de tufos de névoa escura e violeta (*wisps*), ecos residuais (*afterimages*) escalonados com decaimento suave de opacidade, além do sigilo de lançamento que permanece estático no ar no ponto de partida em coordenadas de mundo até se dissipar elegantemente.
- **Frenagem e Parada:** Ao término da distância ou impacto contra parede sólida, impacto com faíscas afiadas projetadas para frente no piso, cascalho de pedra arremessado à frente pela inércia da frenagem e dissipação harmoniosa do rastro.
- **Orientação Direcional:** Renderização com suporte nativo e simétrico para esquerda (`facing = -1`) e direita (`facing = 1`), preservando integridade espacial através do espaço de coordenadas globais do `CanvasItem`.

---

## 2. Incorporação dos Elementos da Imagem de Referência

A imagem de referência oficial de 3 painéis (`media_1793974603062_ed364131.jpg`) orientou cada componente:

| Elemento da Referência | Implementação em Godot 4 / GDScript | Paleta de Cores Aplicada |
| :--- | :--- | :--- |
| **Painel 1 — Início (Arco & Sigilo)** | Sigilo gótico em cruz floriada com diamante central de alto brilho e arco crescente sweeping na origem | Neon Violet `#d973ff`, Specular Core `#f5e6ff`, Glow `#b859e6` |
| **Painel 1 — Faíscas no Solo** | 6 linhas radiais afiadas de impacto no piso (`draw_line`) partindo do pé de apoio com comprimentos de 5 a 18 px | Floor Spark `#eb8cff`, Bright Center `#ffffff` |
| **Painel 1 — Detritos Iniciais** | 5 partículas de pedra com gravidade (+220 px/s²) e 3 tufos de poeira lilás projetados para trás | Stone `#473e52`, Dust `#85669e` |
| **Painel 2 — Sigilo Persistente** | Sigilo e arco permanecem ancorados na coordenada global de partida por 0.28s mesmo enquanto Aren avança | Alpha Decay dinâmico `clampf(_dash_start_timer / 0.28, 0, 1)` |
| **Painel 2 — Raspagem no Chão** | Linha dupla horizontal no piso entre a origem `_dash_start_pos.x` e `hero.global_position.x` | Outer `#a640e0` (largura 2px), Core `#faebff` (largura 1px) |
| **Painel 2 — Ecos / Afterimages** | Até 4 silhuetas de Aren em pose de corrida atlética (`FRAME_RECTS[4]`) com decaimento temporal rápido (0.20s) | Silhouette Shadow `#401f59`, Main Ghost `#ad57fa` |
| **Painel 2 — Névoa e Fumaça** | Tufos circulares concêntricos de névoa sombria com turbulência vertical leve | Dark Smoke `#4d246b`, Deep Violet `#8c38cc` |
| **Painel 3 — Frenagem Final** | Feixe frontal de faíscas em cunha projetado para frente na parada da corrida e contato com piso/parede | Electric Violet `#f299ff`, Spark Core `#ffffff` |
| **Painel 3 — Projeção de Cascalho** | Pedras e cascalho saltando para frente no sentido do movimento pela inércia da desaceleração | Stone `#473e52`, Highlight `#70617a` |

---

## 3. Preservação Absoluta das Regras de Gameplay e Física

Nenhum parâmetro de física, controle ou combate foi alterado:
- **Velocidade do Dash (`dash_speed`):** Preservada em `260.0 px/s`.
- **Duração do Movimento (`dash_duration`):** Preservada em `0.16s`.
- **Cooldown (`dash_cooldown`):** Preservado em `0.75s`.
- **Hitboxes / Hurtboxes:** Sem alterações na detecção de dano recebido ou infligido.
- **Invulnerabilidade:** Inexistente durante o dash (conforme regra canônica homologada em M5-G).
- **Parada em Parede:** Mantida com precisão: `if is_on_wall(): dash_remaining = 0.0`.
- **Persistência e Desbloqueio:** Regras de `ABBEY_PROGRESS.unlocked()` e salvamento em `cinzas_abbey_progress_v1.json` 100% inalteradas.

---

## 4. Resultados dos Testes Automatizados

Todos os testes foram executados em ambiente isolado (`$env:APPDATA = .godot\isolated_test_appdata`):

### 4.1. Nova Suíte Dedicada — `tests/dash_vfx_test.gd`
- **Total de verificações:** 47
- **Falhas:** 0 (100% PASS)
- **Cenários Cobertos:**
  1. *Dash para a Direita:* Ativação, temporizador de início, facing +1, dispersão de cascalho para trás (vel.x < 0), tufos de poeira, ecos/afterimages, névoa violeta, linha de raspagem, temporizador de frenagem e cascalho projetado para frente.
  2. *Dash para a Esquerda:* Espelhamento simétrico de todas as propriedades e vetores (facing -1, cascalho de partida vel.x > 0, afterimages facing -1, cascalho de frenagem vel.x < 0).
  3. *Colisão com Parede Sólida:* Interrupção imediata do deslocamento (`dash_remaining == 0`) e disparo limpo dos efeitos de frenagem e impacto no ponto de colisão.
  4. *Morte do Jogador:* Limpeza instantânea de todos os arrays de partículas, ecos, névoa e zeramento imediato dos temporizadores.
  5. *Conformidade de Cooldown:* Tentativas de acionamento sob cooldown (`dash_cooldown_remaining > 0`) não disparam sigilos, detritos ou sons falsos.
  6. *Reset e Respawn:* Cancelamento e limpeza de estado ao chamar `reset_to()`.

### 4.2. Suítes de Regressão Consolidadas
| Arquivo de Teste | Checks | Falhas | Status |
| :--- | :---: | :---: | :---: |
| `tests/dash_vfx_test.gd` | 47 | 0 | **PASS** |
| `tests/combat_test.gd` | 36 | 0 | **PASS** |
| `tests/boss_test.gd` | 59 | 0 | **PASS** |
| `tests/m5_h_fix01_physics.gd` | 62 | 0 | **PASS** |
| `tests/m5_h_fix01_spawns.gd` | 42 | 0 | **PASS** |
| `tests/m5_h_aerial_test.gd` | 16 | 0 | **PASS** |
| `tests/recompensa_guardiao_test.gd` | 33 | 0 | **PASS** |
| `tests/abbot_cinematic_test.gd` | 26 | 0 | **PASS** |
| **TOTAL GERAL** | **321** | **0** | **100% APROVADO** |

---

## 5. Evidências Visuais Geradas

As capturas foram geradas pelo pipeline GPU oficial em resolução 960 × 540 e salvas em `tests/evidencias/dash_vfx/`:

1. `tests/evidencias/dash_vfx/dash_inicio_direita.png`:
   - Lançamento para a direita nos Portões do Cemitério;
   - Sigilo gótico em cruz floriada e arco etéreo suspensos sobre a capa de Aren;
   - Faíscas radiais afiadas no piso de pedra e cascalho projetado para trás.
2. `tests/evidencias/dash_vfx/dash_meio_direita.png`:
   - Aren em velocidade máxima (260 px/s);
   - Rastro linear de raspagem com núcleo branco-violeta e borda púrpura;
   - Ecos de silhueta (*afterimages*) e tufos de fumaça escura;
   - Sigilo original visível no ponto de partida em decaimento gradual.
3. `tests/evidencias/dash_vfx/dash_fim_direita.png`:
   - Frenagem deslizante com contato no piso;
   - Feixe de faíscas frontais e cascalho de pedra arremessado para a frente.
4. `tests/evidencias/dash_vfx/dash_inicio_esquerda.png`:
   - Início de dash perfeitamente espelhado para a esquerda.
5. `tests/evidencias/dash_vfx/dash_meio_esquerda.png`:
   - Deslocamento para a esquerda com sigilo ancorado à direita e rastro correspondente.
6. `tests/evidencias/dash_vfx/dash_fim_esquerda.png`:
   - Frenagem para a esquerda com faíscas e cascalho projetados para a esquerda.
7. `tests/evidencias/dash_vfx/dash_abadia_cenario.png`:
   - Dash executado no cenário da Abadia Silenciosa (*Átrio dos Votos*), demonstrando a harmonia estética do efeito com os relevos de pedra góticos e iluminação do ambiente.

---

## 6. Verificação de Integridade dos Arquivos Protegidos e Saves

### 6.1. Save Pessoal do Responsável
- **Caminho:** `C:\Users\ovohe\AppData\Roaming\Godot\app_userdata\Cinzas do Juramento\cinzas_abbey_progress_v1.json`
- **Hash SHA-256 Baseline:** `DCD23EE318C912E80B376F45BBBBD2037E5326898488532F81CC0AE997CB9A3A`
- **Hash SHA-256 Atual:** `DCD23EE318C912E80B376F45BBBBD2037E5326898488532F81CC0AE997CB9A3A`
- **Status:** **100% INTACTO E PRESERVADO**

### 6.2. 15 Arquivos Protegidos Canônicos
| Arquivo | Hash SHA-256 | Status |
| :--- | :--- | :---: |
| `project.godot` | `63FDDFB499D59CD3AE9B5B70D7D4A8816CCFD8586486C6CFCC3023733BCDCEC9` | **INTACTO** |
| `The Art of the Pixel.jpg` | `89F2F66DB85A545F389F81BFC8D1D21BC9901E0E140424175DC4326A2A17E17F` | **INTACTO** |
| `The Art of the Pixel.jpg.import` | `9DF64F571BC6F08A8C11A65905B1A19FCE763136F44D3957A16F83A0FF925E2F` | **INTACTO** |
| `The Siege and the Sandfox...jpg` | `5C05CA320FCC0A04EB5C3881C9DC7C284E646B8662459AD13B57EE0218746BF6` | **INTACTO** |
| `The Siege and the Sandfox...jpg.import` | `FE8BBD256A7EC2C1AA9C7A466825CB0C1E151292E37834F963F8A00AFB960415` | **INTACTO** |
| `tests/evidencias/m3d/fix03-after-sector1.png.import` | `1716C903F25A32256268EF6FD432A6259B3A7EE51BC0F1BFB41D7A73F6239A18` | **INTACTO** |
| `tests/evidencias/m3d/fix03-after-sector2.png.import` | `05FB6D88B054772330896EDC1A169AC93B6F405BF6066AB34103FE2EF1F48732` | **INTACTO** |
| `tests/evidencias/m3d/fix03-after-sector3.png.import` | `2B16C43221EF25ED73ABC8E59FDFE9B49F3FA22FC53E4AE955C381658B277269` | **INTACTO** |
| `tests/evidencias/m3d/fix03-after-sector4.png.import` | `7D28E62BC5740BBB4F58EB98DC25C6B3A0CAB77E6F8B57E5272BE60B89F176C5` | **INTACTO** |
| `tests/evidencias/m3d/fix03-after-sector5.png.import` | `4A2EFCB617B89EE53115B69FCA7A2DC8EBFF4BBFA35F67B99358592EDA833792` | **INTACTO** |
| `tests/evidencias/m3d/fix03-after-sector6.png.import` | `DF6CD5307940F5A9B1D5BA1D01CFEF424B0FDF33C15C63437F85A776766F7BED` | **INTACTO** |
| `tests/evidencias/m3d/fix03-attack--1-8.png.import` | `62E84E838CDBCBC0B8175E0D9C07AAFF79BA36EDC61999B42E73D7A640871FE6` | **INTACTO** |
| `tests/evidencias/m3d/fix03-attack-1-8.png.import` | `2FE6D6743AD1022B5F01C627DB426F5C824123D8D3797DC65B0D2D35FD25E78E` | **INTACTO** |
| `tests/evidencias/m3d/fix03-detail-cp1-active.png.import` | `8FB8EDCBDEAF3DFCFD336E3E7802DB657BAF2AD6EA037A6DCE94BFC0072B858C` | **INTACTO** |
| `tests/evidencias/m3d/fix03-detail-cp2-active.png.import` | `8CADB90AF8A0D107AF944B6E8D6C05F4D64AEC4B98895FB6E3023BAA57C1AE02` | **INTACTO** |

### 6.3. Disciplina Git
- Nenhum comando de alteração de histórico (`git add`, `git commit`, `git push`, `git reset`, `git clean`) foi executado.
- Repositório mantido exatamente no commit `2ac02cf0344b5fa5fc447b301cfdd8bae397be43`.
