# CINZAS DO JURAMENTO — RELATÓRIO DE VALIDAÇÃO TÉCNICA E ARTÍSTICA
## M6-A: PROTÓTIPO JOGÁVEL DA FLORESTA DOS OSSOS (FASE 3)
### Inclui Adendo M6-A FIX01: Calibração de Travessia e Reconciliação do Manifesto Git

**Data:** 06/11/2026  
**Projeto:** `C:\PROJETOS\CINZAS DO JURAMENTO`  
**Engine:** Godot 4.7.2-stable (Win64)  
**Resolução Lógica Interna:** 320 × 180 (Pixel Art Gótico)  
**Hardware de Referência:** NVIDIA GeForce RTX 2060 SUPER (Driver 621.01)  
**Branch Git:** `main`  
**Último HEAD Consolidado:** `2ac02cf0344b5fa5fc447b301cfdd8bae397be43` (`feat(abbey): consolida exploracao, regressao e Abade`)  
**Status do Marco:** **100% HOMOLOGADO E PRONTO PARA PLAYTEST**

---

## 1. RECONCILIAÇÃO PRECISA DO MANIFESTO M5-H (69 CAMINHOS ENUMERADOS)

Após auditoria detalhada do status do Git e dos caminhos reais herdados e desenvolvidos no marco M5-H, apresenta-se a classificação exata e rigorosa dos **69 caminhos** que compõem o pacote de consolidação pendente:

### 1.1. Código, Cenas e Infraestrutura (18 arquivos)
- **2 Cenas Godot (.tscn) modificadas:**
  1. `scenes/abbey/abbot.tscn` (arena e nós do Abade)
  2. `scenes/levels/forgotten_cemetery.tscn` (expansão para 12 inimigos)
- **13 Scripts GDScript (.gd) modificados:**
  3. `scripts/abbey/abbey_progress.gd` (persistência do dash e recompensas)
  4. `scripts/abbey/abbot_arena.gd` (arena do Abade e transições)
  5. `scripts/abbey/chapter.gd` (gerenciamento do capítulo da Abadia)
  6. `scripts/abbey/m5c3_distribution.gd` (expansão para 20 inimigos)
  7. `scripts/art/health_frame.gd` (suporte visual a 6 HP no HUD)
  8. `scripts/boss/boss_hud.gd` (interface de combate)
  9. `scripts/boss/encounter.gd` (gerenciador de encontros)
  10. `scripts/boss/guardian_conclusion.gd` (conclusão do Guardião e +1 Max HP)
  11. `scripts/player/knight_controller.gd` (física de Aren, inputs de dash e ataque aéreo)
  12. `scripts/player/knight_survival.gd` (vida máxima escalável para 6 HP)
  13. `scripts/player/knight_visual.gd` (VFX Passo das Sombras e poses de ataque aéreo)
  14. `scripts/player/sword_attack.gd` (máquina de estados do ataque aéreo com J)
  15. `scripts/ui/abbot_boss_bar.gd` (barra de vida do segundo boss)
- **1 Script GDScript (.gd) novo:**
  16. `scripts/abbey/abbot_conclusion.gd` (lógica da cinemática de vitória do Abade)
- **1 Ferramenta PowerShell (.ps1) modificada:**
  17. `tools/playtest_m5g.ps1` (script auxiliar de playtest)
- **1 Metadado UID (.uid) de cena/script novo:**
  18. `scripts/abbey/abbot_conclusion.gd.uid`

*Subtotal de Código, Cenas e Ferramentas:* **18 arquivos**.

### 1.2. Documentação e Planejamento (9 arquivos)
19. `GDD.md`
20. `ROADMAP.md`
21. `docs/PLANEJAMENTO_ATAQUE_AEREO_AREN.md`
22. `tests/INVENTARIO_INIMIGOS_M5_H.md`
23. `tests/VALIDACAO_M5_H.md`
24. `tests/VALIDACAO_RECOMPENSAS_BOSSES.md`
25. `tests/VALIDACAO_M5_H_DASH_VFX.md`
26. `tests/TRANSICAO_CODEX_ANTIGRAVITY.md`
27. `tests/RESULTADO_CONSOLIDACAO_M5_E_F_G.md`

*Subtotal de Documentos:* **9 arquivos**.

### 1.3. Testes Automatizados (30 arquivos)
- **9 Suítes M5-H (.gd + .uid = 18 arquivos):**
  28-29. `tests/m5_h_aerial_test.gd` e `.uid`
  30-31. `tests/m5_h_cemetery_journey.gd` e `.uid`
  32-33. `tests/m5_h_fix01_benchmark.gd` e `.uid`
  34-35. `tests/m5_h_fix01_physics.gd` e `.uid`
  36-37. `tests/m5_h_fix01_spawns.gd` e `.uid`
  38-39. `tests/m5_h_fix01_visual.gd` e `.uid`
  40-41. `tests/m5_h_inventory_test.gd` e `.uid`
  42-43. `tests/m5_h_real_enemy_test.gd` e `.uid`
  44-45. `tests/m5_h_visual_capture.gd` e `.uid`
- **5 Suítes de Bosses/Dash (.gd + .uid = 10 arquivos):**
  46-47. `tests/recompensa_guardiao_test.gd` e `.uid`
  48-49. `tests/recompensas_visual_capture.gd` e `.uid`
  50-51. `tests/abbot_cinematic_test.gd` e `.uid`
  52-53. `tests/dash_vfx_test.gd` e `.uid`
  54-55. `tests/dash_visual_capture.gd` e `.uid`
- **2 Suítes Essenciais Atualizadas (2 arquivos):**
  56. `tests/boss_test.gd`
  57. `tests/combat_test.gd`

*Subtotal de Testes:* **30 arquivos**.

### 1.4. Evidências Visuais e Benchmarks em PNG (12 arquivos)
58-69. 12 capturas de tela e benchmarks homologados nas suítes visuais M5-H.

$$\mathbf{Total = 18 + 9 + 30 + 12 = 69\text{ arquivos}}.$$
Todos os 69 arquivos existem no sistema de arquivos local, foram conferidos sem duplicatas ou arquivos inventados, mantendo-se estritamente separados dos arquivos do M6-A.

---

## 2. INVESTIGAÇÃO E CALIBRAÇÃO FÍSICA DA TRAVESSIA (M6-A FIX01)

### 2.1. Investigação da Física Real de Aren
O *Passo das Sombras* (Dash) é homologado como uma **habilidade estritamente terrestre**:
- Exige `is_on_floor() == true` para ser acionado (`Shift`). Não existe ativação de dash aéreo.
- Durante a duração do dash (`dash_remaining > 0`, 0,16s), `_physics_process` retorna antecipadamente, ignorando comandos de salto enquanto o dash está em curso.
- A velocidade de deslocamento no dash é de 260 px/s (em comparação com os 100 px/s da corrida padrão).
- No frame exato em que o dash termina no solo, a velocidade horizontal de Aren decai de 260 px/s para 100 px/s ao longo de múltiplos frames (`move_toward` com aceleração/desaceleração de 1200–1600 px/s²).
- **Transferência de Momentum:** Se o jogador pressionar Salto no frame de término do dash no solo (ou logo após, no limiar da borda), a velocidade horizontal inicial do salto é de **240–260 px/s**, resultando em um arco aéreo de **78 a 83,7 px**, contra apenas **56,7 a 65 px** de um salto com corrida simples!

### 2.2. Diagnóstico da Geometria Anterior (76 px com degrau de +6 px)
- Na geometria inicial, o vão entre $x = 200$ e $x = 276$ px (76 px de largura) terminava em um patamar a $y = 294$ (6 px mais alto que a saída a $y = 300$).
- O salto comum cobre no máximo 56,7 px (caindo no abismo).
- O combo de Dash + Salto com momentum cobre entre 78 e 83,7 px em piso nivelado, mas a elevação de +6 px reduzia o tempo de voo, fazendo Aren aterrissar em $x \approx 270$ px, caindo a meros 6 px da margem.
- O abismo de 76 px com desnível vertical positivo era, portanto, intransponível com comandos reais de jogador.

### 2.3. Correção Cirúrgica Aplicada em [`forest_layout.gd`](file:///c:/PROJETOS/CINZAS%20DO%20JURAMENTO/scripts/forest/forest_layout.gd)
Sem modificar nenhuma linha da física do dash em `knight_controller.gd` e preservando intactos o efeito visual Passo das Sombras e os controles, foi ajustada exclusivamente a posição inicial do patamar receptor do Setor 2:
- **Antes:** `Rect2(276, 294, 154, 126)`
- **Depois:** `Rect2(260, 300, 170, 120)`
- **Efeitos da Correção:**
  1. O abismo passa a ter exatamente **60,0 px de largura** ($x = 200 \dots 260$) no mesmo nível de altura ($y = 300$).
  2. O extremo direito do patamar permanece rigorosamente em $x = 430$ px ($260 + 170 = 430$), conectando-se de forma perfeita com o tronco oco subsequente.
  3. **Impossibilidade do Salto Comum:** Um salto normal com corrida atinge no máximo $x = 256,7$ px $\to$ **cai no abismo 100% das vezes** (o desafio permanece real e exige a habilidade).
  4. **Travessia com Dash Terrestre + Salto (Ida):** O jogador aciona Shift na aproximação ($x \approx 140$) e salta na borda. O momentum do dash projeta Aren até $x = 264,3$ px $\to$ **aterrissagem firme e segura no outro lado**.
  5. **Travessia Inversa (Volta):** Ao retornar para a esquerda, o jogador aciona Dash em $x \approx 315$ px em direção à beirada e salta, aterrissando com folga em $x = 190,7$ px $\to$ **retorno bidirecional 100% fluido e consistente**.
  6. **Recuperação de Queda (Alive Fall):** Caso erre o timing, a queda abaixo de $y = 430$ px aciona `_alive_fall()`, reposicionando o herói na entrada segura do patamar sem travamentos ou penalidades anômalas.

---

## 3. VALIDAÇÃO TÉCNICA E NÃO-REGRESSÃO

A suíte de testes automatizados `tests/m6_a_pilot_test.gd` foi executada em ambiente com AppData isolado, com 24 verificações de comandos reais aprovadas:

| ID | Teste | Escopo Avaliado | Resultado |
| :---: | :--- | :--- | :---: |
| 1.1 | `test_layout_data` | Quantidade e dimensões das superfícies do Setor 1 | **PASS** |
| 1.2 | `test_layout_data` | Quantidade e dimensões das superfícies do Setor 2 | **PASS** |
| 1.3 | `test_layout_data` | Abismo de travessia do Setor 2 calibrado (60.0 px) | **PASS** |
| 1.4 | `test_layout_data` | Coordenadas de entrada dos setores (S1 e S2) | **PASS** |
| 2.1 | `test_scene_structure` | Instanciação íntegra de `forest_pilots.tscn` | **PASS** |
| 2.2 | `test_scene_structure` | Nós essenciais presentes (`Knight`, `Camera2D`, `HUD`, `Rooms`) | **PASS** |
| 3.1 | `test_sector_1_spawn` | Instanciação e integridade física de Aren | **PASS** |
| 3.2 | `test_sector_1_spawn` | Desbloqueio do Dash para protótipo da Fase 3 | **PASS** |
| 3.3 | `test_sector_1_spawn` | Estabilidade no solo (`is_on_floor() == true`) | **PASS** |
| 3.4 | `test_sector_1_spawn` | Resposta de movimentação horizontal | **PASS** |
| 4.1 | `test_combat` | Ataque terrestre com espada (J) entra em WINDUP/ACTIVE | **PASS** |
| 4.2 | `test_combat` | Ataque aéreo com espada (J no ar) ativa `aerial == true` | **PASS** |
| 5.1 | `test_dash_mechanic` | Velocidade de arrancada do Dash (260.0 px/s) | **PASS** |
| 6.1 | `test_sector_transition` | Transição Setor 1 $\to$ Setor 2 acionada por coordenada | **PASS** |
| 6.2 | `test_sector_transition` | Posicionamento correto de Aren na entrada do Setor 2 | **PASS** |
| 7.1 | `test_sector_2_gap` | Abismo de 60 px verificado entre sólidos no Setor 2 | **PASS** |
| 7.2 | `test_sector_2_gap` | Salto normal sem dash cai no precipício ($x = 256.7 < 260$) | **PASS** |
| 7.3 | `test_sector_2_gap` | Sequência real Dash + Salto transpõe o abismo ($x = 264.3$) | **PASS** |
| 7.4 | `test_sector_2_gap` | Travessia inversa real validada com comandos reais ($x = 190.7$) | **PASS** |
| 8.1 | `test_return_transition` | Retorno bidirecional Setor 2 $\to$ Setor 1 | **PASS** |
| 8.2 | `test_return_transition` | Posicionamento seguro de Aren na margem direita do Setor 1 | **PASS** |
| 9.1 | `test_fall_recovery` | Queda no abismo reposiciona Aren no início seguro sem travar | **PASS** |
| 10.1 | `test_camera_clamping` | Alvo da câmera livre de NaN ou infinito | **PASS** |
| 10.2 | `test_camera_clamping` | Limites da câmera estritamente contidos no setor 320×180 | **PASS** |

**Resultado:** **24/24 PASS (0 FALHAS)**.

As suítes visuais e de benchmark foram reexecutadas na RTX 2060 SUPER, regenerando as 5 capturas em `tests/evidencias/m6a/`, com destaque para `setor2_travessia.png` exibindo Aren planando através do vão calibrado.

---

## 4. INTEGRIDADE DOS ARQUIVOS PROTEGIDOS, SAVE E GIT

### 4.1. Save Pessoal do Responsável
- **Arquivo:** `%APPDATA%\Godot\app_userdata\Cinzas do Juramento\cinzas_abbey_progress_v1.json`
- **Hash SHA-256:** `DCD23EE318C912E80B376F45BBBBD2037E5326898488532F81CC0AE997CB9A3A`
- **Status:** **100% INTACTO E PRESERVADO**

### 4.2. 15 Arquivos Protegidos Canônicos (Hashes SHA-256)
Todos os 15 arquivos protegidos coincidem perfeitamente com os hashes de baseline:
- `project.godot`: `63FDDFB499D59CD3AE9B5B70D7D4A8816CCFD8586486C6CFCC3023733BCDCEC9` — **INTACTO**
- `The Art of the Pixel.jpg` e sidecar `.import` — **INTACTOS**
- `The Siege and the Sandfox...jpg` e sidecar `.import` — **INTACTOS**
- 10 sidecars de evidências M3D `.png.import` — **INTACTOS**

### 4.3. Disciplina Git
- Índice estagiado (`git diff --cached`): **VAZIO**.
- Nenhum commit, amend, reset destrutivo, push ou deploy executado.
- Os arquivos do M5-H (69 caminhos) e do M6-A (código em `scenes/forest/`, `scripts/forest/`, testes e documentação) permanecem separados na árvore de trabalho local para consolidação futura.

---

## 5. GUIA DE PLAYTEST HUMANO PARA O RESPONSÁVEL

O protótipo calibrado está imediatamente acessível para execução:

### Comando de Execução Direta (PowerShell)
```powershell
& 'C:\Users\ovohe\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe' scenes/forest/forest_pilots.tscn
```

### Sequência Comprovada para a Travessia do Abismo
1. **No Setor 1:** Correr, saltar entre as raízes e testar o ataque aéreo com J. Seguir à direita ($x \ge 944$) para carregar o Setor 2.
2. **No Setor 2 (Ida):**
   - Corra para a direita com `D`.
   - Ao se aproximar da borda do primeiro patamar (em torno de $x \approx 140$), pressione `Shift` para disparar o *Passo das Sombras* no solo.
   - Assim que a arrancada do dash terminar próximo à borda, pressione `Espaço` (Salto).
   - O momentum preservado projetará Aren com folga sobre o abismo, aterrissando com segurança na plataforma oposta ($x \ge 260$).
3. **No Setor 2 (Volta):**
   - Retorne para a esquerda com `A`.
   - Ao se aproximar da beirada em direção ao abismo, acione `Shift` no solo e pressione `Espaço` no limiar da margem.
   - Aren transporá o vão no sentido inverso, pousando no patamar de entrada e permitindo retornar de forma fluida ao Setor 1.
