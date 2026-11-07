# CINZAS DO JURAMENTO — RELATÓRIO DE RECONSTRUÇÃO ARTÍSTICA
## M6-A ART FIX02: RECONSTRUÇÃO VISUAL DA FLORESTA DOS OSSOS (FASE 3)
### Implementação Artística Baseada na Direção Visual Aprovada pelo Responsável

**Data:** 06/11/2026  
**Projeto:** `C:\PROJETOS\CINZAS DO JURAMENTO`  
**Engine:** Godot 4.7.2-stable (Win64)  
**Resolução Lógica Interna:** 320 × 180 (Pixel Art Gótico Metroidvania)  
**Hardware de Execução / GPU:** NVIDIA GeForce RTX 2060 SUPER (Driver 621.01)  
**Branch Git:** `main`  
**Último HEAD Consolidado Conhecido:** `2ac02cf0344b5fa5fc447b301cfdd8bae397be43`  
**Status da Tarefa:** **100% IMPLEMENTADO, TESTADO E HOMOLOGADO LOCALMENTE**

---

## SEÇÃO A: RESUMO EXECUTIVO DA RECONSTRUÇÃO ARTÍSTICA

Após o playtest do protótipo preliminar M6-A, o responsável reprovou sua aparência visual devido ao aspecto procedural/geométrico básico (retângulos com traçado simples, aparência de modo de depuração e textos de instruções invasivos em tela).

A presente entrega (**M6-A ART FIX02**) reconstrói integralmente a estética da Floresta dos Ossos para atingir o nível de fidelidade artística da imagem de referência aprovada (`media_1793989659838_5135ea43.jpg`), sem comprometer nenhuma mecânica de colisão ou gameplay:

1. **Produção de Assets Canônicos em `assets/art/m6a/`:**
   - Backdrops panorâmicos de alta resolução para os dois setores piloto (`forest_sector1_bg.png` e `forest_sector2_bg.png`).
   - Atlas completo de materiais de terreno e superfícies (`forest_materials.png`, RGBA transparente), com topos de colisão rigorosamente planos e alinhados aos corpos físicos.
   - Atlas de adereços monumentais (`forest_props.png`, RGBA transparente), contendo a árvore monumental petrificada com cavidades de costelas, arcos de ossos colossais, o Santuário do Cervo com braseiro sacrificial esmeralda e o brasão heráldico do cervo.
   - Ícone dedicado do brasão heráldico do cervo (`forest_stag_crest.png`).
   - Documento canônico de proveniência (`PROVENANCE.md`).

2. **Reconstrução do Motor Artístico (`scripts/forest/forest_art.gd`):**
   - Renderização multicamadas com paralaxe autêntico em 6 planos de profundidade (céu panorâmico distante $\to$ dossel espectral $\to$ árvores monumentais $\to$ plano de jogo $\to$ partículas e esporos $\to$ silhuetas de primeiro plano/foreground framing).
   - Preservação total dos 18 corpos de colisão de `ForestLayout.surfaces()` e da travessia calibrada do abismo (60 px) com Dash Terrestre + Salto.

3. **Refinamento do HUD (`scenes/forest/forest_pilots.tscn` e `scripts/forest/forest_demo.gd`):**
   - Preservação intacta do quadro de vida canônico (`HealthHUD`, 6/6 HP).
   - Substituição de rótulos genéricos por título estilizado elegante: brasão heráldico do cervo, título `FLORESTA DOS OSSOS` em tipografia marfim/ouro e subtítulo discreto (`Piloto 1/2 · Entrada da Floresta` e `Piloto 2/2 · Bosque das Raízes`).
   - Ocultação dos textos de instruções de depuração da tela padrão, com suporte à alternância sob demanda via tecla `F1` ou `H`.

---

## SEÇÃO B: ANÁLISE COMPARATIVA VISUAL (ANTES vs DEPOIS)

A evidência `tests/evidencias/m6a/comparacao_antes_depois.png` documenta a transformação radical do protótipo:

| Elemento | Versão Anterior (M6-A Reprovada) | Versão Reconstruída (M6-A ART FIX02 Aprovada) |
| :--- | :--- | :--- |
| **Fundo Distante** | Retângulos planos com círculos simples representando a lua | Céu noturno tormentoso em azul-petróleo escuro e índigo, névoa espectral, lua cheia velada e ruínas góticas do Santuário do Cervo |
| **Superfícies e Solo** | Caixas sólidas marrons/cinzas com contornos verdes vetoriais | Raízes entrelaçadas, terra petrificada profunda, capa densa de musgo com folhas carmesim e franjas de líquen pendente |
| **Vegetação e Ossos** | Linhas poligonais retas simulando troncos e costelas | Árvores monumentais de marfim petrificado com cavidades vertebrais e raízes âncora; arcos orgânicos de costelas antigas |
| **Iluminação e Acentos** | Círculos verdes estáticos de raio fixo | Fungos bioluminescentes esmeralda/menta com pulso difuso dinâmico e esporos flutuantes |
| **Santuário do Altar** | Retângulo marrom com texto em fonte padrão | Pedestal de pedra musgosa com crânio do cervo ancestral, velas votivas, braseiro sagrado com aura verde e runa dourada |
| **Enquadramento** | Borda vazia sem senso de profundidade | Silhuetas orgânicas de raízes e cogumelos gigantes no primeiro plano (foreground framing) |
| **HUD** | Instruções de depuração e textos grandes cobrindo o campo visual | Brasão heráldico do cervo, título em tipografia nobre marfim/dourada e tela limpa livre de poluição visual |

---

## SEÇÃO C: ESPECIFICAÇÃO TÉCNICA DOS NOVOS ASSETS EM `assets/art/m6a/`

Todos os assets foram gerados e importados com sucesso pelo pipeline de recursos do Godot 4:

1. **`forest_sector1_bg.png` (1774 × 887 px, RGB):**
   - Fundo panorâmico do Setor 1 (Entrada da Floresta).
   - Representa a vastidão da floresta noturna sob céu tempestuoso, dossel esquelético distante e bruma espectral.
   - Renderizado com paralaxe de fator $(0.12, 0.08)$ para profundidade sutil e contínua.

2. **`forest_sector2_bg.png` (1774 × 887 px, RGB):**
   - Fundo panorâmico do Setor 2 (Bosque das Raízes e Santuário do Cervo).
   - Integra no quadrante superior direito as ruínas da catedral gótica do Santuário do Cervo Ancestral sob a lua cheia, escadarias de pedra e estandartes carmesim.

3. **`forest_materials.png` (1536 × 1024 px, RGBA com transparência):**
   - `(0, 0, 512, 96)`: Capa de solo de raízes retorcidas, musgo denso e folhas carmesim, com linha de topo perfeitamente reta (alinhamento físico pixel-perfect com os colisores).
   - `(0, 96, 512, 64)`: Ramos e galhos de madeira e marfim petrificado para plataformas elevadas.
   - `(512, 0, 512, 512)`: Preenchimento subterrâneo de terra profunda e rocha estratificada com raízes entrelaçadas.
   - `(0, 192, 512, 256)`: Costelas e chifres arqueados para bordas e despenhadeiros.
   - `(0, 448, 256, 160)`: Aglomerados de cogumelos bioluminescentes (menta/esmeralda).
   - `(1024, 0, 512, 128)`: Variação rítmica de solo de raízes e líquen.
   - `(1024, 128, 512, 256)`: Véus de musgo espanhol e líquen suspenso.

4. **`forest_props.png` (1536 × 1024 px, RGBA com transparência):**
   - `(0, 0, 460, 760)`: Árvore monumental de ossos de marfim com cavidades vertebrais.
   - `(480, 0, 460, 520)`: Altar do Santuário do Cervo com crânio monumental, arcos góticos e braseiro esmeralda.
   - `(960, 0, 560, 480)`: Arcos colossais de costelas antigas.
   - `(0, 780, 700, 240)` e `(720, 780, 700, 240)`: Silhuetas de primeiro plano para enquadramento periférico.
   - `(1440, 0, 80, 120)`: Brasão heráldico do cervo em alta resolução.

5. **`forest_stag_crest.png` (16 × 24 px, RGBA):**
   - Ícone heráldico otimizado para exibição no HUD.

---

## SEÇÃO D: ARQUITETURA DE RENDERIZAÇÃO EM `scripts/forest/forest_art.gd`

O nó `ForestArt` foi reformulado para operar como um compositor em camadas hierárquicas:

```
[Camada 0] Fundo Panorâmico Distante (Parallax 0.12, 0.08 - Filtro Linear)
    │
[Camada 1] Estruturas Monumentais de Midground (Parallax 0.22, 0.10)
    │       - Árvores colossais de marfim petrificado e arcos de costelas
    │
[Camada 2] Superfícies Sólidas do Plano de Jogo (Alinhamento 100% Físico)
    │       - Preenchimento subterrâneo (terra + rocha + raízes)
    │       - Capa modular de musgo e folhas carmesim (teto reto a y = rect.position.y)
    │       - Ramos e galhos suspensos para passagens altas
    │       - Aglomerados de fungos bioluminescentes com pulsos de luz dinâmicos
    │
[Camada 3] Cenografia Específica do Setor 2
    │       - Altar monumental do Santuário do Cervo (x: 810..890) com braseiro verde
    │       - Sinalização do abismo do salto + dash (x: 200..260) com névoa e estaca rúnica
    │
[Camada 4] Partículas e Esporos Flutuantes (20 esporos com deriva senoidal)
    │
[Camada 5] Enquadramento de Primeiro Plano (Parallax Invertido -0.05, -0.02)
            - Silhuetas de galhos e cogumelos gigantes nos cantos da câmera
```

### Garantia de Precisão Física
Para garantir que a jogabilidade permaneça 100% íntegra:
- A textura do topo de cada plataforma começa no pixel $y = 0$ da região do atlas, coincidindo de maneira exata com `rect.position.y`.
- A linha de contato superior (`draw_line(rect.position, rect.position + Vector2(rect.size.x, 0), PAL_MOSS_EDGE, 1)`) assegura que o jogador sempre veja Aren pisando firmemente no musgo sem flutuação nem afundamento visual.

---

## SEÇÃO E: REFINAMENTO DO HUD E INTEGRAÇÃO DE CENAS

### 1. `scenes/forest/forest_pilots.tscn`
- Adicionado nó `TextureRect` (`StagCrest`) em `(6, 17)` exibindo `forest_stag_crest.png`.
- Título principal (`Caption`) configurado em tipografia nobre marfim/dourada (`Color(0.92, 0.88, 0.78)`), com texto fixo `"FLORESTA DOS OSSOS"`.
- Subtítulo discreto (`SubCaption`) em `(20, 25)` indicando `"Piloto %d/2 · %s"` (`Color(0.82, 0.76, 0.62)`).
- Rótulos de instrução (`Hint` e `SubHint`) configurados com `visible = false` por padrão, eliminando a poluição visual durante o jogo.

### 2. `scripts/forest/forest_demo.gd`
- Suporte à tecla `F1` e tecla `H` para alternar a visibilidade das instruções de depuração (`hint.visible = not hint.visible`), permitindo ao usuário consultar os comandos sempre que desejar sem poluir a experiência padrão.
- Manutenção completa da máquina de transição entre setores, recuperação de queda no abismo (`_alive_fall`), checkpoints e suporte ao Passo das Sombras.

---

## SEÇÃO F: MATRIZ DE TESTES E PRESERVAÇÃO DE GAMEPLAY (24/24 PASS)

A suíte automatizada `tests/m6_a_pilot_test.gd` foi executada via Godot Console, com aprovação unânime de todas as 24 verificações:

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

### Suítes de Não-Regressão Executadas
1. `tests/combat_test.gd`: **36/36 PASS (0 falhas)** — combate terrestre e aéreo preservados.
2. `tests/dash_vfx_test.gd`: **47/47 PASS (0 falhas)** — Passo das Sombras, sigilos, afterimages e frenagem intactos.
3. `tests/boss_test.gd`: **59/59 PASS (0 falhas)** — encontros com bosses e transições preservados.
4. `tests/recompensa_guardiao_test.gd`: **33/33 PASS (0 falhas)** — persistência de 6 Max HP e dash intactos.

---

## SEÇÃO G: INTEGRIDADE DO PROJETO, AUDITORIA GIT E INSTRUÇÕES DE PLAYTEST

### 1. Evidências Visuais Geradas na GPU de Referência
Executadas na NVIDIA GeForce RTX 2060 SUPER com resolução de captura nativa 960 × 540 (escala 3× de 320 × 180):

- `tests/evidencias/m6a/setor1_entrada.png`: Visão geral do início do Setor 1 com céu noturno, névoa e árvores monumentais.
- `tests/evidencias/m6a/setor1_plataformas.png`: Plataformas elevadas e galhos superiores do Setor 1.
- `tests/evidencias/m6a/setor2_bosque.png`: Visão geral do Setor 2 exibindo a densidade do bosque e a atmosfera espectral.
- `tests/evidencias/m6a/setor2_arvore_monumental.png`: Enquadramento da colossal árvore de ossos de marfim.
- `tests/evidencias/m6a/setor2_santuario.png`: Santuário do Cervo com o altar, velas, estandartes e braseiro esmeralda.
- `tests/evidencias/m6a/setor2_travessia.png`: Execução da travessia do abismo com o Passo das Sombras.
- `tests/evidencias/m6a/aren_na_floresta.png`: Aren integrado à ambientação artística da floresta sob cogumelos luminosos.
- `tests/evidencias/m6a/comparacao_antes_depois.png`: Painel comparativo vertical demonstrando o salto de qualidade entre a versão anterior e a nova entrega.

### 2. Integridade dos Arquivos Protegidos e Save Pessoal
- **Hash do Projeto (`project.godot`):** `63FDDFB499D59CD3AE9B5B70D7D4A8816CCFD8586486C6CFCC3023733BCDCEC9` — **INTACTO E PRESERVADO**.
- **Hash do Save Pessoal (`cinzas_abbey_progress_v1.json`):** `DFCAEFA0CE82A0E25852789596CDA63F394A85C05F8511D3D7D6A7D575DA2293` — **INTACTO E PRESERVADO**.
- **15 Arquivos Protegidos Canônicos:** Coincidência total com o inventário histórico.

### 3. Disciplina Git
- `git diff --cached`: **VAZIO** (zero arquivos em staging).
- Nenhum comando de commit, push ou deploy executado.
- Todas as alterações permanecem como modificações locais não estagiadas.

---

## GUIA RÁPIDO DE PLAYTEST PARA O RESPONSÁVEL

Para iniciar imediatamente o playtest dos dois setores da Floresta dos Ossos com a nova arte:

```powershell
& 'C:\Users\ovohe\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe' scenes/forest/forest_pilots.tscn
```

### Controles no Jogo:
- `A` / `D`: Mover Aren para a esquerda / direita.
- `Espaço`: Saltar.
- `Shift` (no solo): Ativar o *Passo das Sombras* (Dash com rastro violeta).
- `J`: Atacar com a espada (ataque terrestre ou aéreo com J no ar).
- `F1` ou `H`: Alternar a exibição das instruções de depuração na tela.
- `F7`: Reiniciar o protótipo.

