# RELATÓRIO DE CONSOLIDAÇÃO — M6-B4 + FIX01
## AUDITORIA PRÉ-COMMIT, VALIDAÇÃO DA CANDIDATA E CONSOLIDAÇÃO SELETIVA
### Fase 3: Floresta dos Ossos — Setores 9 e 10 (Conclusão Estrutural e Futura Arena do Cervo)

- **Data:** 07/11/2026
- **Engine:** Godot 4.7.2 (`Godot_v4.7.2-stable_win64_console.exe`)
- **GPU de Validação:** NVIDIA GeForce RTX 2060 SUPER (Driver 621.01)
- **Branch:** `main`
- **HEAD Anterior:** `388dc848ac71d8d8e0294139ead7e78e066fbbab`
- **Mensagem Autorizada:** `feat(forest): consolida M6-B4 e FIX01 setores 9 e 10`
- **Status da Auditoria:** **GO (Aprovado para Consolidação Local)**

---

## A. BASELINE DO REPOSITÓRIO

- **Diretório do Projeto:** `C:\PROJETOS\CINZAS DO JURAMENTO`
- **Branch Ativa:** `main`
- **HEAD de Origem:** `388dc848ac71d8d8e0294139ead7e78e066fbbab`
- **Staging Inicial:** Totalmente vazio (`git diff --cached` com 0 bytes).
- **Alterações Locais Externas:** Preservadas e blindadas contra descarte ou inclusão.

---

## B. MANIFESTO DOS 35 ARQUIVOS CANDIDATOS

A consolidação engloba exclusivamente 35 arquivos divididos em:
1. **Cenas (2):** `scenes/forest/sector_09.tscn`, `scenes/forest/sector_10.tscn`
2. **Recursos Artísticos e Proveniência (5):** `assets/art/m6a/forest_sector9_bg.png`, `.import`, `assets/art/m6a/forest_sector10_bg.png`, `.import`, `assets/art/m6a/PROVENANCE.md`
3. **Scripts de Gameplay e Level Design (4):** `scripts/forest/forest_art.gd`, `forest_demo.gd`, `forest_layout.gd`, `forest_sector.gd`
4. **Testes Automatizados (3):** `tests/m6_b3_expansion_test.gd`, `tests/m6_b4_expansion_test.gd`, `tests/m6_b4_visual_capture.gd`
5. **Documentação Técnica e Manifestos (4):** `tests/VALIDACAO_M6_B4.md`, `tests/VALIDACAO_M6_B4_FIX01.md`, `tests/MANIFESTO_COMMIT_M6_B4_FIX01.md`, `tests/VALIDACAO_COMMIT_M6_B4_FIX01.md`
6. **Evidências Gráficas GPU (17):** 17 capturas PNG em `tests/evidencias/m6b4/` cobrindo panorâmicas, travessia de abismo, arena, pórtico e FIX01 (sem vitória prematura e retorno ao Setor 9).

---

## C. INTEGRIDADE CRIPTOGRÁFICA E ARQUIVOS PROTEGIDOS

### 1. Auditoria do Arquivo Pessoal de Save
- **Caminho:** `C:\Users\ovohe\AppData\Roaming\Godot\app_userdata\Cinzas do Juramento\cinzas_abbey_progress_v1.json`
- **Tamanho:** **215 bytes** (inalterado)
- **SHA-256:** `4DB32167231D18C4B0872C73A8647FE6803C86C3E1FE5B49D68BE8012405797F`
- **Resultado:** **100% Íntegro e Blindado**.

### 2. Auditoria dos 15 Arquivos Protegidos Canônicos
Todos os 15 arquivos protegidos do repositório (`project.godot`, imagens de referência de arte e `.import` legados) foram verificados bit a bit e permanecem 100% íntegros.

---

## D. TESTES E REGRESSÃO AUTOMATIZADA

Regressão executada com isolamento de ambiente (`APPDATA` temporário e `SAVE_SAFETY_ISOLATED_ROOT`):

| # | Suíte de Testes | Verificações | Resultado | Foco |
| :-: | :--- | :---: | :---: | :--- |
| 1 | `tests/m6_b4_expansion_test.gd` | **77/77** | **PASS** | Setores 9 e 10, arena, retorno bidirecional e ausência de conclusão prematura |
| 2 | `tests/m6_platform_accessibility_test.gd` | **44/44** | **PASS** | Cinemática e alcance de plataformas nos 8 setores |
| 3 | `tests/m6_b3_expansion_test.gd` | **59/59** | **PASS** | Setores 7 e 8: geometria, limites e checkpoints |
| 4 | `tests/m6_b2_expansion_test.gd` | **46/46** | **PASS** | Setores 5 e 6: topografia e fluxo contínuo |
| 5 | `tests/m6_b1_expansion_test.gd` | **33/33** | **PASS** | Setores 3 e 4: compatibilidade pós-calibração S1 |
| 6 | `tests/m6_b1_altar_accessibility_test.gd` | **15/15** | **PASS** | Altar do Santuário do Cervo: acesso aos apoios |
| 7 | `tests/m6_a_pilot_test.gd` | **24/24** | **PASS** | Setores 1 e 2: reconstrução artística do Codex |
| 8 | `tests/combat_test.gd` | **36/36** | **PASS** | Ataque com espada, hitbox e ataque aéreo M5-H |
| 9 | `tests/dash_vfx_test.gd` | **47/47** | **PASS** | Cinemática e partículas de dash terrestre e aéreo |
| 10 | `tests/boss_test.gd` | **59/59** | **PASS** | Encontros do Guardião e Abade |
| 11 | `tests/recompensa_guardiao_test.gd` | **33/33** | **PASS** | Recompensa do Guardião (+1 Max HP) e persistência |
| 12 | `tests/save_safety_01_test.gd` | **44/44** | **PASS** | Blindagem e integridade do save pessoal |
| 13 | `tests/abbot_cinematic_test.gd` | **26/26** | **PASS** | Cinemática pós-Abade e concessão do dash |
| **TOTAL** | **13 Suítes Automatizadas** | **543/543** | **100% PASS** | **Aprovação Integral de Regressão** |

---

## E. DECISÃO GO / NO-GO

- HEAD de origem correto (`388dc84...`): **SIM**
- Branch correta (`main`): **SIM**
- Manifesto dos 35 arquivos completo: **SIM**
- Hashes coerentes: **SIM**
- Save pessoal íntegro: **SIM**
- 15 arquivos protegidos íntegros: **SIM**
- Alterações locais externas preservadas: **SIM**
- Staging seletivo restrito ao escopo: **SIM**
- Correção FIX01 presente e testada: **SIM**
- Testes automatizados 100% aprovados (543/543): **SIM**
- Homologação humana registrada: **SIM**

**DECISÃO: GO PARA COMMIT LOCAL ÚNICO.**
