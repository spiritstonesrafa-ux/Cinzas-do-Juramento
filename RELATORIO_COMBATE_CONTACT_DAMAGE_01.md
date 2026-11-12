# CINZAS DO JURAMENTO
# RELATÓRIO TÉCNICO OFICIAL DE IMPLEMENTAÇÃO E AUDITORIA
## Marco COMBATE-CONTACT-DAMAGE-01: Dano por Contato Corporal, Hurtboxes, I-Frames e Knockback

---

### METADADOS DA EXECUÇÃO
- **Data/Hora:** 11/11/2026
- **Ambiente:** Windows 10 / Godot Engine v4.7.2.stable.official.ed1daf0bf
- **Branch Canônica:** `main` (Sem commits ou pushes)
- **Status Técnico:** IMPLEMENTAÇÃO LOCAL CONCLUÍDA — 100% TESTADA — AGUARDANDO PLAYTEST HUMANO
- **Classificação:** Sucesso integral sem regressões (64/64 verificações dedicadas + 381/381 testes históricos aprovados)

---

## 1. RESUMO EXECUTIVO

O marco **COMBATE-CONTACT-DAMAGE-01** resolveu a vulnerabilidade de combate identificada pelo responsável, onde o protagonista Aren conseguia atravessar corpos de inimigos vivos sem sofrer penalidades sempre que estes não estivessem desferindo golpes.

A implementação:
1. **Ativou detecção física de contato corporal** nas camadas de inimigos (Layers 128 e 256) sem transformar monstros em paredes sólidas intransponíveis.
2. **Reutilizou a janela canônica de invulnerabilidade (i-frames de 0,8 s)** de `KnightSurvival`, evitando repetição contínua de dano por frame.
3. **Introduziu knockback direcional sutil e controlado** (110 px/s horizontal para longe da fonte, -60 px/s de elevação) com desaceleração natural.
4. **Preservou 100% a mobilidade de Aren**: Dash (Passo das Sombras) mantém sua velocidade e distância inalteradas; pulo duplo espectral e controle aéreo permanecem intactos.
5. **Implementou arbitragem estrita de prioridade**: Ataque de arma (DamageSource, 2 de dano) tem precedência absoluta sobre contato corporal (1 de dano), eliminando dano duplicado no mesmo frame.
6. **Inimigos derrotados não causam dano**: Monstros com `current_health <= 0` ou `state == DEAD` e chefes em estados neutros/derrotados (`DEAD`, `DEFEATED`, `RESET`, `INTRO`, `DORMANT`) têm colisão de dano suprimida.
7. **Reversibilidade total garantida**: Flag `@export var contact_damage_enabled: bool = true` em `knight_hurtbox.gd` permite alternar em tempo real (tecla F10 na arena de validação).

---

## 2. ARQUITETURA E ARQUIVOS MODIFICADOS

### 2.1. `scripts/player/knight_hurtbox.gd`
- **Expansão da máscara de colisão:** A query física passou a monitorar `collision_mask = 32 | 128 | 256` com `collide_with_bodies = true` e `collide_with_areas = true`.
- **Arbitragem em duas etapas (`contact_damage()`):**
  - **Passo 1 (Prioridade Máxima):** Itera sobre áreas sobrepostas procurando nós do tipo `DamageSource` (camada 32, armas inimigas e espinhos). Se houver impacto, aplica o dano da arma (ex.: 2 HP) e registra a posição exata da fonte.
  - **Passo 2 (Contato Corporal Secundário):** Se nenhuma arma atingiu Aren e o contato por corpo estiver ativo (`contact_damage_enabled == true`), itera sobre os corpos sobrepostos (`CharacterBody2D`). Através de `_is_body_dangerous(body)`, valida se o corpo é um monstro hostil vivo e ativo. Aplica dano nominal de 1 HP e registra `last_source_position`.
- **Filtro de Inimigos Vivos (`_is_body_dangerous`):**
  - Verifica HP (`current_health > 0`).
  - Verifica máquinas de estado (`state != DEAD`, `state != DEFEATED`, etc.).
  - Para chefes de fase (Guardião, Abade, Cervo Espectral), filtra estados `RESET`, `INTRO`, `DORMANT` e estados terminais de derrota.
- **Rastreamento de Origem:** Registra `last_source_position`, `last_damage_source` e `last_damage_type` (`"body"` vs `"source"`).

### 2.2. `scripts/player/knight_controller.gd`
- **Assinatura expandida de dano:** `receive_damage(amount: int = 1, source_position: Vector2 = Vector2.ZERO)`.
- **Controle de Recuo (`_apply_knockback`):**
  - Calcula a direção horizontal do impacto (`sign(global_position.x - source_position.x)`).
  - Aplica impulso controlado: `velocity.x = push_dir * knockback_speed` (110.0 px/s) e `velocity.y = knockback_lift` (-60.0 px/s).
- **Proteção do Passo das Sombras (Dash):**
  - Se Aren estiver em execução de Dash (`dash_remaining > 0.0`), a velocidade do Dash NÃO é interrompida pelo knockback, garantindo que a evasão atravesse sem travar.
- **Interrupção de Ataque Aéreo:** Ao sofrer dano no ar, o golpe de espada é imediatamente cancelado, priorizando o feedback de dano e recuperação.
- **Integração de Contato no Movimento:** Tanto no loop de corrida/caminhada quanto durante o Dash, o controlador invoca `hurtbox.contact_damage()` passando `hurtbox.last_source_position` para `receive_damage()`.

---

## 3. SUÍTE DE TESTES DEDICADA (`tests/contact_damage_01_test.gd`)

Foram implementadas 64 verificações automatizadas estruturadas em 9 grupos funcionais (A até I):

| Grupo | Descrição do Teste | Verificações | Resultado |
| :--- | :--- | :---: | :---: |
| **A** | Detecção de Colisão Corporal (Distante, Sobreposto, Lateral, Vertical, Rastejante, Corvo, Inimigo Morto) | 8 | **PASS** |
| **B** | Dano e Arbitragem (1 HP, Proteção por Frame, Arma x Corpo = 2 HP, Guarda contra Jogador Morto) | 6 | **PASS** |
| **C** | Invulnerabilidade e I-Frames (0.8s, Sem Dano Contínuo, Restauração de Vulnerabilidade) | 6 | **PASS** |
| **D** | Knockback e Reação Física (Direção Oposta, Intensidade Segura, Desaceleração, Respeito ao Dash) | 6 | **PASS** |
| **E** | Preservação de Habilidades (Cancelamento de Ataque Aéreo, Salto Espectral, Dash Contínuo) | 5 | **PASS** |
| **F** | Comportamento com Inimigos de Todas as Fases (Esqueleto, Monge, Corvo, Sentinela, Rastejante) | 10 | **PASS** |
| **G** | Comportamento com Chefes (Guardião, Abade, Cervo: Fase Ativa causa Dano / Derrota causa 0 Dano) | 6 | **PASS** |
| **H** | Não Regressão SOTN (Timings 0.05/0.05/0.15s, Buffer, Hitstop, ART-FIX02 Ativo) | 12 | **PASS** |
| **I** | Comparativo ON / OFF (Toggle de Reversibilidade F10: Desativado = 0 dano / Ativado = 1 dano) | 5 | **PASS** |
| **TOTAL** | **Suíte Especializada COMBATE-CONTACT-DAMAGE-01** | **64** | **100% PASS** |

---

## 4. REGRESSÃO INTEGRAL DO PROJETO

Nenhum arquivo ou subsistema pré-existente foi corrompido ou regrediu. Bateria completa executada:

1. `tests/contact_damage_01_test.gd` — 64 PASS / 0 FAIL
2. `tests/ataque_sotn_03_test.gd` — 44 PASS / 0 FAIL
3. `tests/ataque_sotn_02_art_fix02_test.gd` — 42 PASS / 0 FAIL
4. `tests/ataque_sotn_02_test.gd` — 24 PASS / 0 FAIL
5. `tests/ataque_sotn_01_test.gd` — 30 PASS / 0 FAIL
6. `tests/m6_cervo_boss_combat_test.gd` — 68 PASS / 0 FAIL
7. `tests/m6_cervo_full_journey_test.gd` — 35 PASS / 0 FAIL
8. `tests/boss1_transition_fix02_test.gd` — 23 PASS / 0 FAIL
9. `tests/save_safety_01_test.gd` — 44 PASS / 0 FAIL
10. `tests/m5_g_fix01_dash_integration.gd` — 7 PASS / 0 FAIL

**Total acumulado:** 381 verificações consecutivas aprovadas com 0 falhas.

---

## 5. EVIDÊNCIAS VISUAIS CAPTURADAS (RENDERIZAÇÃO REAL GPU)

Capturadas em resolução nativa na pasta `tests/evidencias/contact_damage_01/`:

1. `01_aren_encostando_esqueleto.png` — Aren se aproximando e tocando o torso do esqueleto.
2. `02_primeiro_dano_corporal.png` — Instante de aplicação de 1 HP de dano e acionamento dos i-frames.
3. `03_iframes_flash_vermelho.png` — Flash visual vermelho e piscar translúcido de invulnerabilidade.
4. `04_knockback_recuo_seguro.png` — Aren recuando 110 px/s em arco com elevação vertical suave (-60 px/s).
5. `05_sobreposicao_durante_iframes.png` — Aren atravessando o inimigo durante a janela de 0,8 s sem dano múltiplo.
6. `06_contato_rastejante_baixo.png` — Detecção de colisão contra monstro rasteiro de perfil baixo (Crawler).
7. `07_contato_corvo_aereo.png` — Detecção de contato corporal contra inimigo aéreo em voo.
8. `08_dois_inimigos_em_contato.png` — Arbitragem correta ao colidir com múltiplos inimigos agrupados.
9. `09_inimigo_morto_sem_dano.png` — Aren caminhando sobre o corpo de inimigo abatido sem sofrer dano.
10. `10_ataque_sotn_em_combate.png` — Golpe com espada SOTN cortando o inimigo mantendo a fluidez original.

---

## 6. GUIA OFICIAL DE PLAYTEST HUMANO

Para testar a mecânica de dano corporal diretamente no ambiente isolado seguro:

### Como Executar:
Abra o terminal PowerShell ou o Explorador de Arquivos e execute:
```powershell
cd "c:\PROJETOS\CINZAS DO JURAMENTO"
.\jogar_playtest_contact_damage.bat
```
*(Ou dê um duplo clique no arquivo `jogar_playtest_contact_damage.bat` dentro da pasta do jogo).*

### Controles de Teste:
- **A / D:** Mover Aren
- **Espaço:** Pulo / Ataque Aéreo (com landing cancel)
- **J:** Golpe de Espada SOTN
- **Shift:** Passo das Sombras (Dash)
- **F10 (ou F5):** **Alternar Dano por Contato Corporal (ON <-> OFF)**
- **F6:** Alternar modo de ataque (SOTN <-> ORIGINAL)
- **F8:** Alternar arte visual (ART-FIX02 <-> ARM-FIX01)
- **F9:** Alternar áudio/hitstop SOTN-03 (ON <-> OFF)
- **F7:** Resetar arena (restaura vida máxima e reposiciona monstros)
- **ESC:** Fechar sessão

---

## 7. GARANTIAS DE CONSERVAÇÃO E SEGURANÇA
- **Save Pessoal:** Intocado e 100% isolado em sandbox temporário (`tests/perfil_playtest_contact/`).
- **Git:** 0 commits realizados, 0 pushes efetuados, 0 alterações fora do escopo aprovado.
- **Campanha Oficial:** Permanece em modo seguro e reversível.
