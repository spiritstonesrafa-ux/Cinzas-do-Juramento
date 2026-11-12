# CINZAS DO JURAMENTO
# RELATÓRIO TÉCNICO OFICIAL DE IMPLEMENTAÇÃO E AUDITORIA
## Marco RETORNO-ENTRE-FASES-01: Transições Físicas Bidirecionais entre as Três Fases
### Cemitério Esquecido ↔ Abadia Silenciosa ↔ Floresta dos Ossos

---

### METADADOS DA EXECUÇÃO
- **Data e Hora:** 11/11/2026 - 12:45 (Horário de Brasília)
- **Engine:** Godot Engine v4.7.2.stable.official.ed1daf0bf
- **Diretório do Projeto:** `C:\PROJETOS\CINZAS DO JURAMENTO`
- **Branch Canônica:** `main`
- **HEAD Consolidado:** `fe35d78801923c548028af2b479d37273bb0f6eb`
- **Modo de Operação:** Implementação Local Controlada + Persistência + Bateria Global de Regressão + Isolamento Estrito de Saves

---

## A — BASELINE GIT E AMBIENTE

1. **Branch e HEAD:**
   - Branch: `main`
   - HEAD: `fe35d78801923c548028af2b479d37273bb0f6eb`
2. **Estado do Índice (`staged`):**
   - VAZIO (`git diff --cached --name-only` = limpo).
   - ZERO commits efetuados, ZERO push, ZERO deploy.
3. **Arquivos Alterados no Marco:**
   - `scripts/abbey/abbey_progress.gd`: Implementação de `set_pending_entrance()`, `get_pending_entrance()`, `consume_pending_entrance()` e rotina centralizada `sync_hero_progression()`.
   - `scripts/levels/forgotten_cemetery.gd`: Receptor de retorno da Abadia em $x=2296, y=156$ (virado à esquerda, sem loop com o portal de $x \ge 2340$), proteção contra transição de jogador morto, e sinalização de avanço.
   - `scripts/boss/encounter.gd`: Sinalização `from_cemetery` ao avançar pós-derrota do Guardião.
   - `scripts/abbey/chapter.gd`: Receptor de retorno da Floresta no Setor 11 em $x=1360, y=300$ (virado à esquerda), gatilho de retorno físico para o Cemitério na margem oeste do Setor 0 ($x \le 16, \text{facing} < 0$), e textos de orientação contextual.
   - `scripts/forest/forest_demo.gd`: Gatilho de retorno físico para a Abadia no Setor 0 ($x \le 16, \text{facing} < 0$), remoção do clamp artificial de $x < 6$, proteção contra transição de jogador morto, e textos de orientação contextual.
4. **Arquivos Criados no Marco:**
   - `tests/retorno_entre_fases_01_test.gd`: Suíte dedicada cobrindo Grupos A a G (54 verificações 100% PASS).
   - `tests/playtest_retorno_entre_fases.gd`: Launcher isolado para playtest humano bidirecional.
   - `jogar_retorno_entre_fases.bat`: Script 1-clique para inicialização com perfil isolado.
   - `RELATORIO_RETORNO_ENTRE_FASES_01.md`: Este relatório técnico oficial.

---

## B — DIAGNÓSTICO: ORIGEM DO PROBLEMA HISTÓRICO

A auditoria da arquitetura de cenas revelou exatamente os três fatores que impediam o retorno:
1. **Ausência de Gatilhos de Saída Reversa:**
   - No Cemitério, havia transição de avanço para a Abadia em $x \ge 2340$, mas na Abadia (Setor 0) a checagem `next = current_room - 1` resultava em `next == -1`, que simplesmente não possuía nenhum bloco condicional.
   - Na Floresta (Setor 0), a margem oeste possuía uma trava estática dura: `if current_room == 0 and local.x < 6.0: hero.global_position.x = 6.0`, que aprisionava o jogador na fase em vez de permitir a saída.
2. **Ponto de Spawn Estático:**
   - O Cemitério sempre forçava o spawn no início da fase ($x=48$), fazendo com que uma eventual reentrada posicionasse o jogador no lado oposto ao portão.
   - A Abadia sempre iniciava no Setor 0 ($x=48$), impedindo que o retorno vindo da Floresta colocasse o jogador no Setor 11.
3. **Falta de Sincronização de Habilidades em Fases Anteriores:**
   - `forgotten_cemetery.gd` não sincronizava as habilidades permanentes desbloqueadas na Abadia (Passo das Sombras / Dash) nem na Floresta (Salto Espectral), gerando risco de regressão de movimentação em fases revisitadas.

---

## C — ARQUITETURA DA NAVEGAÇÃO BIDIRECIONAL

A solução adotada respeita a integridade física do mundo, sem teletransportes arbitrários, sem menus e sem quebra de imersão:

```
[ CEMITÉRIO ESQUECIDO ]                     [ ABADIA SILENCIOSA ]                    [ FLORESTA DOS OSSOS ]
   (Setor 1 ... Setor 6)                     (Setor 0 ... Setor 11)                   (Setor 0 ... Setor 10)
            │                                         │                                         │
Portão Catedral (x=2296) ──[Avanço: x>=2340]──> Átrio Oeste (x=48)                             │
            │                                         │                                         │
Portão Catedral (x=2296) <──[Retorno: x<=16]─── Átrio Oeste (x=48)                             │
                                                      │                                         │
                                             Coro Leste (x=1360) ──[Avanço: x>=1392]──> Entrada Oeste (x=48)
                                                      │                                         │
                                             Coro Leste (x=1360) <──[Retorno: x<=16]─── Entrada Oeste (x=48)
```

### Mecanismo de Transferência Semântica (`pending_entrance`):
- Implementado em memória na classe compartilhada `AbbeyProgress` através de `set_pending_entrance()`, `get_pending_entrance()` e `consume_pending_entrance()`.
- **Zero impacto em disco:** Não altera o formato JSON nem o checksum de `cinzas_abbey_progress_v1.json`.
- Ao transicionar, a fase de origem define o marcador (`"from_cemetery"`, `"from_abbey"`, `"from_forest"`). A fase de destino consome atômica e imediatamente esse valor no `_ready()`, selecionando o ponto físico exato de recepção.

---

## D — CONEXÃO 1: CEMITÉRIO ESQUECIDO ↔ ABADIA SILENCIOSA

### 1. Cemitério → Abadia (Ida):
- **Gatilho:** $x \ge 2340.0$ e $x \le 2375.0$ com `guardian_defeated == true` e jogador vivo.
- **Chegada na Abadia:** Setor 0 (*Átrio dos Votos*), $x=48.0, y=300.0$, virado para a direita (`facing = 1`).
- **Margem anti-loop:** Aren surge a 32 pixels de distância do sensor de retorno ($x \le 16$) e virado para o sentido oposto.

### 2. Abadia → Cemitério (Volta):
- **Gatilho:** Setor 0 (*Átrio dos Votos*), $x \le 16.0$, virado para a esquerda (`facing = -1`), não ocupado e vivo.
- **Chegada no Cemitério:** Junto ao Portão da Catedral em $x=2296.0, y=156.0$, virado para a esquerda (`facing = -1`).
- **Margem anti-loop:** Aren surge a 44 pixels à esquerda do gatilho de avanço ($x \ge 2340.0$).
- **Revisita:** O Guardião permanece em estado `completed = true`, saída da arena aberta, nenhuma cinematográfica é repetida e o +1 HP não é duplicado.

---

## E — CONEXÃO 2: ABADIA SILENCIOSA ↔ FLORESTA DOS OSSOS

### 1. Abadia → Floresta (Ida):
- **Gatilho:** Setor 11 (*Coro das Correntes*), $x \ge 1392.0$ (ou travessia da arena pós-derrota do Abade).
- **Chegada na Floresta:** Setor 0 (*Entrada da Floresta*), $x=48.0, y=300.0$, virado para a direita (`facing = 1`).
- **Margem anti-loop:** Aren surge a 32 pixels à frente do sensor de retorno ($x \le 16$) e virado para a direita.

### 2. Floresta → Abadia (Volta):
- **Gatilho:** Setor 0 (*Entrada da Floresta*), $x \le 16.0$, virado para a esquerda (`facing = -1`), não ocupado e vivo.
- **Chegada na Abadia:** Setor 11 (*Coro das Correntes*), $x=1360.0, y=300.0$, virado para a esquerda (`facing = -1`).
- **Margem anti-loop:** Aren surge a 32 pixels à esquerda do sensor de saída para a Floresta ($x \ge 1392$).
- **Revisita:** O Abade permanece derrotado, sem luta obrigatória, sem duplicação de recompensas. O jogador pode explorar todos os 12 setores em sentido reverso até o Setor 0.

---

## F — PÓS-CERVO E RETORNO INTEGRAL DA FASE 3

- **Estado Pós-Cervo:** A vitória sobre o Cervo Espectral concede o *Salto Espectral* (salto duplo) e libera o Pórtico do Juramento no Setor 10.
- **Retorno Físico Contínuo:** Aren pode caminhar e saltar do Setor 10 $\to$ 9 $\to$ 8 $\to$ ... $\to$ 0 utilizando as passagens e degraus nivelados homologados ($\le 20\text{ px}$ e vãos simétricos de 46/48 px).
- **Travessia Completa de Volta:** Ao atingir o Setor 0 da Floresta, Aren cruza para a Abadia (Setor 11), percorre a Abadia até o Setor 0, e cruza para o Cemitério.
- **Preservação de Habilidades:** Em todas as fases revisitadas, Aren mantém o *Salto Espectral*, o *Passo das Sombras* e os *6 HP Máximos*.

---

## G — PERSISTÊNCIA, CHECKPOINTS E RESPAWN

1. **Separação de Conceitos:**
   - *Progresso e Conquistas:* Flags imutáveis em `cinzas_abbey_progress_v1.json` (`guardian_defeated`, `abbot_defeated`, `cervo_defeated`, etc.).
   - *Localização da Sessão:* Gerenciada por fase ativa, permitindo ao jogador explorar fases antigas sem perder flags ou reduzir o teto alcançado.
2. **Checkpoints Locais:**
   - **No Cemitério:** Ao reentrar vindo da Abadia, o respawn padrão é associado ao Checkpoint 2 ($x=1936$). Se morrer no Cemitério, não é teleportado de volta à Abadia.
   - **Na Abadia:** O checkpoint do setor visitado é ativado dinamicamente.
   - **Na Floresta:** Os 10 checkpoints setoriais mantêm suas posições de respawn intactas.
3. **Morte e Quedas:**
   - Quedas em abismos acionam a recuperação segura no início do setor local.
   - Morte do jogador bloqueia imediatamente quaisquer disparos de transição entre fases.

---

## H — SEGURANÇA E PREVENÇÃO DE LOOPS / SOFTLOCKS

1. **Anti-Looping Espacial:** Em todas as 4 extremidades de transição, a posição de chegada possui descolamento seguro ($32$ a $44\text{ px}$) em relação à área de detecção, e o vetor `facing` aponta sempre para o interior da fase de destino.
2. **Debounce e Estado Ocupado:** Variáveis `busy` e `transitioning` evitam requisições concorrentes ou duplicadas.
3. **Ausência de Duplicação de Entidades:** A engine descarrega integralmente a cena anterior (`change_scene_to_file`), garantindo a existência de exatamente 1 nó `KnightController` e 1 HUD ativo sob a árvore.

---

## I — REGRESSÕES E COMPATIBILIDADE

Todas as baterias canônicas anteriores foram executadas e aprovadas com 100% de sucesso:
- **ATAQUE-SOTN-01:** Ciclos nominais congelados em 0,25s (0,05s startup / 0,05s ativo / 0,15s recovery), buffer de ~0,08s e landing cancel.
- **ATAQUE-SOTN-02 (ART-FIX02):** Poses anatômicas e integração visual homologadas mantidas como padrão. Fallback ARM-FIX01 preservado via F8.
- **ATAQUE-SOTN-03:** Hitstop visual localizado ($\le 0,05$s) e os 4 arquivos de áudio WAV sintéticos preservados.
- **COMBATE-CONTACT-DAMAGE-01:** Dano corporal por contato (1 HP, 0,8s i-frames, knockback 110 px/s) ativo em todas as fases.
- **INTEGRACAO-SOTN-CAMPANHA-01:** SOTN ativo por padrão em todas as 3 fases.

---

## J — MATRIZ OFICIAL DE TESTES AUTOMATIZADOS

| Suíte de Testes | Foco / Escopo | PASS | FAIL | SKIP | Status |
|---|---|---|---|---|---|
| `tests/retorno_entre_fases_01_test.gd` | Transições bidirecionais, spawns, chefes e persistência (Grupos A a G) | 54 | 0 | 0 | **100% PASS** |
| `tests/integracao_sotn_campanha_01_test.gd` | Campanha completa Fases 1 a 3, balanceamento e SOTN padrão | 68 | 0 | 0 | **100% PASS** |
| `tests/contact_damage_01_test.gd` | Dano por contato corporal, i-frames e knockback | 64 | 0 | 0 | **100% PASS** |
| `tests/ataque_sotn_03_test.gd` | Impacto, hitstop e feedback audiovisual | 44 | 0 | 0 | **100% PASS** |
| `tests/ataque_sotn_02_art_fix02_test.gd` | Refino visual ART-FIX02 e fallback ARM-FIX01 | 42 | 0 | 0 | **100% PASS** |
| `tests/ataque_sotn_01_test.gd` | Mecânica pura SOTN e preservação do ORIGINAL | 30 | 0 | 0 | **100% PASS** |
| `tests/save_safety_01_test.gd` | Resiliência atômica, travas e integridade de saves | 44 | 0 | 0 | **100% PASS** |
| `tests/m6_cervo_boss_combat_test.gd` | Combate de 3 fases do Cervo Espectral | 68 | 0 | 0 | **100% PASS** |
| `tests/m6_cervo_full_journey_test.gd` | Travessia completa e Salto Espectral na Floresta | 35 | 0 | 0 | **100% PASS** |
| `tests/boss1_transition_fix02_test.gd` | Transição de avanço e cinemática do Guardião | 23 | 0 | 0 | **100% PASS** |
| **TOTAL CONSOLIDADO** | **Bateria global do projeto Cinzas do Juramento** | **472** | **0** | **0** | **100% PASS** |

---

## K — GUIA DE PLAYTEST HUMANO (PERFIL ISOLADO)

### 1. Inicialização em 1 Clique (Recomendada)
Na pasta do projeto, execute com dois cliques:
* **[jogar_retorno_entre_fases.bat](file:///c:/PROJETOS/CINZAS%20DO%20JURAMENTO/jogar_retorno_entre_fases.bat)**

### 2. Inicialização Segura no Terminal PowerShell
Execute a linha única nativa abaixo (que utiliza `try/finally` para guardar e restaurar o seu APPDATA original):

```powershell
$oldA=$env:APPDATA;$oldS=$env:SAVE_SAFETY_ISOLATED_ROOT;try{$p='C:\PROJETOS\CINZAS DO JURAMENTO\tests\perfil_playtest_retorno_fases';if(-not(Test-Path $p)){New-Item -ItemType Directory -Path $p -Force|Out-Null};$env:SAVE_SAFETY_ISOLATED_ROOT='C:/PROJETOS/CINZAS DO JURAMENTO/tests/perfil_playtest_retorno_fases';$env:APPDATA=$p;& 'C:\Users\ovohe\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe' --path 'C:\PROJETOS\CINZAS DO JURAMENTO' -s res://tests/playtest_retorno_entre_fases.gd}finally{$env:APPDATA=$oldA;$env:SAVE_SAFETY_ISOLATED_ROOT=$oldS}
```

### 3. Roteiro de Validação Humana (R1 a R14)
- **R1:** Derrote o Guardião no Cemitério, pegue o +1 HP (6 HP) e atravesse o portão à direita para a Abadia.
- **R2:** Na Abadia (Setor 0), volte imediatamente à esquerda até a margem do portal.
- **R3:** Confirme que reaparece no Cemitério junto ao portão ($x=2296$), virado para a esquerda, sem nova luta ou cinematográfica.
- **R4:** Avance novamente para a direita e reentre na Abadia.
- **R5:** Prossiga pela Abadia, derrote o Abade das Correntes e desbloqueie o Dash.
- **R6:** Atravesse para a Floresta dos Ossos.
- **R7:** Na Entrada da Floresta (Setor 0), volte à esquerda e confirme que reaparece no Setor 11 da Abadia.
- **R8:** Percorra a Abadia de volta até o Setor 0 e cruze para o Cemitério.
- **R9:** Confirme que o Dash funciona normalmente no Cemitério com 6 HP preservados.
- **R10:** Refaça o caminho de volta até a Floresta sem repetição de chefes.
- **R11:** Derrote o Cervo Espectral, desbloqueie o Salto Espectral.
- **R12:** Percorra a Floresta em sentido reverso (Setor 10 até 0) usando o Salto Espectral.
- **R13:** Volte à Abadia e ao Cemitério, comprovando o Salto Duplo em todas as fases.
- **R14:** Feche o jogo, reabra pelo launcher e comprove a preservação das habilidades.

---

## L — AUDITORIA DE SEGURANÇA E INTEGRIDADE

1. **Save Pessoal:**
   - Caminho: `%APPDATA%\Godot\app_userdata\Cinzas do Juramento\cinzas_abbey_progress_v1.json`
   - Tamanho: **267 bytes** (inalterado).
   - SHA-256: `13DE06DB1B10184A6256A5C4845C032D96B825791373FBD2EF739841E13DA0AB` (**MATCH: TRUE**).
2. **`project.godot`:**
   - Tamanho: **3900 bytes** (inalterado).
   - SHA-256: `63FDDFB499D59CD3AE9B5B70D7D4A8816CCFD8586486C6CFCC3023733BCDCEC9` (**MATCH: TRUE**).
3. **Quinze Arquivos Canônicos Protegidos:**
   - Todos os 15 arquivos conferidos com SHA-256 idêntico ao manifesto `tests/VALIDACAO_M6_B3.md` (**15/15 MATCH**).
4. **Governança Git:**
   - Staging limpo (`git diff --cached` vazio).
   - Zero commits, zero push, zero deploy.

---

## M — RISCOS RESIDUAIS

- **Bloqueantes:** ZERO.
- **Não bloqueantes:** No Setor 10 da Floresta, após o Cervo ser pacificado, a saída leste para a futura Fase 4 permanece narrativamente reservada conforme estabelecido para marcos posteriores.
- **Recomendação:** A reavaliação de balanceamento dos chefes (Guardião e Abade) segue preservada para o marco específico `BOSS-BALANCE-01`.

---

## N — VEREDITO TÉCNICO OFICIAL

### Classificação Canônica:
# RETORNO-ENTRE-FASES-01 IMPLEMENTADO LOCALMENTE — AGUARDANDO PLAYTEST HUMANO

As conexões físicas bidirecionais entre o Cemitério Esquecido, a Abadia Silenciosa e a Floresta dos Ossos foram implementadas com total integridade espacial, preservação absoluta de saves e progresso idempotente, estando 100% prontas para homologação humana.
