# CINZAS DO JURAMENTO — RELATÓRIO DE VALIDAÇÃO TÉCNICA E ARTÍSTICA
## M6-A ART FIX03: Correção Crítica da Renderização Artística da Floresta dos Ossos

**Projeto:** Cinzas do Juramento  
**Engine:** Godot 4.7.2 (stable)  
**Resolução Lógica Interna:** 320 × 180 (Pixel Art 16-bit com escala inteira)  
**Hardware de Referência:** NVIDIA GeForce RTX 2060 SUPER (Windows 11)  
**Branch:** `main` | **HEAD:** `2ac02cf0344b5fa5fc447b301cfdd8bae397be43`  
**Data:** 06/11/2026  

---

## 1. RESUMO EXECUTIVO E CAUSA-RAIZ DA REPROVAÇÃO VISUAL (FIX02)

O protótipo visual anterior (M6-A ART FIX02) foi **reprovado** pelo responsável após inspeção in-game, que revelou artefatos visuais inaceitáveis:
1. **Colagens Retangulares Sobrepostas:** Blocos com bordas duras e retangulares cobrindo plataformas, árvores e cantos da tela.
2. **Duplicação do Santuário do Cervo:** O monumento gótico aparecia simultaneamente no pano de fundo estático e como um "adesivo" retangular flutuante no primeiro plano.
3. **Contaminação de Texturas do Solo:** Recortes retangulares brutos da arte conceitual continham pedaços da bota do cavaleiro Aren e remendos de fundo, repetidos ciclicamente no subsolo.
4. **Filtragem Inadequada (Linear Blur):** A interpolação bilinear padrão borrou a resolução 320x180, eliminando a nitidez de pixel art 16-bit.

### Causa-Raiz Técnica
A implementação do FIX02 tratou a pintura conceitual de referência única (`media_1793989659838_5135ea43.jpg`) como se fosse um spritesheet modular. O recorte mecânico de regiões da ilustração completa gerou retângulos com fundo opaco embutido (céu e névoa misturados com raízes), impedindo qualquer transparência orgânica. Ao aplicar esses recortes retangulares sobre a geometria física, surgiram "cartões" sobrepostos e duplicações.

### Solução Arquitetural Definitiva (FIX03)
1. **Separação Rigorosa de Assets:** Produção de sprites e módulos individuais isolados sobre fundo puro e convertidos com máscara alfa perfeita (RGBA 100% transparente fora dos contornos).
2. **Backdrops Puros e Distantes:** Panoramas de céu, neblina e lua pura (`forest_sector1_bg.png` e `forest_sector2_bg.png`), sem elementos de primeiro plano ou santuários queimados na imagem.
3. **Santuário Único:** O Santuário do Cervo foi isolado como prop sagrado de primeiro plano e posicionado unicamente sobre a plataforma do altar no Setor 2 (`x = 812, y = 196`), eliminando toda e qualquer duplicação.
4. **Filtragem Nearest-Neighbor:** Ativação forçada de `CanvasItem.TEXTURE_FILTER_NEAREST` em todos os nós visuais, garantindo fidelidade pixel art cristalina sem borramento.
5. **Composição Modular de Terreno:** Construção de superfícies com módulos de topo musgoso plano para alinhamento físico milimétrico com `ForestLayout.surfaces()`, saias de raízes retorcidas pendentes e preenchimento subterrâneo com padrão seamless de terra/húmus escuro.

---

## 2. INVENTÁRIO DE ASSETS MODULARES PRODUZIDOS

Todos os novos assets foram consolidados em `assets/art/m6a/` com rastreabilidade formal em `assets/art/m6a/PROVENANCE.md`:

| Arquivo | Resolução | Formato | Função e Conteúdo |
| :--- | :---: | :---: | :--- |
| `forest_sector1_bg.png` | 1774 × 887 | PNG (RGB) | Backdrop panorâmico do Setor 1: céu noturno gótico, lua cheia, copas distantes em silhueta, sem plataformas ou UI. |
| `forest_sector2_bg.png` | 1774 × 887 | PNG (RGB) | Backdrop panorâmico do Setor 2: céu com névoa mística e ruínas arruinadas na neblina profunda; **sem o Santuário queimado**. |
| `forest_materials.png` | 1024 × 512 | PNG (RGBA) | Atlas de terreno modular com canal alfa: topo de musgo horizontal, terminação esquerda/direita de raízes, galhos elevados, padrão seamless de terra profunda, cogumelos esmeralda luminescentes e espigões ósseos. |
| `forest_props.png` | 1024 × 512 | PNG (RGBA) | Atlas de monumentos e props isolados com canal alfa: Árvore-Óssea Colossal com vértebras vazadas, arcos de costelas petrificadas, galhadas de cervo e o **Santuário do Cervo** isolado em alta resolução. |

---

## 3. ARQUITETURA DE RENDERIZAÇÃO EM 6 PLANOS DE PARALLAX

A classe `ForestArt` (`scripts/forest/forest_art.gd`) foi integralmente reescrita, organizando a cena em 6 planos de profundidade visual independentes:

1. **Plano 0 — Céu Noturno e Neblina Distante (Parallax 0.08x):**
   - Panorama atmosférico infinito com movimento suave.
   - Texturas puras sem nenhum elemento de gameplay.
2. **Plano 1 — Silhuetas Góticas Distantes (Parallax 0.18x):**
   - Arcos ogivais e copas retorcidas em tons frios dessaturados.
3. **Plano 2 — Monumentos de Meia-Distância (Parallax 0.35x):**
   - Árvores petrificadas secundárias e vegetação intermediária que conferem profundidade tridimensional.
4. **Plano 3 — Camada de Gameplay / Colisão (Parallax 1.00x):**
   - Alinhamento pixel-perfect com as caixas de colisão de `ForestLayout`.
   - Topo de musgo plano (`y = surface.position.y`), saia de raízes pendentes e textura de húmus profundo.
   - Props de colisão: Árvore Monumental no Setor 2 (`x = 480`), Arcos de Costelas no abismo (`x = 180`) e o Santuário do Cervo no altar (`x = 812, y = 196`).
5. **Plano 4 — Efeitos Atmosféricos e Partículas (Parallax 1.00x):**
   - Névoa rasteira translúcida em tons verde-petróleo.
   - Bioluminescência suave pulsante ao redor dos cogumelos e das velas do santuário.
6. **Plano 5 — Moldura de Primeiro Plano (Parallax 1.15x):**
   - Silhuetas de galhos retorcidos, folhas carmesins e vinhas nos cantos superiores, emoldurando a ação sem obstruir a visão de Aren.

---

## 4. EVIDÊNCIAS VISUAIS CAPTURADAS NA GPU (RTX 2060 SUPER)

Foram geradas 12 capturas de tela reais executadas diretamente na GPU física de referência com o binário oficial Godot 4.7.2, além da imagem comparativa antes/depois:

### 4.1. Imagem Comparativa Direta
- `tests/evidencias/m6a/comparacao_antes_depois.png`:
  - **Superior (Antes - FIX02):** Mostra os blocos retangulares cortados, o santuário duplicado no centro da tela e o solo com artefatos repetitivos.
  - **Inferior (Depois - FIX03):** Mostra o Santuário do Cervo único, erguido organicamente sobre o topo do altar, solo contínuo com raízes orgânicas sem colagens, e iluminação mística coerente.

### 4.2. Galeria das 12 Capturas Oficiais
- **Setor 1 (Travessia Inicial e Galhos Elevados):**
  1. `setor1_01_inicio.png`: Spawn de Aren com HUD completo, solo contínuo sem cortes e parallax distante.
  2. `setor1_02_meio.png`: Tronco de transição e cogumelos luminescentes integrados à terra.
  3. `setor1_03_fim.png`: Zona de transição para o Setor 2, integridade de iluminação.
  4. `setor1_04_movimento_dash.png`: Execução do Passo das Sombras (dash) com VFX violeta sobre o novo terreno.
  5. `setor1_05_plataformas_altas.png`: Aren sobre galhos elevados, demonstrando colisão física exata.
  6. `setor1_06_parallax_deslocado.png`: Câmera com scroll lateral comprovando a fluidez dos 6 planos sem desalinhamento.
- **Setor 2 (Bosque das Raízes, Abismo e Santuário):**
  7. `setor2_01_inicio.png`: Entrada do setor e borda oeste do abismo.
  8. `setor2_02_abismo_travessia.png`: O abismo de 60 px com arcos de costelas petrificadas no vão e névoa profunda.
  9. `setor2_03_bosque_meio.png`: Meio do bosque com vegetação densa e solo com raízes entrelaçadas.
  10. `setor2_04_arvore_monumental.png`: Árvore-Óssea Colossal em transparência alfa pura (sem cartão branco ou cinza).
  11. `setor2_05_santuario_cervo.png`: O Santuário do Cervo definitivo no platô do altar, sem duplicações.
  12. `setor2_06_parallax_deslocado.png`: Profundidade angular comprovando que o monumento não se multiplica no horizonte.

---

## 5. RESULTADOS DAS SUÍTES DE TESTES (FUNCIONAL E REGRESSÃO)

| Suíte de Teste | Arquivo | Verificações | Resultado | Notas |
| :--- | :--- | :---: | :---: | :--- |
| **Piloto M6-A** | `tests/m6_a_pilot_test.gd` | 24 | **24 PASS / 0 FAIL** | Layout, inputs reais, travessia bidirecional do abismo com Dash+Salto, Alive Fall e limites de câmera. |
| **VFX do Dash** | `tests/dash_vfx_test.gd` | 47 | **47 PASS / 0 FAIL** | Passo das Sombras, tempos de cooldown, partículas violetas e frenagem. |
| **Combate Geral** | `tests/combat_test.gd` | 36 | **36 PASS / 0 FAIL** | Hitboxes da espada, golpe terrestre e novo golpe aéreo (J no ar). |
| **Boss M4-A** | `tests/boss_test.gd` | 59 | **59 PASS / 0 FAIL** | Ciclo completo do Abade das Correntes, fases 1 e 2, punição e vitória. |
| **Recompensas Bosses**| `tests/recompensa_guardiao_test.gd`| 33 | **33 PASS / 0 FAIL** | +1 HP máximo permanente (VIDA 6/6) e desbloqueio/persistência do Dash. |
| **Total Consolidado** | — | **199** | **199 PASS / 0 FAIL** | **100% de Aprovação Técnica.** |

---

## 6. AUDITORIA DE SEGURANÇA E DISCIPLINA GIT

- **Branch Atual:** `main`
- **HEAD do Repositório:** `2ac02cf0344b5fa5fc447b301cfdd8bae397be43` (inalterado)
- **Área de Preparação (`git diff --cached`):** **RIGOROSAMENTE VAZIA** (nenhum arquivo adicionado com `git add`).
- **Comandos de Versão:** Nenhum commit, amend, push ou deploy foi realizado.
- **Integridade dos 15 Arquivos Protegidos:**
  - `project.godot`: `63FDDFB499D59CD3AE9B5B70D7D4A8816CCFD8586486C6CFCC3023733BCDCEC9` (**INTACTO**)
  - `The Art of the Pixel.jpg` e sidecar `.import` (**INTACTOS**)
  - `The Siege and the Sandfox...jpg` e sidecar `.import` (**INTACTOS**)
  - 10 sidecars de evidências M3D `.png.import` (**INTACTOS**)
- **Preservação de Progresso:** O arquivo de save pessoal e histórico de campanha permanece intacto e isolado.

---

## 7. COMANDO PARA PLAYTEST INTERATIVO DO RESPONSÁVEL

Para iniciar imediatamente o playtest interativo da Floresta dos Ossos (Setores 1 e 2 com arte reconstruída e controles reais):

```powershell
& "C:\Users\ovohe\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe" --path "C:\PROJETOS\CINZAS DO JURAMENTO" "res://scenes/forest/forest_demo.tscn"
```

### Controles Durante o Playtest:
- **A / D ou Setas Esquerda/Direita:** Movimentação de Aren.
- **W / Espaço / Seta Cima:** Pulo (e pulo duplo se aplicável).
- **Shift:** Passo das Sombras (Dash terrestre com impulso horizontal de 260 px/s).
- **J:** Ataque com espada (no chão: corte horizontal; no ar: ataque aéreo com recuperação ao aterrissar).
- **Travessia do Abismo no Setor 2:** Acione **Shift** no chão na margem do abismo e pressione **Pulo** imediatamente para transpor o vão de 60 px com facilidade.

