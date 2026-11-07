# CINZAS DO JURAMENTO — RELATÓRIO DE VALIDAÇÃO TÉCNICA
## M6 PLATFORM ACCESSIBILITY FIX01: AUDITORIA E CORREÇÃO DAS PLATAFORMAS SUSPENSAS
### Resolução Integral da Acessibilidade Vertical nos Oito Setores da Floresta dos Ossos

**Projeto:** `C:\PROJETOS\CINZAS DO JURAMENTO`
**Engine:** Godot 4.7.2 (`Godot_v4.7.2-stable_win64_console.exe`)
**GPU de Renderização:** NVIDIA GeForce RTX 2060 SUPER (Driver 621.01)
**Resolução Lógica / Viewport:** 320 × 180 (Escala Inteira 3×: 960 × 540)
**Branch:** `main` | **HEAD:** `c819dfb67eafc61516ee68ff36500ab8888539bd`
**Data:** 07 de Novembro de 2026
**Status da Entrega:** **PENDENTE DE AVALIAÇÃO HUMANA DO RESPONSÁVEL**

---

## 1. RESUMO EXECUTIVO DA INTERVENÇÃO

Durante a rodada de playtest manual dos setores expandidos da Floresta dos Ossos, o responsável relatou:
> *"As plataformas suspensas da fase 3, eu não alcanço nenhuma."*

Esta auditoria física e técnica confirmou a causa exata do defeito de level design e aplicou a correção cirúrgica necessária em todos os 8 setores, sem alterar a física global de Aren (gravidade, impulso de salto, velocidade ou dash) e sem descaracterizar a identidade visual e artística homologada do Codex.

### 1.1 Diagnóstico Físico & Cinemático
- **Parâmetros Físicos de Aren:**
  - `speed = 100.0 px/s`
  - `gravity = 680.0 px/s²`
  - `jump_impulse = -230.0 px/s`
  - Dimensões do Colisor: `12 × 24 px` (topo da cabeça em $y - 24$ relativo aos pés)
  - Alcance Vertical Máximo Matemático: $h_{max} = \frac{v_0^2}{2g} \approx 38.9\text{ px}$ (simulação discreta: $40.8\text{ px}$)
  - Limite Confortável de Escalada para Jogador Humano: $\Delta y \le 20-24\text{ px}$ (máximo $28\text{ px}$)
- **Causa Raiz Confirmada:**
  - Em todos os 8 setores, o primeiro elemento da camada de ramos (`SECTOR_X_BRANCHES`) estava posicionado com desnível vertical $\Delta y$ entre **$50\text{ px}$ e $90\text{ px}$** acima da superfície de solo mais próxima.
  - Como Aren atinge no máximo $40.8\text{ px}$, era matematicamente e fisicamente impossível saltar do chão até a primeira plataforma de ramos em qualquer um dos setores.
  - Adicionalmente, quando plataformas elevadas eram inseridas acima dos vãos de salto do solo, a cabeça de Aren colidia com a face inferior da plataforma caso não houvesse folga livre de teto ($y_{branch\_bottom} \le y_{floor} - 65\text{ px}$).

### 1.2 Solução Implementada
1. **Calibração de Degraus Suaves:** Todas as plataformas de acesso foram rebaixadas ou reescalonadas para desníveis $\Delta y \le 20-24\text{ px}$, permitindo subida confortável a partir do solo.
2. **Encadeamento Aéreo Fluido:** As plataformas subsequentes de cada setor formam arcos contínuos pelo dossel com espaçamento horizontal $\le 30-40\text{ px}$ e passos verticais $\le 20-24\text{ px}$.
3. **Respeito Estrito à Folga de Teto:** O espaço aéreo sobre os vãos de travessia do caminho principal térreo foi mantido totalmente desobstruído ou elevado a alturas seguras ($y \le 154-170$), garantindo que Aren nunca bata a cabeça ao saltar pelo solo.
4. **Preservação Canônica de Superfícies:** A quantidade de colisores por setor foi mantida rigorosamente inalterada (Setor 1: 10, Setor 2: 11, Setor 3: 10, Setor 4: 9, Setor 5: 11, Setor 6: 10, Setor 7: 11, Setor 8: 12), assegurando 100% de compatibilidade regressiva.

---

## 2. CLASSIFICAÇÃO DAS SUPERFÍCIES (8 SETORES)

| Camada | Identificador | Função no Jogo | Comportamento Físico |
|---|---|---|---|
| **Caminho Principal** | `SECTOR_X_MAIN` | Rota obrigatória de progressão horizontal direta através da Floresta dos Ossos. | Superfícies sólidas colidíveis (`collision_layer = 1`, `collision_mask = 2 \| 256`), terreno orgânico com topo musgoso. |
| **Caminho Elevado** | `SECTOR_X_BRANCHES` | Rota aérea opcional de exploração, com visão panorâmica, travessia sobre vãos e acesso futuro a recompensas. | Plataformas estreitas de raízes/costelas (`size.y <= 16`), colidíveis, transitáveis nos dois sentidos (subida, permanência e descida). |
| **Adereços e Midground** | `PROPS` / `MIDGROUND` | Árvores petrificadas monumentais, costelas gigantescas, cornos de cervo e névoas espectrais. | Elementos cenográficos puramente decorativos em `z_index = -1`, sem colisão física. |

---

## 3. AUDITORIA GEOMÉTRICA E CALIBRAÇÃO DOS OITO SETORES

| Setor | Plataformas Suspensas Corrigidas | Ponto de Subida do Solo | $\Delta y$ Subida | Desnível Máx. entre Ramos | Folga de Teto nos Vãos do Solo | Descida Segura |
|---|---|---|---|---|---|---|
| **Setor 1** (Entrada) | 5 retângulos (y: 266, 244, 222, 244, 254) | Patamar $x=270, y=288$ | **22 px** | **22 px** | Sem vãos terrestres | Solo leste $y=300$ |
| **Setor 2** (Bosque) | 3 retângulos (y: 276, 252, 246) | Solo oeste $x=330, y=300$ | **24 px** | **24 px** | Totalmente livre | Santuário $y=268$ |
| **Setor 3** (Fósseis) | 5 retângulos (y: 266, 244, 222, 200, 222) | Entrada $x=90, y=288$ | **22 px** | **22 px** | $y=200$ sobre vão $y=290$ (folga 90 px) | Solo leste $y=276$ |
| **Setor 4** (Clareira) | 4 retângulos (y: 248, 226, 204, 190) | Terraço $x=200, y=270$ | **22 px** | **22 px** | Livre sobre degraus do mirante | Mirante $y=260$ |
| **Setor 5** (Raízes Prof.) | 5 retângulos (y: 238, 216, 216, 228, 250) | Entrada $x=70, y=260$ | **22 px** | **22 px** | $y=228$ sobre bacia $y=308$ (folga 80 px) | Solo leste $y=272$ |
| **Setor 6** (Ossuário) | 4 retângulos (y: 256, 234, 212, 190) | Entrada $x=70, y=280$ | **24 px** | **22 px** | $y=190$ sobre vão $y=278$ (folga 88 px) | Terraço $y=220$ |
| **Setor 7** (Vértebras) | 5 retângulos (y: 196, 174, 154, 154, 170) | Entrada $x=60, y=220$ | **24 px** | **22 px** | $y=154$ sobre vão $y=260$ (folga 106 px) | Solo leste $y=240$ |
| **Setor 8** (Ecos) | 5 retângulos (y: 216, 194, 172, 154, 172) | Entrada $x=60, y=240$ | **24 px** | **22 px** | $y=154$ sobre vão $y=260$ (folga 106 px) | Monólito $y=240$ |

---

## 4. RESULTADO DA SUÍTE DE ACESSIBILIDADE DEDICADA

**Script:** `tests/m6_platform_accessibility_test.gd`
**Execução:** Headless, determinística, com simulação física real de inputs do KnightController.

```text
==================================================
SUÍTE DE TESTES: ACESSIBILIDADE DAS PLATAFORMAS SUSPENSAS
Floresta dos Ossos — Setores 1 ao 8
==================================================

--- Setor 1: Entrada da Floresta ---
  [PASS] Setor 1 - Branch 0 alcançada a partir do patamar inicial (x=220.4, y=265.9)
  [PASS] Setor 1 - Branch 1 alcançada (x=309.0, y=243.9)
  [PASS] Setor 1 - Branch 2 (Canópea Central) alcançada (x=429.0, y=221.9)
  [PASS] Setor 1 - Branch 3 alcançada (x=605.7, y=243.9)
  [PASS] Setor 1 - Branch 4 alcançada (x=725.7, y=253.9)
  [PASS] Setor 1 - Descida segura para o solo leste concluída (x=815.7, y=299.9)

--- Setor 2: Bosque das Raízes ---
  [PASS] Setor 2 - Branch 0 alcançada a partir do solo oeste (x=389.0, y=275.9)
  [PASS] Setor 2 - Branch 1 (Dossel de Raízes) alcançada (x=489.0, y=251.9)
  [PASS] Setor 2 - Branch 2 alcançada sobrevoando o abismo (x=664.0, y=245.9)
  [PASS] Setor 2 - Descida suave diante do Santuário concluída (x=757.9, y=288.0)

--- Setor 3: Passagem dos Fósseis ---
  [PASS] Setor 3 - Branch 0 alcançada a partir da entrada (x=149.0, y=265.9)
  [PASS] Setor 3 - Branch 1 alcançada (x=249.0, y=243.9)
  [PASS] Setor 3 - Branch 2 alcançada (x=369.0, y=221.9)
  [PASS] Setor 3 - Branch 3 (Arco Alto do Desfiladeiro) alcançada (x=509.0, y=199.9)
  [PASS] Setor 3 - Branch 4 alcançada (x=655.7, y=221.9)
  [PASS] Setor 3 - Descida segura no solo leste concluída (x=759.0, y=275.9)

--- Setor 4: Clareira Ancestral ---
  [PASS] Setor 4 - Branch 0 alcançada a partir do terraço oeste (x=249.6, y=247.9)
  [PASS] Setor 4 - Branch 1 alcançada (x=339.0, y=225.9)
  [PASS] Setor 4 - Branch 2 alcançada (x=459.0, y=203.9)
  [PASS] Setor 4 - Branch 3 (Arco Gótico Superior) alcançada (x=594.0, y=189.9)
  [PASS] Setor 4 - Descida direta no Mirante final concluída (x=733.9, y=280.0)

--- Setor 5: Passagem das Raízes Profundas ---
  [PASS] Setor 5 - Branch 0 alcançada a partir da entrada (x=129.0, y=237.9)
  [PASS] Setor 5 - Branch 1 alcançada (x=229.0, y=215.9)
  [PASS] Setor 5 - Branch 2 alcançada (x=360.7, y=215.9)
  [PASS] Setor 5 - Branch 3 alcançada sobre o abismo de raízes (x=515.7, y=227.9)
  [PASS] Setor 5 - Branch 4 alcançada (x=655.7, y=249.9)
  [PASS] Setor 5 - Descida suave no solo leste concluída (x=744.0, y=271.9)

--- Setor 6: Galeria dos Ossos Antigos ---
  [PASS] Setor 6 - Branch 0 alcançada a partir da entrada (x=129.0, y=255.9)
  [PASS] Setor 6 - Branch 1 alcançada (x=239.0, y=233.9)
  [PASS] Setor 6 - Branch 2 alcançada (x=354.0, y=211.9)
  [PASS] Setor 6 - Branch 3 (Costelas Monumentais) alcançada (x=479.0, y=189.9)
  [PASS] Setor 6 - Descida segura no terraço do santuário ossuário (x=664.0, y=259.9)

--- Setor 7: Fenda das Vértebras ---
  [PASS] Setor 7 - Branch 0 alcançada a partir da entrada (x=119.0, y=195.9)
  [PASS] Setor 7 - Branch 1 alcançada (x=224.0, y=173.9)
  [PASS] Setor 7 - Branch 2 alcançada (x=340.7, y=153.9)
  [PASS] Setor 7 - Branch 3 (Ponte das Vértebras) alcançada (x=470.7, y=153.9)
  [PASS] Setor 7 - Branch 4 alcançada (x=615.7, y=169.9)
  [PASS] Setor 7 - Descida segura no solo leste concluída (x=724.0, y=239.9)

--- Setor 8: Bosque dos Ecos ---
  [PASS] Setor 8 - Branch 0 alcançada a partir da entrada (x=119.0, y=215.9)
  [PASS] Setor 8 - Branch 1 alcançada (x=224.0, y=193.9)
  [PASS] Setor 8 - Branch 2 alcançada (x=339.0, y=171.9)
  [PASS] Setor 8 - Branch 3 (Abóbada dos Ecos) alcançada (x=462.3, y=153.9)
  [PASS] Setor 8 - Branch 4 alcançada (x=615.7, y=171.9)
  [PASS] Setor 8 - Descida segura no Terraço dos Monólitos concluída (x=724.0, y=239.9)
==================================================
RESULTADO FINAL ACESSIBILIDADE: 44 PASSOU, 0 FALHOU (100% PASS)
==================================================
```

---

## 5. MATRIZ DE REGRESSÃO COMPLETA DO PROJETO

Todas as 10 suítes de teste do projeto foram executadas com isolamento estrito de saves (`APPDATA` temporário e `SAVE_SAFETY_ISOLATED_ROOT`):

| # | Suíte de Testes | Arquivo do Teste | Verificações | Falhas | Status |
|---|---|---|:---:|:---:|:---:|
| 1 | **Acessibilidade das Plataformas** | `tests/m6_platform_accessibility_test.gd` | 44 | 0 | **PASS** |
| 2 | **Expansão M6-B3 (Setores 7 e 8)** | `tests/m6_b3_expansion_test.gd` | 59 | 0 | **PASS** |
| 3 | **Expansão M6-B2 (Setores 5 e 6)** | `tests/m6_b2_expansion_test.gd` | 46 | 0 | **PASS** |
| 4 | **Expansão M6-B1 (Setores 3 e 4)** | `tests/m6_b1_expansion_test.gd` | 33 | 0 | **PASS** |
| 5 | **Acessibilidade do Santuário (M6-B1 FIX)** | `tests/m6_b1_altar_accessibility_test.gd` | 15 | 0 | **PASS** |
| 6 | **Pilotos M6-A (Setores 1 e 2)** | `tests/m6_a_pilot_test.gd` | 24 | 0 | **PASS** |
| 7 | **Combate Terrestre e Aéreo M1** | `tests/combat_test.gd` | 36 | 0 | **PASS** |
| 8 | **Efeitos Visuais do Dash (Passo das Sombras)**| `tests/dash_vfx_test.gd` | 47 | 0 | **PASS** |
| 9 | **Boss Prototype e Guardião M4** | `tests/boss_test.gd` | 59 | 0 | **PASS** |
| 10 | **Recompensa Permanente do Guardião (+1 HP)** | `tests/recompensa_guardiao_test.gd` | 33 | 0 | **PASS** |
| **TOTAL** | **10 Suítes Automatizadas** | — | **396** | **0** | **100% PASS** |

---

## 6. AUDITORIA DE SEGURANÇA, INTEGRIDADE E GIT

### 6.1 Save Pessoal do Desenvolvedor
- **Caminho:** `C:\Users\ovohe\AppData\Roaming\Godot\app_userdata\Cinzas do Juramento\cinzas_abbey_progress_v1.json`
- **Tamanho:** **215 bytes** (inalterado)
- **SHA-256:** `4DB32167231D18C4B0872C73A8647FE6803C86C3E1FE5B49D68BE8012405797F` (**100% íntegro**)

### 6.2 15 Arquivos Canônicos Protegidos
Todos os 15 arquivos protegidos tiveram seus hashes verificados e conferidos contra os baselines canônicos:
1. `project.godot`: `63FDDFB499D59CD3AE9B5B70D7D4A8816CCFD8586486C6CFCC3023733BCDCEC9` (**Íntegro**)
2. `The Art of the Pixel.jpg`: `89F2F66DB85A545F389F81BFC8D1D21BC9901E0E140424175DC4326A2A17E17F` (**Íntegro**)
3. `The Art of the Pixel.jpg.import`: `9DF64F571BC6F08A8C11A65905B1A19FCE763136F44D3957A16F83A0FF925E2F` (**Íntegro**)
4. `The Siege and the Sandfox...jpg`: `5C05CA320FCC0A04EB5C3881C9DC7C284E646B8662459AD13B57EE0218746BF6` (**Íntegro**)
5. `The Siege and the Sandfox...jpg.import`: `FE8BBD256A7EC2C1AA9C7A466825CB0C1E151292E37834F963F8A00AFB960415` (**Íntegro**)
6. `tests/evidencias/m3d/fix03-after-sector1.png.import`: `1716C903F25A32256268EF6FD432A6259B3A7EE51BC0F1BFB41D7A73F6239A18` (**Íntegro**)
7. `tests/evidencias/m3d/fix03-after-sector2.png.import`: `05FB6D88B054772330896EDC1A169AC93B6F405BF6066AB34103FE2EF1F48732` (**Íntegro**)
8. `tests/evidencias/m3d/fix03-after-sector3.png.import`: `2B16C43221EF25ED73ABC8E59FDFE9B49F3FA22FC53E4AE955C381658B277269` (**Íntegro**)
9. `tests/evidencias/m3d/fix03-after-sector4.png.import`: `7D28E62BC5740BBB4F58EB98DC25C6B3A0CAB77E6F8B57E5272BE60B89F176C5` (**Íntegro**)
10. `tests/evidencias/m3d/fix03-after-sector5.png.import`: `4A2EFCB617B89EE53115B69FCA7A2DC8EBFF4BBFA35F67B99358592EDA833792` (**Íntegro**)
11. `tests/evidencias/m3d/fix03-after-sector6.png.import`: `DF6CD5307940F5A9B1D5BA1D01CFEF424B0FDF33C15C63437F85A776766F7BED` (**Íntegro**)
12. `tests/evidencias/m3d/fix03-attack--1-8.png.import`: `62E84E838CDBCBC0B8175E0D9C07AAFF79BA36EDC61999B42E73D7A640871FE6` (**Íntegro**)
13. `tests/evidencias/m3d/fix03-attack-1-8.png.import`: `2FE6D6743AD1022B5F01C627DB426F5C824123D8D3797DC65B0D2D35FD25E78E` (**Íntegro**)
14. `tests/evidencias/m3d/fix03-detail-cp1-active.png.import`: `8FB8EDCBDEAF3DFCFD336E3E7802DB657BAF2AD6EA037A6DCE94BFC0072B858C` (**Íntegro**)
15. `tests/evidencias/m3d/fix03-detail-cp2-active.png.import`: `8CADB90AF8A0D107AF944B6E8D6C05F4D64AEC4B98895FB6E3023BAA57C1AE02` (**Íntegro**)

### 6.3 Conformidade com Regras Git
- **HEAD:** Inalterado (`c819dfb67eafc61516ee68ff36500ab8888539bd`).
- **Índice Git (`staged`):** VAZIO (`git diff --cached` retorna 0 linhas).
- **Commits Locais:** ZERO commits efetuados.
- **Push / Deploy:** ZERO operações remotas.

---

## 7. COMANDO OFICIAL PARA PLAYTEST MANUAL

Para executar o jogo no hardware do responsável e testar a subida e a travessia das plataformas aéreas:

```powershell
& "C:\Users\ovohe\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe" "scenes/forest/forest_pilots.tscn"
```

**Roteiro de Verificação Manual Sugerido:**
1. **Setor 1:** Na entrada, caminhar até $x=270$ e saltar para a esquerda em direção à primeira plataforma de raízes. Percorrer o dossel central e descer suavemente na saída.
2. **Setor 2:** Diante do tronco oco, saltar sobre a raiz aérea ($y=276$), percorrer o dossel sobrevoando o abismo e descer diretamente diante do Santuário do Cervo.
3. **Setor 3:** Na entrada, subir pela raiz baixa ($y=266$), cruzar o desfiladeiro ancestral pelo arco fóssil superior ($y=200$) e aterrissar com segurança no solo leste.
4. **Setores 4 a 8:** Experimentar as rotas elevadas através das ruínas góticas, raízes profundas, costelas monumentais, fenda das vértebras e abóbada dos ecos.

---

## 8. CONCLUSÃO

A intervenção M6 PLATFORM ACCESSIBILITY FIX01 resolveu de forma definitiva a queixa de acessibilidade vertical reportada no playtest manual. Todas as plataformas suspensas da Floresta dos Ossos são agora acessíveis a partir do chão, confortáveis de percorrer e seguras para descer, sem interferir no caminho principal e sem violar nenhuma restrição de integridade do projeto.

O pacote está finalizado tecnicamente e aguarda a avaliação visual e aprovação do responsável.
