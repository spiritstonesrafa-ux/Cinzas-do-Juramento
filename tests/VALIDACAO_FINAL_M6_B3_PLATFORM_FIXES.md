# RELATÓRIO DE AUDITORIA FINAL INTEGRADA
## M6-B3 (Setores 7 e 8) + M6 PLATFORM ACCESSIBILITY FIX01 + M6 PLATFORM FIX02
### Auditoria Completa, Verificação de Regressão (396/396 PASS), Evidências em GPU Real e Blindagem de Repositório

---

## A. Resumo Executivo e Status

Esta auditoria consolida a validação técnica, funcional, visual e de segurança para os três marcos pendentes da **Fase 3 — Floresta dos Ossos**:
1. **M6-B3:** Expansão dos Setores 7 (*Fenda das Vértebras*, $1280 \times 360$) e 8 (*Bosque dos Ecos / Monólito*, $960 \times 360$), completando os 8 setores da fase.
2. **M6 PLATFORM ACCESSIBILITY FIX01:** Calibração exaustiva da acessibilidade das plataformas aéreas suspensas nos 8 setores da fase, garantindo que Aren alcance 100% das rotas de exploração sem alterar a física global.
3. **M6 PLATFORM FIX02:** Resolução do bloqueio físico no retorno do Setor 1 ($x=746$), mediante remoção do obstáculo aéreo em $y=254$ e garantia de pé-direito livre $\ge 40\text{ px}$.

> [!IMPORTANT]
> **CLASSIFICAÇÃO DO MARCO:**
> **APTO PARA SOLICITAR AUTORIZAÇÃO DE COMMIT (PENDENTE DE HOMOLOGAÇÃO VISUAL DOS SETORES 7 E 8 PELO RESPONSÁVEL)**.
> - **Commits realizados:** 0 (ZERO).
> - **Staging no Git (`git add`):** 0 (ZERO) — `git diff --cached` nulo.
> - **Push / Deploy:** 0 (ZERO).
> - **Integridade do Save Pessoal:** 100% íntegro (SHA-256 `4DB32167231D18C4B0872C73A8647FE6803C86C3E1FE5B49D68BE8012405797F`).
> - **Suítes de Regressão:** 10/10 suítes aprovadas, 396/396 verificações PASS (100%).

---

## B. Estado Inicial do Repositório e Linha de Base Canônica

- **Branch de Trabalho:** `main`
- **HEAD Consolidado de Referência:** `c819dfb67eafc61516ee68ff36500ab8888539bd`
- **Área de Preparação Git (`git diff --cached`):** Vazia (0 bytes).
- **Save Pessoal:** `C:\Users\ovohe\AppData\Roaming\Godot\app_userdata\Cinzas do Juramento\cinzas_abbey_progress_v1.json`
  - Tamanho: 215 bytes
  - SHA-256: `4DB32167231D18C4B0872C73A8647FE6803C86C3E1FE5B49D68BE8012405797F`
  - Conteúdo verificado: `abbot_defeated: true`, `guardian_defeated: true`, `dash_unlocked: true`, `health_upgrade_unlocked: true`.

### Auditoria dos 15 Arquivos Protegidos Canônicos

| Arquivo Protegido | Tamanho | SHA-256 Observado | Status |
| :--- | :---: | :--- | :---: |
| `project.godot` | 4,228 | `9AF9D5B41364F56E74B78EE451C9B90D87E60FE861E2E19A26C6B24962ED4E22` | ÍNTEGRO |
| `scenes/player/knight.tscn` | 1,811 | `F5C1D2D50E6347FEBCDBB45E8F0174F8CBEFDCE232A048FBCB35667AC168E2E5` | ÍNTEGRO |
| `scripts/player/player.gd` | 7,163 | `D87BDDDEBD2C1ED601FBEB65E479361CEAA6DFBCE96DE2A69EF292E4EBBFCBBE` | ÍNTEGRO |
| `scripts/player/player_state.gd` | 10,753 | `DAF75C09F628795A40FDF670DF79C56A8F08332152862BFA1BA62313FCE72A42` | ÍNTEGRO |
| `scripts/combat/hitbox.gd` | 1,291 | `249AC49EBE120530A200DCB474C56EB73A2BE03A89BA78D40E53B022B801D11B` | ÍNTEGRO |
| `scripts/combat/hurtbox.gd` | 1,328 | `47348EED70CE0E6E9E8D1219CE6C0FAFE98DDAAC15E9D087BE329848D2A3D224` | ÍNTEGRO |
| `scripts/core/game_state.gd` | 6,367 | `A3681729A332BEA7BC8F9EBD32B8797B79E5EFDAAEBA8D755A8A9325D3249156` | ÍNTEGRO |
| `scripts/core/save_manager.gd` | 10,774 | `BF1FD6C1032338C4EC2D1CE845E0CF80A849AF3DE77A016838D6475C66270086` | ÍNTEGRO |
| `scripts/boss/boss_controller.gd` | 7,934 | `6D7061CD6F66E7C410B5515BD0D98EB0A8FA4F6C87C0D0EF456F6423984594A5` | ÍNTEGRO |
| `scripts/boss/boss_arena.gd` | 14,929 | `A46CA02403F54F044A152125C96E2AF46EFA9BF983A7CE8C32E3A0B10B45C228` | ÍNTEGRO |
| `scenes/boss/guardian.tscn` | 1,848 | `71A9A2CE14D43F93E417C6C9C4E03FBD46EBE84DE4DB7CC40B8F1BA3A12521C5` | ÍNTEGRO |
| `scenes/boss/boss_arena.tscn` | 2,746 | `DA254EC0FE073932F23568EBECF2A80277EDC7249E67EE8B706B1FF5EE141C89` | ÍNTEGRO |
| `scenes/combat/sword_slash_vfx.tscn` | 1,173 | `9F71B7A07EBF09D3E64AE8FDB6B94A61CC6BD5C989C82B460A29BF9D13009AE5` | ÍNTEGRO |
| `scenes/ui/hud.tscn` | 1,846 | `CF2363AF7A6A802C45FDFD713EFCCEC52516A7DC21A837A6A76BF9161B563DF7` | ÍNTEGRO |
| `scenes/forest/forest_pilots.tscn` | 1,368 | `00155A77B90708AC6E33B05C725D8F0BFA3480B68E719A711FFCCB0EC5211B3A` | ÍNTEGRO |

---

## C. Auditoria Técnica e Funcional do M6-B3 (Setores 7 e 8)

### 1. Setor 7 — Fenda das Vértebras
- **Identificação:** `SECTOR_7` / Cena: `scenes/forest/sector_07.tscn`.
- **Dimensões:** $1280 \times 360\text{ px}$ (4 telas de largura lógica $320 \times 180$).
- **Topografia e Geometria:**
  - Ponto de entrada Oeste: $x=0$, altura de piso contínua com a saída do Setor 6 ($y=288$).
  - Terreno acidentado com degraus em $y=288 \to y=276 \to y=264$.
  - Abismo profundo na *Fenda das Vértebras* entre $x=520$ e $x=740$, transponível através de plataformas em balanço formadas por costelas fósseis.
  - Saída Leste: $x=1280$, cota $y=288$, alinhada milimetricamente à entrada do Setor 8.
- **Arte Panorâmica:** `assets/art/m6a/forest_sector7_bg.png` ($1280 \times 360$).
  - Tons cianos profundos e ossaturas ciclópicas que emergem da névoa azulada.

### 2. Setor 8 — Bosque dos Ecos (Câmara do Monólito)
- **Identificação:** `SECTOR_8` / Cena: `scenes/forest/sector_08.tscn`.
- **Dimensões:** $960 \times 360\text{ px}$ (3 telas de largura lógica).
- **Topografia e Geometria:**
  - Ponto de entrada Oeste: $x=0$, cota $y=288$, continuidade perfeita com o Setor 7.
  - Abóbada gótica de costelas e arcadas ósseas monumentais.
  - Centro cerimonial: *Monólito dos Ecos* e chama azulada de repouso em $x=480, y=288$.
  - Checkpoint final registrado em `ForestLayout.SECTOR_8_CHECKPOINT`.
  - Ponto de término Leste: $x=960$, barreira intransponível que sinaliza o final da fase.
- **Arte Panorâmica:** `assets/art/m6a/forest_sector8_bg.png` ($960 \times 360$).
  - Abóbada catedralícia ancestral com névoa mística e partículas fosforescentes.

### 3. Travessia Bidirecional Sem Emendas
- A transição física de saída do Setor 6 ($x=1280, y=288$) conecta diretamente à entrada do Setor 7 ($x=0, y=288$).
- A transição física de saída do Setor 7 ($x=1280, y=288$) conecta à entrada do Setor 8 ($x=0, y=288$).
- Ambas as conexões foram comprovadas em testes contínuos de ida e retorno com o corpo físico de Aren.

---

## D. Auditoria de Acessibilidade das Plataformas (M6 PLATFORM ACCESSIBILITY FIX01)

### 1. Modelo Físico Imutável de Aren
A calibração respeitou rigorosamente o congelamento da física de Aren:
- **Impulso de Salto Vertical ($v_0$):** $-260.0\text{ px/s}$.
- **Gravidade ($g$):** $870.0\text{ px/s}^2$.
- **Tempo até o Ápice ($t_{\text{apex}}$):** $t = \frac{|v_0|}{g} = \frac{260}{870} \approx 0.29885\text{ s}$.
- **Altura Máxima Teórica de Salto ($h_{\max}$):**
  $$h_{\max} = \frac{v_0^2}{2g} = \frac{260^2}{1740} = \frac{67600}{1740} \approx 38.85\text{ px}$$
- **Velocidade de Movimento Horizontal ($v_x$):** $100.0\text{ px/s}$ (alcance horizontal durante um salto livre: $\approx 59.7\text{ px}$).
- **Hitbox de Aren:** Largura $12\text{ px}$, Altura $24\text{ px}$.

### 2. Regras de Ouro de Level Design Aplicadas
Para garantir 100% de acessibilidade sem alterar os atributos do herói:
1. **Diferencial de Altura ($\Delta y$):** Todo desnível vertical entre ponto de apoio e plataforma de destino foi restringido a $24\text{ px} \le \Delta y \le 36\text{ px}$ (sempre inferior aos $38.85\text{ px}$ de limite físico).
2. **Espaçamento Horizontal ($\Delta x$):** Saltos entre plataformas mantidos entre $32\text{ px}$ e $48\text{ px}$.
3. **Pé-Direito Mínimo (Headroom):** Nenhuma plataforma ou galho pode estar a menos de $40\text{ px}$ acima de uma superfície de corrida terrestre, prevenindo colisão de teto durante a corrida ou o salto.

### 3. Tabela de Cobertura das Plataformas nos 8 Setores

| Setor | Nome Temático | Plataformas Aéreas Calibradas | Desnível Máximo ($\Delta y$) | Acessibilidade Física |
| :---: | :--- | :---: | :---: | :---: |
| **1** | Clareira dos Sussurros | 4 galhos calibrados (Branch 0 a 3) | $32\text{ px}$ | **100% PASS** |
| **2** | Bosque das Raízes | 5 galhos + Santuário do Cervo | $32\text{ px}$ | **100% PASS** |
| **3** | Desfiladeiro dos Fêmures | 3 plataformas de ossos suspensos | $34\text{ px}$ | **100% PASS** |
| **4** | Ruínas do Relicário | 4 plataformas do dossel gótico | $32\text{ px}$ | **100% PASS** |
| **5** | Garganta das Serpentes | 4 plataformas sobre o abismo | $34\text{ px}$ | **100% PASS** |
| **6** | Vale das Caixas Torácicas | 4 plataformas ósseas elevadas | $32\text{ px}$ | **100% PASS** |
| **7** | Fenda das Vértebras | 4 plataformas em balanço | $34\text{ px}$ | **100% PASS** |
| **8** | Bosque dos Ecos | 4 plataformas na abóbada cerimonial | $32\text{ px}$ | **100% PASS** |

A suíte `tests/m6_platform_accessibility_test.gd` validou individualmente o salto e pouso bem-sucedido de Aren em todas as plataformas dos 8 setores (44/44 verificações PASS).

---

## E. Auditoria da Correção Pontual do Setor 1 (M6 PLATFORM FIX02)

### 1. Diagnóstico da Falha Reportada
Durante o playtest manual, Aren conseguia avançar para a direita no Setor 1, mas não conseguia retornar da direita para a esquerda:
- **Topografia:** No trecho $x=740$, o piso sobe de $y=300$ para $y=276$ ($\Delta y = 24\text{ px}$).
- **Causa Raiz:** A plataforma aérea `Rect2(690, 254, 80, 12)` encontrava-se posicionada diretamente sobre o degrau.
- Sua base em $y=266$ deixava apenas $10\text{ px}$ de espaço livre sobre o chão de cota $y=276$ ($276 - 266 = 10\text{ px}$).
- Como Aren tem $24\text{ px}$ de altura, ao tentar saltar para subir o degrau, Aren batia o topo de sua cabeça no fundo da plataforma após subir apenas $10\text{ px}$, perdendo o momento vertical e caindo de volta, ficando permanentemente barrado em $x=746.1$.

### 2. Ação Corretiva Implementada
1. **Remoção de Obstáculo:** A plataforma `Rect2(690, 254, 80, 12)` foi completamente eliminada de `SECTOR_1_BRANCHES` em `scripts/forest/forest_layout.gd`.
2. **Espaço Aéreo Aberto:** A região do degrau em $x=740$ passou a ter céu totalmente aberto. O salto de $24\text{ px}$ requer apenas $61.7\%$ da capacidade de salto de Aren ($38.85\text{ px}$).
3. **Pé-Direito Garantido nos Galhos Remanescentes:**
   - `Branch 0`: redefinido para `Rect2(160, 252, 80, 8)` $\to$ cota inferior $y=260$, com piso a $y=300$, fornecendo $40\text{ px}$ de pé-direito livre ($40 > 24\text{ px}$).
   - `Branch 3`: `Rect2(570, 224, 90, 12)` $\to$ cota inferior $y=236$, com piso a $y=276$, fornecendo $40\text{ px}$ de pé-direito livre ($40 > 24\text{ px}$).
4. **Alinhamento Artístico:** As decorações de cogumelos em `scripts/forest/forest_art.gd` foram atualizadas para não deixarem elementos flutuando no ar.

### 3. Comprovação Funcional
- Simulação cinemática contínua de Aren iniciando na extremidade Leste ($x=887$) e correndo/saltando até a extremidade Oeste ($x=24$).
- Travessia executada sem nenhum bloqueio, colisão de teto ou desaceleração anormal.
- Todas as asserções de geometria do Setor 1 em `m6_b1_expansion_test.gd` e `m6_b2_expansion_test.gd` foram atualizadas ($s0.size() == 9$).

---

## F. Matriz Completa de Regressão Automatizada (10/10 Suítes, 396/396 PASS)

A suíte completa de testes de regressão do projeto foi executada com isolamento estrito de ambiente (usando `TEMP` para evitar qualquer interação com o save pessoal). Todas as 10 suítes obtiveram taxa de aprovação de 100%.

| # | Arquivo de Teste | Verificações | Resultado | Foco da Avaliação |
| :-: | :--- | :-: | :---: | :--- |
| **1** | `tests/m6_platform_accessibility_test.gd` | **44/44** | **PASS** | Física de salto e alcance de plataformas aéreas em todos os 8 setores |
| **2** | `tests/m6_b3_expansion_test.gd` | **59/59** | **PASS** | Setores 7 e 8: geometria, limites, conexões e checkpoints |
| **3** | `tests/m6_b2_expansion_test.gd` | **46/46** | **PASS** | Setores 5 e 6: integridade topográfica e fluxo contínuo |
| **4** | `tests/m6_b1_expansion_test.gd` | **33/33** | **PASS** | Setores 3 e 4: expansão e compatibilidade estrutural |
| **5** | `tests/m6_b1_altar_accessibility_test.gd` | **15/15** | **PASS** | Santuário do Cervo: acessibilidade do patamar superior e apoios |
| **6** | `tests/m6_a_pilot_test.gd` | **24/24** | **PASS** | Setores 1 e 2: preservação da reconstrução artística do Codex |
| **7** | `tests/combat_test.gd` | **36/36** | **PASS** | Mecânicas de ataque, hitbox de espada e dano |
| **8** | `tests/dash_vfx_test.gd` | **47/47** | **PASS** | Cinemática e efeitos de partículas do dash em terreno e ar |
| **9** | `tests/boss_test.gd` | **59/59** | **PASS** | Ciclos de combate, IA, padrões e estados dos chefes |
| **10** | `tests/recompensa_guardiao_test.gd` | **33/33** | **PASS** | Recompensa permanente do Guardião (coração de vida) e save |
| **TOTAL** | **10 Suítes Automatizadas** | **396/396** | **PASS (100%)** | **Regressão Integral Homologada** |

---

## G. Catálogo de Evidências Gráficas em GPU Real

- **Placa de Vídeo Utilizada:** NVIDIA GeForce RTX 2060 SUPER (Driver 595.71)
- **Renderizador Godot:** Forward+ (D3D12/Vulkan), Janela $960 \times 540$ (Upscale 3x Pixel-Perfect de $320 \times 180$)
- **Localização no Repositório:** `tests/evidencias/`

### 1. Painéis Sintéticos Consolidados

| Painel | Dimensões | Tamanho | Conteúdo / Composição |
| :--- | :---: | :---: | :--- |
| `tests/evidencias/m6_auditoria_final/painel_auditoria_final_m6.png` | $1920 \times 1620$ | 5,378 KB | Composição de 6 painéis: Retorno S1 desobstruído, Fenda das Vértebras S7, Plataformas Aéreas S7, Bosque dos Ecos S8, Monólito S8 e Retorno Bidirecional S8 $\to$ S7. |
| `tests/evidencias/m6_platform_fix02/painel_m6_platform_fix02.png` | $1920 \times 1080$ | 3,688 KB | Sequência do retorno no Setor 1: subida do degrau $x=740$, ápice do salto sem bater no teto e vista panorâmica limpa. |
| `tests/evidencias/m6b3/comparacao_setores_6_7_8.png` | $1920 \times 1620$ | 4,537 KB | Alinhamento panorâmico demonstrando a transição contínua S6 $\to$ S7 $\to$ S8. |

### 2. Capturas Individuais em Alta Resolução

#### Auditoria Final e Desobstrução S1 (`tests/evidencias/m6_auditoria_final/`)
- `setor1_01_retorno_degrau_livre.png`: Aren posicionado diante do degrau $x=740$, espaço aéreo livre.
- `setor1_02_retorno_salto_desobstruido.png`: Aren no ápice do salto ultrapassando o desnível de $24\text{ px}$.
- `setor7_01_entrada.png`: Transição contínua vindo do Setor 6.
- `setor7_02_fenda_vertebras.png`: Vista ampla das costelas ciclópicas sobre o abismo.
- `setor7_03_plataformas_aereas.png`: Aren saltando entre plataformas de vértebras fósseis.
- `setor7_04_terraco_saida.png`: Terraço superior na transição para o Setor 8.
- `setor8_01_entrada.png`: Entrada solene na abóbada catedralícia.
- `setor8_02_abobada_e_chama.png`: Centro cerimonial com chama azulada e iluminação ambiente.
- `setor8_03_plataformas_ecos.png`: Aren explorando o dossel ósseo superior.
- `setor8_04_monolito_dos_ecos.png`: Aren ao lado do Monólito e checkpoint final.
- `setor8_05_retorno_setor7.png`: Comprovação do retorno fluido em direção ao Setor 7.

#### Acessibilidade de Plataformas FIX01 (`tests/evidencias/m6_platform_accessibility/`)
- `setor1_01_branch0_acessivel.png` a `setor8_abobada_ecos.png`: 10 capturas demonstrando Aren apoiado com sucesso sobre as plataformas suspensas em cada um dos 8 setores.

---

## H. Auditoria de Segurança, Baseline e Conclusão

### 1. Auditoria do Arquivo Pessoal de Save
- **Caminho:** `C:\Users\ovohe\AppData\Roaming\Godot\app_userdata\Cinzas do Juramento\cinzas_abbey_progress_v1.json`
- **Hash Pré-Auditoria:** `4DB32167231D18C4B0872C73A8647FE6803C86C3E1FE5B49D68BE8012405797F`
- **Hash Pós-Auditoria:** `4DB32167231D18C4B0872C73A8647FE6803C86C3E1FE5B49D68BE8012405797F`
- **Diagnóstico:** Inalterado e 100% preservado. Nenhuma operação tocou na pasta do usuário.

### 2. Parecer de Conclusão e Próximos Passos
Todas as verificações matemáticas, de física cinemática, de compilação Godot, de renderização em GPU e de regressão do projeto foram concluídas com êxito integral (100% PASS).

**Próxima Etapa Requerida:**
O responsável pelo projeto deve realizar o playtest manual executando:
```powershell
& "C:\Users\ovohe\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe" "scenes/forest/forest_pilots.tscn"
```
Durante o playtest:
1. Pressionar `[1]` e testar a ida e volta no Setor 1, confirmando a subida livre do degrau no retorno.
2. Pressionar `[7]` e `[8]` para navegar pelos Setores 7 e 8, avaliando a estética de pixel art, as plataformas e a atmosfera.
3. Emitir a homologação visual e autorização formal para que o commit único de consolidação seja efetuado conforme catalogado no manifesto.
