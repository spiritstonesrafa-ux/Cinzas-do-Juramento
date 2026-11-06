# Validação Técnica — Recompensas e Cenas Cinematográficas dos Chefes
**Projeto:** Cinzas do Juramento<br>
**Engine:** Godot 4.7.2 stable<br>
**Data:** 06/11/2026<br>
**Hardware de Referência:** NVIDIA GeForce RTX 2060 SUPER (Driver 621.01, OpenGL 3.3.0 Compatibility)<br>

---

## 1. Recompensa do Primeiro Boss — Guardião do Juramento

### 1.1 Identificação Canônica
- **Nome canônico:** `OathGuardian` (entidade), `GuardianEncounter` (adaptador na fase), `GuardianArena` (cena da arena).
- **Cena e script:** `scenes/boss/guardian.tscn`, `scripts/boss/guardian.gd`, `scripts/boss/encounter.gd`, `scripts/boss/guardian_conclusion.gd`.
- **Vida original identificada:** Aren possui vida base de **5 HP máximos** (`KnightSurvival.max_health = 5`).

### 1.2 Regra de Concessão e Balanceamento
- **Aumento de vida:** Concede permanentemente **+1 ponto de Vida Máxima** (5 → 6) após a primeira derrota legítima.
- **Regra de cura imediata:** Acrescenta exatamente 1 ponto à vida atual no instante da vitória (ex.: de 3/5 passa para 4/6), cumprindo a diretriz de não conceder cura total arbitrária.
- **Prevenção de duplicação (Idempotência):** Se o jogador refizer o confronto, o Guardião pode ser enfrentado novamente, mas a recompensa **NÃO** é concedida uma segunda vez. Reinícios, mortes, checkpoints ou recarregar o jogo não duplicam o HP máximo.
- **Compatibilidade com saves antigos:** Saves pré-existentes (que continham apenas o progresso do Abade) começam com 5 HP máximos normais; ao derrotarem o Guardião, recebem o upgrade de forma limpa sem sobrescrever nem corromper o progresso do dash.

### 1.3 HUD e Apresentação
- **Rótulo numérico:** `$HealthHUD/Life` atualiza de forma reativa para `VIDA X/6` via sinal `health_changed`.
- **Moldura visual (`health_frame.gd`):** O polígono de fundo escuro e as linhas de ornamentação agora expandem dinamicamente via `maxf(0, maximum - 5) * 7.0 px`, acomodando perfeitamente o 6º bloco de vida entre x=105 e x=111 sem vazamento visual nem desalinhamento.
- **Banner de Encerramento (`boss_hud.gd`):** Quando a recompensa é concedida pela primeira vez, o painel de vitória do Guardião exibe em cores temáticas:
  - `RECOMPENSA CONQUISTADA` (ciano espectral `Color("9de6d4")`)
  - `VIDA MÁXIMA +1` (ouro aquecido `Color("ffe8b0")`)

### 1.4 Testes Automatizados — Recompensa do Primeiro Boss
Arquivo: `tests/recompensa_guardiao_test.gd`<br>
Resultado: **33/33 PASS, 0 FAILURES**.
- P1: Progressão nova sem recompensa prévia.
- P2: Vida inicial base conferida (5/5).
- P3: Boss vivo com 10 HP na ativação.
- P4: Vitória por golpes legítimos até 0 HP.
- P5: Aumento exato de +1 no HP máximo (5 → 6).
- P6: Vida atual com incremento de +1 (3/5 → 4/6, sem cura total).
- P7: HUD numérico e frame visual atualizados.
- P8: Persistência após fechar e reabrir o jogo (novo processo carrega com 6 HP).
- P9: Persistência após morte (HP máximo permanece 6).
- P10: Respawn restaura vida completa para 6/6.
- P11: Nova vitória subsequente não duplica recompensa (permanece 6 HP).
- P12: Comportamento robusto com save ausente.
- P13: Perfil isolado sem recompensa antecipada.
- P14: Coexistência harmônica com o dash do segundo boss.
- P15: Migração e compatibilidade com saves antigos.

---

## 2. Cena Cinematográfica de Vitória do Abade das Correntes (Segundo Boss)

### 2.1 Identificação Canônica
- **Nome canônico:** `Abbot` (chefe), `AbbotArena` (arena), `AbbotBossBar` (HUD do chefe).
- **Cenas e scripts:** `scenes/abbey/abbot.tscn`, `scripts/abbey/abbot.gd`, `scripts/abbey/abbot_conclusion.gd`, `scripts/ui/abbot_boss_bar.gd`.

### 2.2 Sequência Cinematográfica Implementada
1. **Etapa 1 — Golpe final:**
   O golpe final leva o Abade a 0 HP. Imediatamente o combate é encerrado, o ataque é desarmado, hitboxes são limpas e o receptor de dano é desativado.
2. **Etapa 2 — Queda:**
   O Abade entra no estado `DEFEATED`, assumindo a pose 11 do atlas, devidamente apoiada no chão (offset de contato vertical 11.22 px, homologado em M5-G).
3. **Etapa 3 — Rompimento das correntes (0.3s a 1.8s):**
   8 partículas físicas de elos de corrente rompidos são disparadas radialmente do corpo do chefe, girando e caindo com gravidade e desvanecimento suave.
4. **Etapa 4 — Energia assimilada (0.8s a 2.4s):**
   Emanações de energia espectral sombria violeta (`Color(0.75, 0.48, 0.91)`) fluem do Abade em direção à posição exata de Aren. Aren recebe uma aura violeta pulsante com partículas sutis, transmitindo a assimilação da técnica.
5. **Etapa 5 — Recompensa e Apresentação (1.6s a 9.0s):**
   O HUD do Abade (`AbbotBossBar`) transiciona suavemente da barra de vida para o painel de vitória:
   - `VÍNCULO QUEBRADO` (topo)
   - `A Abadia Silenciosa — concluída`
   - `As correntes sucumbem e dissipam-se em cinzas.`
   - `NOVA HABILIDADE — PASSO DAS SOMBRAS` (violeta)
   - `Pressione Shift para deslizar.` (âmbar)
   - Rodapé: `Retorne pelo portal à esquerda (E).`
6. **Etapa 6 — Retorno ao gameplay:**
   Aren nunca fica travado; controles permanecem responsivos. O dash está desbloqueado imediatamente e permanentemente. Pressionar `E` retorna com segurança para o Coro (Setor 12).
7. **Revisita à Arena:**
   Ao retornar à arena com o Abade já derrotado, a cinematográfica dramática **NÃO** é repetida. O chefe permanece repousado no chão e o HUD exibe apenas a faixa elegante e discreta `Abadia concluída · Abade vencido`.

### 2.3 Testes Automatizados — Cena do Abade
Arquivo: `tests/abbot_cinematic_test.gd`<br>
Resultado: **26/26 PASS, 0 FAILURES**.
- P1: Entrada legítima na arena pelo Setor 12.
- P2: Abade vivo com 10 HP em progressão nova.
- P3: Ameaças ativas e em combate.
- P4: Vitória por golpes reais até 0 HP.
- P5: Interrupção imediata de ataques e desativação de hitboxes.
- P6: Animação de derrota em pose alinhada ao chão.
- P7: Início da cena cinematográfica e contagem de tempo.
- P8: Partículas físicas de rompimento das correntes ativas.
- P9: Feixes de assimilação de energia sombria fluindo para Aren.
- P10: Desbloqueio imediato e persistente do dash.
- P11: Persistência do dash em nova instância/processo do jogo.
- P12: Revisita à arena com boss derrotado.
- P13: Ausência de repetição da cena cinematográfica em revisitas.
- P14: Retorno seguro ao Setor 12 via tecla E.
- P15: Recuperação segura de progresso em caso de interrupção.

---

## 3. Evidências Visuais Nativas

As capturas gráficas foram gravadas em renderização real (RTX 2060 SUPER) e estão armazenadas em `tests/evidencias/recompensas/`:
- `guardiao_recompensa_1280x720.png`: Vitória do Guardião exibindo banner "RECOMPENSA CONQUISTADA · VIDA MÁXIMA +1".
- `hud_6_hp_1280x720.png`: HUD com `VIDA 6/6` e a moldura ornamentada expandida com o 6º bloco.
- `abade_queda_1280x720.png`: Abade em pose de derrota com elos de correntes partindo e caindo.
- `abade_assimilacao_1280x720.png`: Partículas violetas de energia sombria fluindo do chefe para Aren.
- `abade_recompensa_1280x720.png`: Apresentação completa "NOVA HABILIDADE — PASSO DAS SOMBRAS · Pressione Shift para deslizar".

---

## 4. Playtest Isolado Disponível

O script `tools/playtest_m5g.ps1` foi atualizado para suportar perfis isolados de teste para ambos os confrontos, protegendo o save pessoal do usuário:

```powershell
# Playtest isolado do Abade (arena sem dash, abade vivo):
powershell -ExecutionPolicy Bypass -File .\tools\playtest_m5g.ps1 -Cenario Boss

# Playtest isolado do Primeiro Boss (Cemitério/Guardião com HP 5, para testar +1 Max HP):
powershell -ExecutionPolicy Bypass -File .\tools\playtest_m5g.ps1 -Cenario Guardian

# Playtest da Campanha da Abadia:
powershell -ExecutionPolicy Bypass -File .\tools\playtest_m5g.ps1 -Cenario Campanha
```
