# RELATÓRIO DE VALIDAÇÃO TÉCNICA E ACESSIBILIDADE — M6-B1 FIX01
## CORREÇÃO CRÍTICA DE ACESSIBILIDADE DO SANTUÁRIO DO CERVO
### Bosque das Raízes (Setor 2) — Floresta dos Ossos

**Projeto:** `C:\PROJETOS\CINZAS DO JURAMENTO`  
**Engine:** Godot 4.7.2-stable (Win64)  
**Branch:** `main`  
**HEAD de Referência:** `e90dfc0c2de67023ea2d3bc7979a145a2cad033d`  
**GPU de Validação:** NVIDIA GeForce RTX 2060 SUPER (Driver 621.01, OpenGL 3.3.0 Compatibility)  
**Data:** 06/11/2026  
**Status Funcional:** **APROVADO** (253/253 verificações automatizadas com 0 falhas)  
**Status Visual:** **PENDENTE** (submetido para avaliação do responsável)

---

## 1. HISTÓRICO E CONTEXTO DO PROBLEMA

Durante o playtest manual do M6-B1 realizado pelo responsável, foi identificada uma falha crítica de acessibilidade no **Setor 2 — Bosque das Raízes**:
- Aren encontrava-se diante do patamar elevado do Santuário do Cervo e não conseguia alcançá-lo com seu salto padrão.
- Esse obstáculo bloqueava o avanço contínuo do jogador rumo aos novos Setores 3 (Passagem dos Fósseis) e 4 (Clareira Ancestral).
- O playtest foi considerado reprovado funcionalmente até que a travessia fosse corrigida de forma orgânica e comprovada por entradas reais de controle.

---

## 2. INVESTIGAÇÃO E DIAGNÓSTICO DA CAUSA RAIZ

### 2.1 Análise Numérica e Física do Pulo de Aren
- **Nível do Chão de Aproximação:** `y = 288.0 px`
- **Nível do Patamar do Santuário:** `y = 246.0 px`
- **Desnível Vertical:** `288.0 - 246.0 = 42.0 px`
- **Física de Aren (`scripts/player/knight_controller.gd`):**
  - Velocidade inicial de salto: `JUMP_FORCE = -230.0 px/s`
  - Gravidade atuante: `GRAVITY = 680.0 px/s²`
  - Passo temporal de física: \( \Delta t = \frac{1}{60} \approx 0.016667 \text{ s} \)
- **Cálculo da Trajetória Discreta (Euler Semi-Implícito a 60 Hz):**
  - Passo 0: \( y = 0.00 \text{ px}, v = -230.00 \text{ px/s} \)
  - Passo 1: \( v = -218.67 \text{ px/s}, \Delta y = -3.64 \text{ px} \)
  - Passo 2: \( v = -207.33 \text{ px/s}, \Delta y = -3.46 \text{ px} \)
  - ...
  - Passo 20 (Ápice do salto, \( v \approx 0 \)): **Elevação máxima atingida: 37.00 px**.
- **Déficit Físico:** \( 42.00 \text{ px} - 37.00 \text{ px} = 5.00 \text{ px} \).
  Aren colidia contra a quina vertical do bloco e caía de volta ao solo.

### 2.2 Por que os Testes Anteriores não Detectaram o Problema?
Nas rotinas automatizadas anteriores (`tests/m6_a_visual_capture.gd` e `tests/m6_b1_expansion_test.gd`), o posicionamento de Aren para capturas e verificações de transição de tela era efetuado através de `hero.reset_to(Vector2(810, 246))` ou `reset_to(Vector2(946, 288))`. Esse método teletransportava o personagem diretamente sobre a superfície elevada sem exigir que ele realizasse o salto físico real a partir do chão inferior em `y = 288.0`.

---

## 3. SOLUÇÃO GEOMÉTRICA ORGÂNICA IMPLEMENTADA

A correção foi implementada respeitando integralmente as seguintes premissas obrigatórias:
1. **Nenhum ajuste nos parâmetros físicos de Aren:** `JUMP_FORCE` (-230), `GRAVITY` (680), velocidade de movimento (120) e dash (260) permaneceram 100% inalterados.
2. **Nenhuma alteração de escala ou arte do Santuário:** O patamar principal permanece estritamente em `y = 246.0`, preservando a composição visual aprovada pelo responsável.
3. **Padrão de Lajes Verticais de Godot:** Todas as superfícies estendem-se até o fundo da sala (`y = 420.0`), garantindo colisão estanque sem quinas internas invisíveis.

### 3.1 Nova Estrutura de Degraus e Patamares (`scripts/forest/forest_layout.gd`)
Substituiu-se a antiga laje contínua única por 5 lajes colunares orgânicas:

| Segmento | Rect2 Físico | Nível do Topo (y) | Elevação / Salto Necessário | Status de Acessibilidade |
|---|---|---|---|---|
| **Chão de Aproximação Oeste** | `Rect2(704, 288, 60, 132)` | 288.0 px | Baseline | Apoiado no chão firme |
| **Degrau Intermediário Oeste** | `Rect2(764, 268, 46, 152)` | 268.0 px | **+20.0 px** (a partir de 288) | Salto de 20 px << 37 px max (Fácil) |
| **Patamar do Santuário** | `Rect2(810, 246, 80, 174)` | 246.0 px | **+22.0 px** (a partir de 268) | Salto de 22 px << 37 px max (Fácil) |
| **Degrau Intermediário Leste** | `Rect2(890, 268, 44, 152)` | 268.0 px | **-22.0 px** (descida) / **+20.0 px** (volta) | Descida suave / subida reversa fácil |
| **Chão de Saída Leste** | `Rect2(934, 288, 26, 132)` | 288.0 px | **-20.0 px** (descida) | Nível contínuo com a entrada do Setor 3 |

### 3.2 Integração Artística Orgânica (`scripts/forest/forest_art.gd`)
- As raízes monumentais do bosque foram reposicionadas e ancoradas nos novos degraus intermediários (`x = 760` e `x = 885`), conferindo o aspecto de afloramentos rochosos e raízes petrificadas que naturalmente servem de apoio para subir ao santuário.
- Cogumelos bioluminescentes e fragmentos de ossos foram relocados para evitar quinas e guiar intuitivamente o olhar do jogador pela rota de subida.

---

## 4. VALIDAÇÃO RIGOROSA COM ENTRADAS REAIS (SEM TELEPORTE)

Criou-se a nova suíte dedicada `tests/m6_b1_altar_accessibility_test.gd`, que testa a travessia do Santuário injetando comandos físicos do motor (`Input.action_press` e `Input.action_release`):

1. **Subida Oeste (x=720 -> Degrau 268 -> Altar 246):**
   - Aren inicia no chão em `x=720, y=288`.
   - Caminha para a direita (`move_right`), salta no momento adequado (`jump`).
   - Aterrissa no degrau oeste em `x=786.0, y=268.0` (**PASS**).
   - Da borda do degrau, caminha e salta novamente.
   - Aterrissa com firmeza no patamar do Santuário em `x=848.2, y=246.0` (**PASS**).
2. **Descida Leste (Altar 246 -> Degrau 268 -> Chão 288 -> Setor 3):**
   - Aren caminha para a direita a partir do topo do altar.
   - Cai com segurança no degrau leste em `x=908.2, y=268.0` (**PASS**).
   - Continua andando para a direita e aterrissa suavemente no chão leste em `x=944.2, y=288.0` (**PASS**).
3. **Subida Reversa Leste (Retorno S3 -> S2):**
   - Aren no chão leste em `x=940, y=288` caminha para a esquerda (`move_left`) e salta.
   - Atinge o degrau leste em `y=268.0` (**PASS**).
   - Salta novamente e atinge o topo do Altar em `y=246.0` (**PASS**).
4. **Descida Reversa Oeste (Retorno S2 -> S1):**
   - Aren caminha para a esquerda, desce para o degrau oeste (`y=268.0`) e depois para o chão oeste (`y=288.0`) (**PASS**).
5. **Jornada Contínua e Ininterrupta S1 -> S2 -> S3 -> S4 -> S3 -> S2 -> S1:**
   - Travessia completa entre todas as 4 salas executada com sucesso usando movimentação real (**PASS**).

**Resultado do Teste de Acessibilidade:** **15/15 PASS (0 falhas)**.

---

## 5. AUDITORIA COMPLETA DE ACESSIBILIDADE DOS 4 SETORES

| Setor | Nome | Obstáculos e Desafios Físicos | Desníveis Máximos | Método de Travessia Homologado | Status |
|---|---|---|---|---|---|
| **Setor 1** | Entrada da Floresta | Desnível inicial, plataformas de galhos fossilizados | Elevações de 12 a 24 px | Salto normal | **APROVADO** |
| **Setor 2** | Bosque das Raízes | Abismo de 60 px (x: 200..260); Santuário do Cervo (x: 704..960) | Abismo: 60 px largura; Degraus: 20 px e 22 px | Abismo: Dash Terrestre + Salto; Santuário: Salto nos degraus | **APROVADO** |
| **Setor 3** | Passagem dos Fósseis | Fenda fóssil de 50 px (x: 520..570); Galhos elevados | Fenda: 50 px largura; Galhos: 24 px | Salto normal sem dash | **APROVADO** |
| **Setor 4** | Clareira Ancestral | Terraços ascendentes até o mirante final (y=300 -> 280 -> 260) | Elevações de 20 px por patamar | Salto progressivo | **APROVADO** |

---

## 6. RESULTADOS DAS SUÍTES DE REGRESSÃO E TESTES (TOTAL: 253/253)

Todas as suítes automatizadas foram executadas no Godot 4.7.2 oficial com perfil isolado e `SAVE_SAFETY_ISOLATED_ROOT`:

| Suíte de Teste | Arquivo | Verificações | Aprovados | Falhas | Status |
|---|---|---|---|---|---|
| **Acessibilidade do Santuário** | `tests/m6_b1_altar_accessibility_test.gd` | 15 | 15 | 0 | **PASS** |
| **Expansão M6-B1 (Setores 3 e 4)** | `tests/m6_b1_expansion_test.gd` | 33 | 33 | 0 | **PASS** |
| **Piloto da Floresta (Setores 1 e 2)** | `tests/m6_a_pilot_test.gd` | 24 | 24 | 0 | **PASS** |
| **Física e Entradas Reais M6-A** | `tests/m6_a_codex_recovery_physics.gd` | 6 | 6 | 0 | **PASS** |
| **Passo das Sombras (Dash VFX)** | `tests/dash_vfx_test.gd` | 47 | 47 | 0 | **PASS** |
| **Combate e Ataque Aéreo (J)** | `tests/combat_test.gd` | 36 | 36 | 0 | **PASS** |
| **Arena do Boss Guardião** | `tests/boss_test.gd` | 59 | 59 | 0 | **PASS** |
| **Recompensas Permanentes dos Bosses** | `tests/recompensa_guardiao_test.gd` | 33 | 33 | 0 | **PASS** |
| **TOTAL CONSOLIDADO** | - | **253** | **253** | **0** | **100% PASS** |

---

## 7. EVIDÊNCIAS VISUAIS CAPTURADAS NA GPU REAL

Capturas executadas diretamente na NVIDIA GeForce RTX 2060 SUPER na resolução 1280 × 720 (escala x4 da resolução nativa 320 × 180):

1. **`santuario_antes.png`**: Estado anterior reprovado pelo responsável, com parede vertical abrupta de 42 px bloqueando o salto.
2. **`santuario_depois.png`**: Novo layout com degraus orgânicos, raízes esculpidas e vegetação bioluminescente integrada.
3. **`aren_apoio_intermediario.png`**: Aren posicionado com estabilidade no degrau oeste (`x=780, y=268`).
4. **`aren_patamar_superior.png`**: Aren no topo do patamar do Santuário (`x=840, y=246`).
5. **`aren_descida_segura.png`**: Aren iniciando a descida pelo degrau leste (`x=905, y=268`).
6. **`cenario_completo_pos_fix.png`**: Composição panorâmica ampla do Santuário do Cervo com atmosfera e iluminação completas.
7. **`comparacao_antes_depois_fix01.png`**: Painel comparativo lado a lado evidenciando a continuidade visual e a acessibilidade física restaurada.

*Todas as imagens estão armazenadas em `tests/evidencias/m6b1_fix01/` e espelhadas na pasta de artefatos.*

---

## 8. INTEGRIDADE DOS 15 ARQUIVOS PROTEGIDOS

Conferência criptográfica realizada via SHA-256 confirmando equivalência exata aos baselines canônicos:

| Arquivo Protegido | SHA-256 Calculado | Status |
|---|---|---|
| `project.godot` | `63FDDFB499D59CD3AE9B5B70D7D4A8816CCFD8586486C6CFCC3023733BCDCEC9` | **Íntegro** |
| `The Art of the Pixel.jpg` | `89F2F66DB85A545F389F81BFC8D1D21BC9901E0E140424175DC4326A2A17E17F` | **Íntegro** |
| `The Art of the Pixel.jpg.import` | `9DF64F571BC6F08A8C11A65905B1A19FCE763136F44D3957A16F83A0FF925E2F` | **Íntegro** |
| `The Siege and the Sandfox...jpg` | `5C05CA320FCC0A04EB5C3881C9DC7C284E646B8662459AD13B57EE0218746BF6` | **Íntegro** |
| `The Siege and the Sandfox...jpg.import` | `FE8BBD256A7EC2C1AA9C7A466825CB0C1E151292E37834F963F8A00AFB960415` | **Íntegro** |
| `tests/evidencias/m3d/fix03-after-sector1.png.import` | `1716C903F25A32256268EF6FD432A6259B3A7EE51BC0F1BFB41D7A73F6239A18` | **Íntegro** |
| `tests/evidencias/m3d/fix03-after-sector2.png.import` | `05FB6D88B054772330896EDC1A169AC93B6F405BF6066AB34103FE2EF1F48732` | **Íntegro** |
| `tests/evidencias/m3d/fix03-after-sector3.png.import` | `2B16C43221EF25ED73ABC8E59FDFE9B49F3FA22FC53E4AE955C381658B277269` | **Íntegro** |
| `tests/evidencias/m3d/fix03-after-sector4.png.import` | `7D28E62BC5740BBB4F58EB98DC25C6B3A0CAB77E6F8B57E5272BE60B89F176C5` | **Íntegro** |
| `tests/evidencias/m3d/fix03-after-sector5.png.import` | `4A2EFCB617B89EE53115B69FCA7A2DC8EBFF4BBFA35F67B99358592EDA833792` | **Íntegro** |
| `tests/evidencias/m3d/fix03-after-sector6.png.import` | `DF6CD5307940F5A9B1D5BA1D01CFEF424B0FDF33C15C63437F85A776766F7BED` | **Íntegro** |
| `tests/evidencias/m3d/fix03-attack--1-8.png.import` | `62E84E838CDBCBC0B8175E0D9C07AAFF79BA36EDC61999B42E73D7A640871FE6` | **Íntegro** |
| `tests/evidencias/m3d/fix03-attack-1-8.png.import` | `2FE6D6743AD1022B5F01C627DB426F5C824123D8D3797DC65B0D2D35FD25E78E` | **Íntegro** |
| `tests/evidencias/m3d/fix03-detail-cp1-active.png.import` | `8FB8EDCBDEAF3DFCFD336E3E7802DB657BAF2AD6EA037A6DCE94BFC0072B858C` | **Íntegro** |
| `tests/evidencias/m3d/fix03-detail-cp2-active.png.import` | `8CADB90AF8A0D107AF944B6E8D6C05F4D64AEC4B98895FB6E3023BAA57C1AE02` | **Íntegro** |

---

## 9. INTEGRIDADE DO SAVE PESSOAL E DO GIT

- **Save Pessoal:** O arquivo original do usuário em `%APPDATA%\Godot\app_userdata\Cinzas do Juramento\` permaneceu 100% intocado. Todos os testes rodaram com profile isolado descartável.
- **Git Staging e Commits:** Nenhuma alteração foi incluída no índice (`git diff --cached` está rigorosamente vazio). Não foi realizado nenhum commit, push ou deploy.

---

## 10. CLASSIFICAÇÃO DE STATUS DA ENTREGA

- **Validação Funcional:** **APROVADO** (Acessibilidade garantida por testes de entrada real, 253/253 testes verdes, desnível máximo de 22 px compatível com os 37 px de salto).
- **Validação Visual do Responsável:** **PENDENTE** (aguardando novo playtest humano interativo).

---

## 11. COMANDO PARA NOVO PLAYTEST MANUAL DO RESPONSÁVEL

Para testar a subida e descida no Santuário do Cervo e a travessia contínua pelos 4 setores:

```powershell
& "C:\Users\ovohe\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe" --path "C:\PROJETOS\CINZAS DO JURAMENTO" "res://scenes/forest/forest_pilots.tscn"
```

### Controles no Jogo:
- **A / D** ou **Setas**: Movimentação horizontal.
- **Espaço / W**: Salto.
- **Shift** (no chão): Passo das Sombras (Dash terrestre para o abismo no Setor 2).
- **J**: Ataque com a espada (no chão ou ataque aéreo).
- **1, 2, 3, 4** (Teclas numéricas): Teleporte rápido para testar cada setor individualmente.

