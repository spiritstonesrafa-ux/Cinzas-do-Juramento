# RELATÓRIO DE VALIDAÇÃO TÉCNICA E HOMOLOGAÇÃO LOCAL — M6-C1
## Fundação do Bestiário, Perigos Iniciais e Persistência de Encontros (Setores 1 a 4)

**Projeto:** Cinzas do Juramento  
**Engine:** Godot 4.7.2 (`Godot_v4.7.2-stable_win64_console.exe`)  
**GPU de Referência:** NVIDIA GeForce RTX 2060 SUPER  
**Branch:** `main`  
**HEAD de Referência:** `6c47693c31a9208617e0133273b4ab0ed2d55b91`  
**Data da Operação:** 07 de novembro de 2026  
**Status do Marco:** Implementado localmente, testado e pronto para homologação humana.  
**Push e Deploy:** **EXPRESSAMENTE PROIBIDOS (ZERO staged, ZERO commits, ZERO pushes)**.

---

## 1. RESUMO EXECUTIVO

O marco **M6-C1** estabelece a fundação do sistema de combate e perigos ambientais da **Fase 3 — Floresta dos Ossos**, introduzindo:

1. **Três Novos Arquétipos de Inimigos Canônicos:**
   - **Rastejante Fóssil (`ForestCrawler`):** Inimigo rastejante de baixo perfil (altura 18 px, largura 24 px, 2 HP, 1 de dano de contato, velocidade de patrulha 45 px/s, telegrafia de bote de 0.30s, esquiva de precipícios e paredes).
   - **Sentinela Ósseo (`ForestSentinel`):** Inimigo pesado (altura 32 px, largura 18 px, 3 HP, 1 de dano, alcance de golpe de 26 px, velocidade de patrulha 28 px/s, telegrafia pesada de 0.45s com **poise ininterrupto durante o windup** e vulnerabilidade total no recovery).
   - **Corvo Espectral (`ForestSpectralCrow`):** Inimigo aéreo flutuante (envergadura 22 px, altura 16 px, 2 HP, 1 de dano, mergulho veloz a 90 px/s, telegrafia de 0.45s, guarda de frustum de câmera `visible_for_attack()` e alvo de interceptação aérea com espada 'J' no ar).
2. **Perigo Ambiental de Solo:**
   - **Espículas Ósseas Temporizadas (`ForestFossilSpikes`):** Perigo estendido de `DamageSource` com ciclo temporizado: `SAFE` (1.8s) $\to$ `WARNING` (0.6s) $\to$ `ACTIVE` (0.8s) $\to$ `RECOVER` (0.4s). Causa 1 de dano de contato exclusivamente no estado ACTIVE.
3. **Distribuição Canônica nos Setores 1 a 4 (9 Inimigos + 1 Perigo):**
   - **Setor 1:** 2 Rastejantes (`E-01` $x=450, y=300$; `E-02` $x=820, y=300$).
   - **Setor 2:** 1 Rastejante (`E-03` $x=330, y=300$), 1 Corvo (`E-04` $x=520, y=240$). Santuário do Cervo ($x \ge 700$) preservado estritamente vazio.
   - **Setor 3:** 1 Rastejante (`E-05` $x=240, y=312$), 1 Corvo (`E-06` $x=450, y=200$), 1 Sentinela (`E-07` $x=660, y=276$), 1 Espícula Fóssil (`P-01` $x=480, y=290$).
   - **Setor 4:** 1 Sentinela (`E-08` $x=480, y=300$), 1 Rastejante (`E-09` $x=820, y=260$).
   - **Setores 5 a 10:** Preservados intactos e vazios (reservados para M6-C2, M6-C3 e arena do Cervo).
4. **Persistência e Contratos de Sala em `ForestSector`:**
   - `snapshot()`: Captura viva/derrotada e estado de saúde de cada inimigo e perigo.
   - `restore_state(data)`: Preserva inimigos mortos (sem respawn indevido na revisita).
   - `reset_encounters()`: Restaura inimigos e perigos à vida e origem após morte do herói no checkpoint.
   - `disarm()`: Desarma hitboxes e fontes de ataque em transições de sala e morte.

---

## 2. ARQUITETURA E RESPOSTAS TÉCNICAS AUDITADAS

### 2.1 Resolução da Questão do Dash e i-Frames
- **Constatação Canônica:** O Passo das Sombras (Dash) em `knight_controller.gd` **NÃO possui invulnerabilidade (i-frames)** (`contact_damage()` é chamado em todas as fases da cinemática).
- **Diretriz de Design:** O Dash destina-se ao reposicionamento espacial e esquiva de alcance, enquanto a janela de telegrafia dos inimigos (0.30s a 0.45s) e a vulnerabilidade pós-ataque fornecem o tempo hábil para esquiva e contra-ataque.

### 2.2 Resolução da Altura do Rastejante Fóssil
- A hitbox de ataque da espada de Aren no solo atinge a faixa $y \in [-21.0, -7.0]$ em relação ao pé ($y=0$).
- O `SwordReceiver` do `ForestCrawler` foi calibrado com altura de 18 px ($y \in [-18.0, 0.0]$).
- Essa calibragem garante **11 pixels de sobreposição vertical contínua** ($y \in [-18.0, -7.0]$), assegurando 100% de precisão nos golpes sem necessidade de alterar `sword_attack.gd`.

### 2.3 Mecânica de Poise do Sentinela Ósseo
- Durante a telegrafia (`State.ATTACK`, `attack_phase = WINDUP` de 0.45s), o Sentinela absorve golpes sem cancelamento de ataque (reduz HP de 3 para 2, aciona flash visual de poise, mas mantém o golpe descendo).
- Na fase de `RECOVERY` (0.40s), ele é completamente vulnerável: qualquer golpe recebido causa atordoamento (`State.HURT`), cancelando a recuperação e premiando o contra-ataque consciente do jogador.

### 2.4 Guarda de Frustum da Câmera do Corvo Espectral
- Implementado método `visible_for_attack()` que inspeciona o retângulo visível da câmera ativa.
- O Corvo nunca inicia o mergulho fora da visão do jogador, prevenindo ataques surpresa injustos.

---

## 3. RELAÇÃO DE ARQUIVOS IMPLEMENTADOS E ALTERADOS

| # | Arquivo | Categoria | Operação | Descrição |
| :-: | :--- | :---: | :---: | :--- |
| 1 | `scripts/forest/forest_encounter_layout.gd` | Script | Novo | Layout e coordenadas canônicas dos encontros dos Setores 1 a 4 |
| 2 | `scripts/enemies/forest_crawler.gd` | Script | Novo | FSM, IA de patrulha/bote, raycasts de solo/parede e dano do Rastejante |
| 3 | `scripts/enemies/forest_crawler_visual.gd` | Script | Atualizado (FIX01) | Integração da arte oficial `forest_crawler.png`, animações de bote e telegrafia |
| 4 | `scripts/enemies/forest_crawler_attack_source.gd` | Script | Novo | DamageSource de curto alcance na fase ativa do bote |
| 5 | `scenes/enemies/forest_crawler.tscn` | Cena | Novo | Cena modular do Rastejante (layer 128, receiver layer 8, attack layer 32) |
| 6 | `scripts/enemies/forest_sentinel.gd` | Script | Novo | FSM, IA pesada, poise no windup e vulnerabilidade no recovery |
| 7 | `scripts/enemies/forest_sentinel_visual.gd` | Script | Atualizado (FIX01) | Integração da arte oficial `forest_sentinel.png`, poise luminoso e slam |
| 8 | `scripts/enemies/forest_sentinel_attack_source.gd` | Script | Novo | DamageSource pesado com alcance de 26 px e verificação de corredor |
| 9 | `scenes/enemies/forest_sentinel.tscn` | Cena | Novo | Cena modular do Sentinela Ósseo |
| 10 | `scripts/enemies/forest_spectral_crow.gd` | Script | Novo | FSM aéreo flutuante, telegrafia alert, mergulho 90 px/s e frustum guard |
| 11 | `scripts/enemies/forest_spectral_crow_visual.gd` | Script | Atualizado (FIX01) | Integração da arte oficial `forest_crow.png`, envergadura e mergulho |
| 12 | `scripts/enemies/forest_crow_attack_source.gd` | Script | Novo | DamageSource de mergulho consumido no primeiro impacto |
| 13 | `scenes/enemies/forest_spectral_crow.tscn` | Cena | Novo | Cena modular do Corvo Espectral |
| 14 | `scripts/props/forest_fossil_spikes.gd` | Script | Novo | Perigo de espículas fósseis temporizadas (SAFE/WARNING/ACTIVE/RECOVER) |
| 15 | `scenes/props/forest_fossil_spikes.tscn` | Cena | Novo | Cena modular das espículas temporizadas |
| 16 | `scripts/forest/forest_sector.gd` | Script | Modificado | Spawner modular de encontros, persistência de sala e contratos |
| 17 | `scripts/forest/forest_demo.gd` | Script | Modificado | Vinculação do `hero` como target dinâmico na troca de salas |
| 18 | `tests/m6_c1_forest_combat_test.gd` | Teste | Novo | Suíte com 43 verificações automatizadas de combate e persistência |
| 19 | `tests/m6_c1_visual_capture.gd` | Teste | Novo | Gerador automatizado de capturas de evidências em GPU real |

---

## 4. RESULTADOS DA REGRESSÃO AUTOMATIZADA

| # | Suíte de Testes | Verificações | Resultado | Foco da Suíte |
| :-: | :--- | :---: | :---: | :--- |
| 1 | `tests/m6_c1_forest_combat_test.gd` | **43/43** | **100% PASS** | Bestiário M6-C1, perigos, poise, aeromobilidade e persistência |
| 2 | `tests/m6_b4_expansion_test.gd` | **77/77** | **100% PASS** | Setores 9 e 10, arena do Cervo, travessia bidirecional e segurança |
| 3 | `tests/m6_platform_accessibility_test.gd` | **44/44** | **100% PASS** | Acessibilidade física das plataformas aéreas nos 8 setores |
| 4 | `tests/m6_b1_expansion_test.gd` | **33/33** | **100% PASS** | Setores 3 e 4, calibração do Setor 1 e conexões |
| 5 | `tests/m6_b2_expansion_test.gd` | **46/46** | **100% PASS** | Setores 5 e 6, abismo de raízes e ossuário |
| 6 | `tests/m6_b3_expansion_test.gd` | **59/59** | **100% PASS** | Setores 7 e 8, fenda das vértebras e bosque dos ecos |
| 7 | `tests/m6_a_pilot_test.gd` | **24/24** | **100% PASS** | Preservação da reconstrução artística do Codex (S1 e S2) |
| 8 | `tests/recompensa_guardiao_test.gd` | **33/33** | **100% PASS** | Recompensa do Guardião (+1 HP permanente) e persistência |
| 9 | `tests/m5_h_aerial_test.gd` | **16/16** | **100% PASS** | Ataque aéreo ('J' no ar), física e cancelamento de queda |
| 10 | `tests/survival_test.gd` | **59/59** | **100% PASS** | Sistema de sobrevivência, dano, checkpoints e respawn |
| 11 | `tests/m6_b1_altar_accessibility_test.gd` | **15/15** | **100% PASS** | Santuário do Cervo: acesso aos apoios e patamar superior |
| 12 | `tests/combat_test.gd` | **36/36** | **100% PASS** | Ataque, hitbox e mecânica de dano da espada no solo |
| 13 | `tests/dash_vfx_test.gd` | **47/47** | **100% PASS** | Cinemática e partículas de dash terrestre e aéreo |
| 14 | `tests/boss_test.gd` | **59/59** | **100% PASS** | Combate contra Abade e Guardião, padrões de IA e vitória |
| **TOTAL** | **14 Suítes Automatizadas** | **591/591** | **100% PASS** | **Zero Falhas / Zero Regressões** |

---

## 5. AUDITORIA DE SEGURANÇA E INTEGRIDADE

### 5.1 Arquivo Pessoal de Save
- **Caminho:** `C:\Users\ovohe\AppData\Roaming\Godot\app_userdata\Cinzas do Juramento\cinzas_abbey_progress_v1.json`
- **Tamanho:** 215 bytes
- **SHA-256:** `4DB32167231D18C4B0872C73A8647FE6803C86C3E1FE5B49D68BE8012405797F`
- **Status:** **100% ÍNTEGRO E INALTERADO**.

### 5.2 15 Arquivos Protegidos Canônicos
Todos os 15 arquivos protegidos tiveram seus hashes SHA-256 auditados e confirmados bit-a-bit idênticos à baseline de segurança.

### 5.3 Estado Git
- **Commits:** ZERO (nenhum commit realizado).
- **Staging (`git diff --cached`):** ZERO bytes (vazio).
- **Push / Deploy:** ZERO.
- **Arquivos modificados rastreados:** Exclusivamente `scripts/forest/forest_demo.gd` e `scripts/forest/forest_sector.gd`.

---

## 6. CATÁLOGO DE EVIDÊNCIAS GRÁFICAS GPU (`tests/evidencias/m6c1/`)

1. `setor1_01_rastejante_e01.png`: Rastejante Fóssil E-01 patrulhando o solo do Setor 1 ($x=450, y=300$).
2. `setor1_02_rastejante_e02.png`: Rastejante Fóssil E-02 patrulhando a clareira leste do Setor 1 ($x=820, y=300$).
3. `setor2_01_rastejante_e03.png`: Rastejante Fóssil E-03 patrulhando o Bosque das Raízes ($x=330, y=300$).
4. `setor2_02_corvo_espectral_e04.png`: Corvo Espectral E-04 em voo sobre o desfiladeiro ($x=520, y=240$), com o Santuário ao fundo preservado vazio.
5. `setor3_01_espicula_p01.png`: Espículas Ósseas Temporizadas P-01 ativas no patamar de pedra e vértebras do Setor 3 ($x=480, y=290$).
6. `setor3_02_sentinela_e07.png`: Sentinela Ósseo E-07 em patrulha sob o dossel de arcos ósseos do Setor 3 ($x=660, y=276$).
7. `setor3_03_corvo_e06_rastejante_e05.png`: Visão de conjunto do Corvo E-06 e Rastejante E-05 na galeria inferior do Setor 3.
8. `setor4_01_sentinela_e08.png`: Sentinela Ósseo E-08 guardando a subida dos terraços da Clareira Ancestral ($x=480, y=300$).
9. `setor4_02_rastejante_e09.png`: Rastejante E-09 patrulhando o mirante final do Setor 4 ($x=820, y=260$).
10. `combate_poise_sentinela.png`: Demonstração de combate mostrando Aren atacando o Sentinela durante o windup do cutelo, com absorção por poise e telegrafia luminosa.

---

## 7. GUIA DE HOMOLOGAÇÃO MANUAL PARA O USUÁRIO

Para iniciar o playtest local e avaliar o comportamento visual e físico das novas criaturas:

1. Execute a cena de pilotos da Floresta dos Ossos:
   `scenes/forest/forest_pilots.tscn`
2. **Setor 1:**
   - Encontre os 2 Rastejantes (`E-01` e `E-02`).
   - Avalie a telegrafia de agachamento (0.30s) e golpeie no chão para confirmar a sobreposição da espada (2 golpes derrotam).
3. **Setor 2:**
   - Encontre o Rastejante `E-03` e o Corvo Espectral `E-04`.
   - Salte e desfira o golpe aéreo (`J` no ar) contra o Corvo para testar o contragolpe aéreo.
   - Prossiga à direita e confirme que o Santuário do Cervo continua sereno e desprovido de inimigos.
4. **Setor 3:**
   - Observe o ciclo temporizado das espículas fósseis (`P-01`): SAFE $\to$ tremor de WARNING $\to$ espículas pontiagudas de ACTIVE (1 de dano) $\to$ RECOVER.
   - Enfrente o Sentinela Ósseo (`E-07`): golpeie durante a subida do cutelo para constatar o **poise**; esquive com salto ou recuo e contra-ataque no **recovery**.
5. **Setor 4:**
   - Supere o Sentinela `E-08` nos terraços e o Rastejante `E-09` no mirante superior.
   - Avance para os Setores 5 a 10 para confirmar que permanecem preservados e vazios.
6. **Morte e Retorno:**
   - Ao morrer, confirme o retorno ao checkpoint com saúde cheia e restauração dos inimigos.
   - Ao transitar entre setores sem morrer, confirme que os inimigos derrotados permanecem caídos (sem respawn indevido).

---

## 8. ADITIVO M6-C1-ART-FIX02 — REMOÇÃO DE MARCADORES E ANIMAÇÕES MULTI-POSE

### 8.1 Correção 1: Remoção Absoluta de Pontos e Marcadores Azuis
- **Diagnóstico:** As rotinas visuais anteriores continham chamadas `r(eye_p.x, eye_p.y, 2, 2, EYE_TEAL)` e `draw_circle(..., EYE_TEAL)` que desenhavam retângulos/círculos ciano puros diretamente sobre os sprites e nas espículas.
- **Resolução:** Todas as chamadas de marcadores azuis foram eliminadas. O olhar e o brilho espectral agora fazem parte da textura anatômica dos novos atlas multi-pose.
- **Validação:** Inspeção pixel-a-pixel nas capturas GPU confirmou **0 pixels** no valor ciano/azul de marcador em todos os 10 setores.

### 8.2 Correção 2: Sistema de Animação Multi-Pose por Atlas (Adeus "Figurinhas Flutuando")
- Foram gerados e importados com mipmaps de alta precisão três atlas canônicos em `assets/art/m6c1/`:
  - `crow_atlas.png` (4x2, 8 frames, células 1006x977): Glide, Flap Up, Flap Mid, Flap Down, Alert, Dive, Recover, Hurt/Dead.
  - `sentinel_atlas.png` (4x2, 8 frames, células 888x1016): Idle, March 1, Neutral, March 2, Windup/Poise, Slam, Recovery, Hurt/Dead.
  - `crawler_atlas.png` (4x2, 8 frames, células 985x440): Idle, Scuttle 1, Neutral, Scuttle 2, Windup/Crouch, Bote/Lunge, Recovery, Hurt/Dead.
- **Dinâmica Visual Implementada:**
  - **Corvo:** Bate asas continuamente em voo (ciclo Flap Up $\to$ Mid $\to$ Down $\to$ Glide a 8 FPS com oscilação vertical acoplada), projeta asas abertas em Alert e recolhe as asas em seta aerodinâmica no mergulho direcionado pelo vetor de velocidade.
  - **Sentinela:** Marcha com passadas pesadas e oscilação alternada do cutelo ligada ao deslocamento horizontal, ergue o cutelo com as duas mãos acima do crânio durante o windup/poise, golpeia o solo provocando impacto no ataque ativo e apoia-se na lâmina durante a recuperação.
  - **Rastejante:** Rasteja com passada de 4 patas alternadas sincronizadas com a velocidade, encolhe a coluna rente ao chão na telegrafia e salta com corpo estendido e mandíbulas abertas durante o bote ativo.
- **Preservação Mecânica:** 100% dos parâmetros de colisão, hitboxes, hurtboxes, alcances, janelas de telegrafia, persistência e i-frames do jogador permaneceram intocados.
- **Validação de Testes:** 14 suítes automatizadas executadas com 100% de aprovação (591/591 verificações).
- **Painel de Evidências:** `tests/evidencias/m6c1/painel_m6_c1_art_fix02.png` consolidando 12 quadros comprobatórios de animação e ausência de pontos azuis.

---

## 9. ADITIVO M6-C1-ART-FIX03 — INTEGRAÇÃO DAS SEIS SPRITESHEETS OFICIAIS

### 9.1 Substituição Definitiva de Animações Procedurais por Quadros Reais Desenhados
- **Originais Brutos Preservados:** Os seis arquivos oficiais foram preservados intactos em `assets/art/m6c1/raw/`:
  1. `sprite_sheet_do_rastejante_fóssil.png` (Caminhada do Rastejante, 4 quadros reais).
  2. `ciclo_de_mordida_do_rastejante_fóssil.png` (Mordida do Rastejante, 4 quadros reais: Windup, Antecipação, Bote ativo, Recovery).
  3. `ciclo_de_caminhada_do_sentinela_ósseo.png` (Marcha do Sentinela, 4 quadros reais: Passo esquerdo, Peso, Passo direito, Retorno).
  4. `sentinela_ósseo_golpe_devastador.png` (Ataque Pesado do Sentinela, 4 quadros reais: Ready, Windup overhead com poise, Slam ativo, Recovery).
  5. `ciclo_de_voo_do_corvo_espectral.png` (Voo do Corvo, 4 quadros reais: Flap Up, Flap Mid, Flap Down, Recover/Glide).
  6. `ciclo_de_ataque_do_corvo_espectral.png` (Mergulho do Corvo, 4 quadros reais: Alert asas abertas, Windup, Active dive, Recover).

### 9.2 Calibração de Atlases e Alinhamento de Pivôs
- **Limpeza de Ruído e Haze:** Pixels residuais de baixa opacidade (`alpha < 25`) foram expurgados para garantir fundos transparentes 100% nítidos sem artefatos de borda.
- **Atlases Padronizados 4x2:**
  - `crawler_atlas.png` (1440x280 px, 4 colunas x 2 linhas de 360x140 px): pés alinhados no solo em $y=130\text{ px}$.
  - `sentinel_atlas.png` (1360x672 px, 4 colunas x 2 linhas de 340x336 px): pés rigorosamente alinhados na linha de solo em $y=325\text{ px}$.
  - `crow_atlas.png` (1120x640 px, 4 colunas x 2 linhas de 280x320 px): centro do tronco estabilizado em $(140, 160)\text{ px}$.
- **Movimento e Sincronização:**
  - **Rastejante:** Movimenta as 4 patas alternadamente sincronizadas com o deslocamento; durante o ataque, transiciona suavemente de agachamento tenso para antecipação com mandíbula abrindo, projetando o bote alongado na janela de dano ativo.
  - **Sentinela:** Marcha pesada alternando passos e oscilação de peso; no ataque, ergue o cutelo sobre a cabeça com as duas mãos durante o poise e desce em golpe descendente cravado no chão durante a janela ativa.
  - **Corvo:** Bate asas continuamente em ciclo de 4 poses a 8 FPS acoplado a elevação aerodinâmica; mergulha com asas recolhidas em flecha apontada na direção do vetor de velocidade.

### 9.3 Resultados da Validação Automatizada (17 Suítes)
- **Suíte Específica M6-C1-ART-FIX03:** `tests/m6_c1_art_fix03_test.gd` — **30/30 PASS** (100%).
- **Suítes de Regressão da Matriz:** 14/14 PASS.
- **Suíte SAVE-SAFETY-01:** `tests/save_safety_01_test.gd` — **44/44 PASS**.
- **Suíte Cinemática do Abade:** `tests/abbot_cinematic_test.gd` — **26/26 PASS**.
- **Total Global:** **17 Suítes Automatizadas — 100% PASS (Zero Falhas, Zero Regressões)**.

### 9.4 Evidências Visuais e Animações GPU
- Painel Consolidado 4x4: `tests/evidencias/m6c1/painel_m6_c1_art_fix03.png`.
- Animações Demonstrativas (GIFs):
  - `crawler_walk_anim.gif` e `crawler_bite_anim.gif`
  - `sentinel_walk_anim.gif` e `sentinel_slam_anim.gif`
  - `crow_flight_anim.gif` e `crow_dive_anim.gif`



