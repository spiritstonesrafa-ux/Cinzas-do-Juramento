# CINZAS DO JURAMENTO — RELATÓRIO TÉCNICO DE VALIDAÇÃO
## MARCO M6-B3: FLORESTA DOS OSSOS (SETORES 7 E 8)
### Expansão artística e funcional mantendo a integridade dos seis setores homologados

**Projeto:** `C:\PROJETOS\CINZAS DO JURAMENTO`
**Engine:** Godot 4.7.2 (Direct3D12 / Vulkan / Direct3D12 GPU rendering)
**Hardware de Execução:** NVIDIA GeForce RTX 2060 SUPER
**Resolução Lógica:** 320 × 180 (Pixel-Perfect)
**Branch:** `main`
**HEAD Consolidado Inicial:** `c819dfb67eafc61516ee68ff36500ab8888539bd`
**Data:** 07/11/2026

---

## 1. RESUMO EXECUTIVO DA ENTREGA

O marco **M6-B3** expandiu a terceira fase (*Floresta dos Ossos*) com a inclusão de dois novos setores jogáveis completos:
- **Setor 7:** *Fenda das Vértebras* (coordenadas x: 7200 a 8160 px; quarto setor do plano expandido).
- **Setor 8:** *Bosque dos Ecos* (coordenadas x: 8400 a 9360 px; quinto setor e clímax silencioso desta etapa).

A implementação respeitou integralmente as regras do projeto:
- **Preservação total dos setores 1 a 6:** A geometria, colisões, arte do Codex e marcos anteriores permanecem intocados em sua jogabilidade e comportamento.
- **Continuidade artística:** Os novos setores incorporam os mesmos elementos estabelecidos pelo Codex (árvores fossilizadas de marfim, raízes retorcidas, musgo profundo, fungos bioluminescentes, arcos de costelas antigas e névoa espectral).
- **Acessibilidade estrita:** Todas as subidas e degraus foram construídos com altura $\le 20\text{ px}$, eliminando riscos de bloqueio físico. Os vãos de travessia (48 px no Setor 7 e 46 px no Setor 8) foram projetados nivelados horizontalmente ($y=260 \to y=260$), permitindo travessia confortável com salto padrão regular ou dash terrestre.
- **Travessia bidirecional comprovada:** A jornada contínua $1 \to 8$ (ida) e $8 \to 1$ (retorno) foi validada por testes físicos com entradas reais de controle do personagem.
- **Isolamento de Saves e Segurança Git:** ZERO commits, ZERO push, saves pessoais 100% íntegros e 15 arquivos protegidos intactos.

---

## 2. DOCUMENTAÇÃO E BASELINE CONSULTADOS

- `tests/GUIA_ARTISTICO_FLORESTA_M6_A.md`
- `tests/VALIDACAO_M6_A_CODEX_ART_RECOVERY.md`
- `tests/VALIDACAO_M6_B1.md` e `tests/VALIDACAO_M6_B1_FIX01.md`
- `tests/VALIDACAO_M6_B2.md` e `tests/VALIDACAO_COMMIT_M6_B2.md`
- `tests/MANIFESTO_COMMIT_M6_B2.md`
- `GDD.md` e `ROADMAP.md`

---

## 3. ARQUIVOS MODIFICADOS E CRIADOS

### 3.1 Arquivos Criados
1. `scenes/forest/sector_07.tscn`: Cena modular do Setor 7 (instancia `ForestSector` e `ForestArt` com `sector_id = 6`).
2. `scenes/forest/sector_08.tscn`: Cena modular do Setor 8 (instancia `ForestSector` e `ForestArt` com `sector_id = 7`).
3. `assets/art/m6a/forest_sector7_bg.png` + `.import`: Panorama distante do Setor 7 (1774 × 887 px, RGB 24-bit).
4. `assets/art/m6a/forest_sector8_bg.png` + `.import`: Panorama distante do Setor 8 (1774 × 887 px, RGB 24-bit).
5. `tests/m6_b3_expansion_test.gd`: Suíte oficial de validação automatizada dos 8 setores (59 verificações aprovadas).
6. `tests/m6_b3_visual_capture.gd`: Script de captura fotográfica real na GPU.
7. `tests/evidencias/m6b3/*`: 15 capturas em resolução nativa 1280x720 e painel comparativo 1280x2160.

### 3.2 Arquivos Modificados (Infraestrutura Mínima)
1. `scripts/forest/forest_layout.gd`: Adição das origens 7200 e 8400, nomes canônicos, geometrias `SECTOR_7_MAIN/BRANCHES`, `SECTOR_8_MAIN/BRANCHES`, `surfaces(6, 7)` e pontos de `entry(6, 7)`.
2. `scripts/forest/forest_sector.gd`: Ajuste de `@export_range(0, 5, 1)` para `@export_range(0, 7, 1)`.
3. `scripts/forest/forest_demo.gd`: Inclusão dos caminhos `sector_07.tscn` e `sector_08.tscn` em `ROOM_PATHS`, e subhints narrativos para os setores 6, 7 e 8.
4. `scripts/forest/forest_art.gd`: Suporte a `@export_range(0, 7, 1)`, preloads dos novos fundos, tints específicos, estruturas de midground e cenografia da fenda das vértebras e monólito dos ecos.
5. `assets/art/m6a/PROVENANCE.md`: Especificação técnica e proveniência dos fundos 7 e 8.
6. `ROADMAP.md`: Atualização documental do marco M6-B3.
7. `tests/m6_b2_expansion_test.gd`: Adaptação de asserções estritas (`== 6` $\to$ `>= 6`) para suportar a nova contagem sem quebrar a suíte anterior.

---

## 4. LEVEL DESIGN, TOPOGRAFIA E GEOMETRIA

### 4.1 Setor 7 — Fenda das Vértebras (Origem: x=7200, y=0)
- **Tema:** Grande formação óssea atravessando uma fenda natural da floresta sobre névoa espectral ascendente.
- **Transição Oeste (Entrada):**
  - Alinhada com a saída do Setor 6 em $y=220$.
  - Patamar de entrada seguro: `Rect2(0, 220, 180, 200)`.
- **Topografia Principal:**
  - `Rect2(180, 240, 140, 180)`: Degrau de descida suave de 20 px ($y=240$).
  - `Rect2(320, 260, 160, 160)`: Patamar calcificado diante da fenda ($y=260$, degrau de 20 px).
  - **Vão da Fenda (Gap):** x = 480 a 528 (largura de 48 px). Piso nivelado em $y=260$ nos dois lados ($y=260 \to y=260$), garantindo simetria perfeita na ida e no retorno.
  - `Rect2(528, 260, 150, 160)`: Patamar de recepção calcificado ($y=260$).
  - `Rect2(678, 240, 120, 180)`: Subida suave em degrau fóssil de 20 px ($y=240$).
  - `Rect2(798, 240, 162, 180)`: Terraço leste de saída alinhado em $y=240$ até $x=960$.
- **Caminho Elevado (Ramos e Vértebras):**
  - Plataformas suspensas: `Rect2(120, 160, 90, 12)`, `Rect2(250, 195, 110, 14)`, `Rect2(420, 160, 120, 14)`, `Rect2(600, 180, 100, 12)`, `Rect2(760, 170, 90, 12)`.

### 4.2 Setor 8 — Bosque dos Ecos (Origem: x=8400, y=0)
- **Tema:** Santuário ancestral e silencioso da floresta, abóbada natural formada por árvores fossilizadas e raízes entrelaçadas, feixes celestes e monólitos de pedra antiga.
- **Transição Oeste (Entrada):**
  - Alinhada com a saída do Setor 7 em $y=240$ (desnível zero).
  - Patamar de entrada seguro: `Rect2(0, 240, 180, 180)`.
- **Topografia Principal:**
  - `Rect2(180, 260, 170, 160)`: Descida suave em direção à clareira ($y=260$, degrau de 20 px).
  - `Rect2(350, 280, 130, 140)`: Bacia central musgosa sob o dossel fechado ($y=280$, degrau de 20 px).
  - `Rect2(480, 260, 40, 160)`: Patamar de impulsão elevado ($y=260$, subida de 20 px).
  - **Vão dos Ecos (Gap):** x = 520 a 566 (largura de 46 px). Vão nivelado horizontalmente em $y=260 \to y=260$.
  - `Rect2(566, 260, 150, 160)`: Patamar de recepção leste ($y=260$).
  - `Rect2(716, 240, 110, 180)`: Subida suave em degrau fóssil de 20 px ($y=240$).
  - `Rect2(826, 240, 134, 180)`: Terraço culminante do Monólito dos Ecos ($y=240$), sólido até a margem extrema $x=960$, preparado estruturalmente para conexões futuras.
- **Caminho Elevado (Abóbada Natural):**
  - Plataformas de cipós e madeira petrificada: `Rect2(130, 180, 90, 12)`, `Rect2(270, 145, 120, 14)`, `Rect2(440, 185, 100, 12)`, `Rect2(630, 150, 130, 14)`, `Rect2(800, 180, 90, 12)`.

---

## 5. RESULTADOS DAS SUÍTES DE TESTES (AMBIENTE ISOLADO)

Todas as suítes foram executadas com perfil e diretório `user://` isolados (`APPDATA` temporário e `SAVE_SAFETY_ISOLATED_ROOT`), garantindo integridade absoluta do save pessoal.

| Suíte de Testes | Verificações / Foco | Retorno | Status |
|---|---|---|---|
| `tests/m6_b3_expansion_test.gd` | 59 verificações (Layout 8 setores, desníveis $\le 20\text{ px}$, vãos 48/46 px, instanciação modular, travessia bidirecional $1 \leftrightarrow 8$ com física real, recuperação de quedas e limites de câmera) | 0 | **PASS (59/59)** |
| `tests/m6_b2_expansion_test.gd` | 46 verificações (Integridade dos setores 1 a 6, Grande Ossuário e terraços) | 0 | **PASS (46/46)** |
| `tests/m6_b1_expansion_test.gd` | 33 verificações (Regressão M6-B1) | 0 | **PASS (33/33)** |
| `tests/m6_b1_altar_accessibility_test.gd` | 15 verificações (Acessibilidade do Santuário do Cervo) | 0 | **PASS (15/15)** |
| `tests/m6_a_pilot_test.gd` | 24 verificações (Piloto inicial da Floresta dos Ossos) | 0 | **PASS (24/24)** |
| `tests/m6_a_codex_recovery_physics.gd` | Recuperação física do piloto Codex | 0 | **PASS** |
| `tests/dash_vfx_test.gd` | Efeitos visuais do Passo das Sombras (Dash) | 0 | **PASS** |
| `tests/combat_test.gd` | Sistema de combate e ataques de Aren | 0 | **PASS** |
| `tests/boss_test.gd` | Combate do Abade das Correntes | 0 | **PASS** |
| `tests/recompensa_guardiao_test.gd` | 33 verificações (Recompensas permanentes do Guardião e Abade) | 0 | **PASS (33/33)** |

**Total de Verificações Aprovadas na Floresta:** **177/177 verificações 100% PASS**.

---

## 6. TRAVESSIA BIDIRECIONAL CONTÍNUA (FÍSICA REAL)

A travessia foi testada por injeção de entradas de controle contínuas (`Input.action_press` / `action_release` de `move_right`, `move_left`, `jump`) interagindo com `KnightController`:

1. **Sentido Ida (Oeste -> Leste: 1 ao 8):**
   - Transições niveladas e contínuas entre todos os setores (Setor 1 até Setor 8).
   - Vão do Setor 7 (48 px) superado com salto livre sem exigência de dash aéreo.
   - Vão do Setor 8 (46 px) superado com salto regular sem exigência de dash aéreo.
   - Aren alcança o Monólito dos Ecos no Setor 8 sem qualquer softlock.
2. **Sentido Retorno (Leste -> Oeste: 8 ao 1):**
   - Retorno a partir do Setor 8 (x=940) até a entrada do Setor 1 (x=48).
   - Transposição reversa dos vãos em $y=260 \to y=260$ sem perda de momentum ou colisão em quinas.
   - Subida de todos os degraus de volta ($\le 20\text{ px}$) completada normalmente.
3. **Checkpoints:**
   - O controlador `ForestDemo` inicializou com 8 pontos de checkpoint (`ForestCheckpoint0` a `ForestCheckpoint7`), registrando o respawn ao cruzar cada setor.
4. **Recuperação de Queda:**
   - Em todos os 8 setores, quedas em abismos ($y > 430\text{ px}$) acionam `_alive_fall`, reposicionando Aren no ponto seguro de entrada do setor correspondente.

---

## 7. EVIDÊNCIAS GRÁFICAS GERADAS NA GPU (RTX 2060 SUPER)

As imagens foram capturadas em janela com resolução nativa de viewport e estão salvas em `tests/evidencias/m6b3/`:

1. `setor6_referencia.png`: Vista de referência do Setor 6 homologado.
2. `setor7_01_entrada.png`: Entrada do Setor 7 (Fenda das Vértebras).
3. `setor7_02_meio.png`: Vista central com vértebras fósseis e névoa.
4. `setor7_03_estruturas_fossilizadas.png`: Arcadas ósseas e abóbada vertebral.
5. `setor7_04_plataformas.png`: Caminho elevado por galhos e costelas.
6. `setor7_05_saida.png`: Terraço leste de saída do Setor 7.
7. `setor8_01_entrada.png`: Entrada do Setor 8 (Bosque dos Ecos).
8. `setor8_02_meio.png`: Clareira central sob a abóbada vegetal.
9. `setor8_03_area_monumental.png`: Monólito dos Ecos e chamas etéreas.
10. `setor8_04_plataformas.png`: Cipós e plataformas da copa fechada.
11. `setor8_05_saida.png`: Margem leste e limite da fase.
12. `transicao_setor6_para_7.png`: Transição plana entre os setores 6 e 7.
13. `transicao_setor7_para_8.png`: Transição plana entre os setores 7 e 8.
14. `aren_travessia_obstaculo_s7.png`: Aren saltando fisicamente sobre o vão da fenda no Setor 7.
15. `comparacao_setores_6_7_8.png`: Painel vertical comparativo dos setores 6, 7 e 8 (1280 × 2160 px).

---

## 8. AUDITORIA DE SEGURANÇA E INTEGRIDADE

### 8.1 Preservação do Save Pessoal
- **Caminho:** `C:\Users\ovohe\AppData\Roaming\Godot\app_userdata\Cinzas do Juramento\cinzas_abbey_progress_v1.json`
- **Tamanho:** **215 bytes** (inalterado).
- **SHA-256:** `4DB32167231D18C4B0872C73A8647FE6803C86C3E1FE5B49D68BE8012405797F` (100% íntegro).

### 8.2 Tabela dos 15 Arquivos Canônicos Protegidos
| Arquivo Protegido | SHA-256 Canônico | Status |
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

### 8.3 Conformidade Git
- **HEAD:** Inalterado (`c819dfb67eafc61516ee68ff36500ab8888539bd`).
- **Índice Git (`staged`):** VAZIO (`git diff --cached` limpo).
- **Commits Locais:** ZERO commits efetuados.
- **Push / Deploy:** ZERO comandos remotos.
- **Modificações não relacionadas na working tree:** Preservadas sem alterações.

---

## 9. CLASSIFICAÇÃO FINAL DA ENTREGA

- **Funcionalidade:** **PASS** (177/177 verificações aprovadas, travessia bidirecional completa $1 \leftrightarrow 8$ funcional).
- **Renderização Técnica:** **PASS** (Paralaxe consistente, sem colagens ou recortes, renderização 1280x720 na RTX 2060 SUPER sem erros).
- **Segurança e Isolamento:** **PASS** (Save pessoal intacto, 15 arquivos protegidos intactos, zero commit, zero push).
- **Aprovação Visual do Responsável:** **PENDENTE** (Aguardando avaliação humana do playtest).

---

## 10. COMANDO PARA PLAYTEST MANUAL HUMANO

Para iniciar e jogar diretamente os 8 setores da Floresta dos Ossos:

```powershell
& 'C:\Users\ovohe\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe' --path 'C:\PROJETOS\CINZAS DO JURAMENTO' 'scenes/forest/forest_pilots.tscn'
```
*(Controles: A/D mover · Espaço saltar · Shift Passo das Sombras/Dash · J atacar com espada · F7 reiniciar · F1 alternar ajuda de tela)*
