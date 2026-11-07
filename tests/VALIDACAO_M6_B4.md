# RELATÓRIO DE VALIDAÇÃO TÉCNICA E FUNCIONAL — M6-B4
## CONCLUSÃO ESTRUTURAL DA FLORESTA DOS OSSOS (10 SETORES)
### Setor 9: Ravina das Sombras Fósseis | Setor 10: Clareira da Bruma Espectral (Arena do Cervo Espectral)

- **Data da Auditoria:** 07 de novembro de 2026
- **Engine:** Godot Engine v4.7.2.stable.official.ed1daf0bf
- **Dispositivo de Renderização:** NVIDIA GeForce RTX 2060 SUPER (OpenGL API 3.3.0 / Compatibility Mode)
- **Resolução Lógica Interna:** 320 × 180 (Pixel Art Escalonado com Canvas Items Inteiro)
- **Resolução da Janela de Testes / Captura:** 960 × 540 (Escala 3× Nativa)
- **Branch Git:** `main`
- **HEAD Consolidado de Referência:** `388dc848ac71d8d8e0294139ead7e78e066fbbab` (`feat(forest): consolida M6-B3 e correcoes de acessibilidade`)
- **Staging Area:** 0 bytes staged (`git diff --cached` limpo)
- **Estado da Operação:** Implementação local concluída com sucesso. NENHUM commit ou push executado. Aguardando playtest manual e homologação pelo responsável.

---

## 1. RESUMO EXECUTIVO E DECISÕES CANÔNICAS

Em conformidade estrita com a aprovação canônica oficial do responsável pelo projeto, a Fase 3 — **Floresta dos Ossos** foi concluída em sua estrutura geográfica e arquitetural, totalizando exatamente **10 setores contínuos e bidirecionais**:

1. **Setor 1 — Entrada da Floresta** (M6-A / FIX02)
2. **Setor 2 — Bosque das Raízes e Santuário do Cervo** (M6-A / FIX01)
3. **Setor 3 — Passagem dos Fósseis** (M6-B1)
4. **Setor 4 — Clareira Ancestral** (M6-B1)
5. **Setor 5 — Passagem das Raízes Profundas** (M6-B2)
6. **Setor 6 — Galeria dos Ossos Antigos** (M6-B2)
7. **Setor 7 — Fenda das Vértebras** (M6-B3)
8. **Setor 8 — Bosque dos Ecos** (M6-B3)
9. **Setor 9 — Ravina das Sombras Fósseis** (M6-B4 — Novo)
10. **Setor 10 — Clareira da Bruma Espectral** (M6-B4 — Novo / Arena da Futura Batalha contra o Cervo Espectral)

### Limites Rígidos de Escopo Preservados
- **Chefe Cervo Espectral:** NÃO implementado (comportamento, IA, ataques, barra de vida e padrões de combate reservados para marcos subsequentes).
- **Inimigos e Armadilhas:** NÃO implementados (reservados para M6-C).
- **Recompensas e Habilidades:** Nenhuma habilidade nova adicionada a Aren; nenhum desbloqueio da Fase 4.
- **Save Pessoal:** 100% intacto, protegido e verificado (215 bytes, SHA-256 `4DB32167...`).
- **Arquivos Protegidos Canônicos:** 15/15 arquivos mantidos intactos.

---

## 2. ESPECIFICAÇÃO TÉCNICA E GEOMETRIA DOS NOVOS SETORES

### 2.1 Setor 9 — Ravina das Sombras Fósseis
- **Origem Global:** `Vector2(9600, 0)`
- **Dimensões:** 960 × 420 px
- **Conexão Oeste (Entrada):** `Rect2(0, 240, 160, 180)` em $y=240.0$, perfeitamente nivelada com a saída do Setor 8 ($y=240.0$, $\Delta y = 0$).
- **Perfil do Terreno Principal:**
  - Descida suave: `Rect2(160, 260, 150, 160)` ($y=260.0$, $\Delta y = 20\text{ px}$).
  - Patamar inferior da ravina: `Rect2(310, 280, 150, 140)` ($y=280.0$, $\Delta y = 20\text{ px}$).
  - **Vão da Ravina (Gap):** $x \in [460, 506]$ (46 px de largura, ambos os lados nivelados em $y=280.0$). Salto limpo com corrida normal ou Dash terrestre.
  - Recepção leste da ravina: `Rect2(506, 280, 150, 140)` ($y=280.0$).
  - Subida suave em degrau fóssil: `Rect2(656, 260, 150, 160)` ($y=260.0$, $\Delta y = 20\text{ px}$).
  - Terraço de saída leste: `Rect2(806, 260, 154, 160)` ($y=260.0$).
- **Caminho Aéreo (Plataformas Suspensas):**
  - Arco suspenso contínuo formado por 7 segmentos de costelas e vértebras titânicas com física one-way (sem bloquear o tráfego térreo):
    - Branch 0: `Rect2(100, 216, 75, 12)` ($y=216$, subida de 24 px da entrada).
    - Branch 1: `Rect2(205, 194, 85, 12)` ($y=194$, subida de 22 px).
    - Branch 2: `Rect2(320, 172, 90, 12)` ($y=172$, subida de 22 px).
    - Branch 3: `Rect2(440, 154, 110, 14)` ($y=154$, sobrevoando o abismo da ravina).
    - Branch 4: `Rect2(580, 176, 90, 12)` ($y=176$, descida suave de 22 px).
    - Branch 5: `Rect2(700, 202, 80, 12)` ($y=202$, descida de 26 px).
    - Branch 6: `Rect2(805, 234, 75, 12)` ($y=234$, descida de 26 px para o terraço leste).
  - Todos os saltos $\le 26\text{ px}$, totalmente escaláveis em ambos os sentidos.

### 2.2 Setor 10 — Clareira da Bruma Espectral (Arena do Cervo Espectral)
- **Origem Global:** `Vector2(10800, 0)`
- **Dimensões:** 960 × 420 px
- **Conexão Oeste (Entrada):** `Rect2(0, 260, 160, 160)` em $y=260.0$, perfeitamente nivelada com a saída do Setor 9 ($y=260.0$, $\Delta y = 0$).
- **Chão de Combate da Arena:**
  - `Rect2(160, 260, 640, 160)` em $y=260.0$ contínuo.
  - Vão plano e sem degraus de 640 px de extensão ($x \in [160, 800]$), projetado para suportar movimentação, investidas e saltos de um chefe quadrúpede colossal.
- **Extremo Leste (Altar e Pórtico):**
  - `Rect2(800, 260, 160, 160)` em $y=260.0$.
  - Altar corrompido central em $x=442..518$ com névoa espectral e chamas turquesa.
  - Pórtico do Juramento em $x=870..950$ com runas antigas que delimitam a fase.
- **Poleiros Táticos para Evasão e Visão Geral:**
  - Abóbada catedralícia de 6 plataformas suspensas em arco ogival com física one-way:
    - Branch 0: `Rect2(140, 234, 85, 12)` ($y=234$, 26 px acima do chão).
    - Branch 1: `Rect2(255, 210, 90, 12)` ($y=210$, 24 px acima de B0).
    - Branch 2: `Rect2(375, 186, 90, 12)` ($y=186$, 24 px acima de B1).
    - Branch 3: `Rect2(495, 186, 90, 12)` ($y=186$, topo plano da abóbada).
    - Branch 4: `Rect2(615, 210, 90, 12)` ($y=210$, 24 px abaixo de B3).
    - Branch 5: `Rect2(735, 234, 85, 12)` ($y=234$, 24 px abaixo de B4).
  - Vãos horizontais entre plataformas: exatamente 30 px.
  - Totalmente acessíveis do solo ou de plataforma adjacente sem interferir na corrida no chão da arena.

---

## 3. ASSETS DE ARTE E ESPECIFICAÇÃO TÉCNICA

| Arquivo de Imagem | Resolução | Formato | Finalidade |
|---|---|---|---|
| `assets/art/m6a/forest_sector9_bg.png` | 1774 × 887 px | PNG (RGB 24-bit) | Fundo panorâmico distante do Setor 9 (Ravina). Paralaxe (0.12, 0.08). |
| `assets/art/m6a/forest_sector9_bg.png.import` | — | Godot Import | Textura comprimida sem emendas em `.godot/`. |
| `assets/art/m6a/forest_sector10_bg.png` | 1774 × 887 px | PNG (RGB 24-bit) | Fundo panorâmico distante do Setor 10 (Arena). Paralaxe (0.12, 0.08). |
| `assets/art/m6a/forest_sector10_bg.png.import` | — | Godot Import | Textura comprimida sem emendas em `.godot/`. |

---

## 4. BATERIA DE TESTES AUTOMATIZADOS E REGRESSÃO (100% SUCESSO)

Todas as suítes foram executadas com perfil isolado temporário de usuário (`APPDATA` isolado e `SAVE_SAFETY_ISOLATED_ROOT` configurado):

| Suíte de Testes | Arquivo de Teste | Checagens | Falhas | Status |
|---|---|---|---|---|
| **Segurança do Save** | `tests/save_safety_01_test.gd` | 7 | 0 | **PASS** |
| **Cinemática do Abade** | `tests/abbot_cinematic_test.gd` | 26 | 0 | **PASS** |
| **VFX do Dash de Aren** | `tests/dash_vfx_test.gd` | 47 | 0 | **PASS** |
| **Expansão M6-B1** | `tests/m6_b1_expansion_test.gd` | 33 | 0 | **PASS** |
| **Acessibilidade do Altar M6-B1** | `tests/m6_b1_altar_accessibility_test.gd` | 15 | 0 | **PASS** |
| **Expansão M6-B2** | `tests/m6_b2_expansion_test.gd` | 46 | 0 | **PASS** |
| **Expansão M6-B3** | `tests/m6_b3_expansion_test.gd` | 59 | 0 | **PASS** |
| **Acessibilidade Geral M6** | `tests/m6_platform_accessibility_test.gd` | 44 | 0 | **PASS** |
| **Expansão M6-B4 (Setores 9 e 10)** | `tests/m6_b4_expansion_test.gd` | 70 | 0 | **PASS** |
| **TOTAL CONSOLIDADO** | **9 suítes automatizadas** | **347** | **0** | **100% PASS** |

### Destaques das 70 Checagens da Suíte M6-B4
- 10/10 setores registrados, nomeados e instanciados em `ForestLayout` e `ForestDemo`.
- Nivelamento exato das conexões: S8 $\to$ S9 ($y=240.0$), S9 $\to$ S10 ($y=260.0$).
- Degraus internos do Setor 9 limitados rigorosamente a 20 px.
- Piso de 640 px da arena do Setor 10 100% plano em $y=260.0$.
- Travessia progressiva de ida (Setor 1 ao 10) concluída com `demo.completed = true` no Setor 10.
- Travessia progressiva de volta (Setor 10 ao 1) concluída sem retenção ou bloqueio.
- Travessia física real por física simulada no Vão da Ravina (46 px) de ida e de volta.
- Corrida contínua na arena do Setor 10 cobrindo do portal oeste ao pórtico leste sem obstrução.
- Acessibilidade das plataformas aéreas nos Setores 9 e 10 com saltos simples $\le 26\text{ px}$.
- Recuperação segura de queda no abismo testada e validada em todos os 10 setores.
- Clamping da câmera 2D testado e contido rigorosamente dentro da tela nos 10 setores.

---

## 5. EVIDÊNCIAS GRÁFICAS DE GPU CAPTURADAS (960 × 540)

Todas as capturas foram obtidas diretamente da viewport renderizada pela GPU (RTX 2060 SUPER) através do script `tests/m6_b4_visual_capture.gd` e salvas em `tests/evidencias/m6b4/`:

1. `setor8_referencia.png`: Aren no terraço do Monólito dos Ecos (referência homologada).
2. `setor9_01_entrada.png`: Aren na entrada do Setor 9, no patamar nivelado a $y=240$.
3. `setor9_02_ravina_meio.png`: Aren descendo para o fundo da ravina fóssil ($y=280$).
4. `setor9_03_abismo_sombras.png`: Aren diante do vão central de 46 px e da arcada vertebral suspensa.
5. `setor9_04_plataformas_aereas.png`: Aren posicionado sobre a ponte fóssil aérea ($y=154$).
6. `setor9_05_terraco_saida.png`: Aren no terraço leste do Setor 9 pronto para transicionar ao Setor 10.
7. `setor10_01_entrada_arena.png`: Aren entrando na Clareira da Bruma Espectral ($y=260$).
8. `setor10_02_visao_geral_arena.png`: Aren correndo pelo chão plano da futura arena de combate.
9. `setor10_03_altar_bruma_espectral.png`: Aren diante do altar corrompido envolto em bruma e chamas turquesa.
10. `setor10_04_abobada_costelas_poleiro.png`: Aren no poleiro da abóbada de costelas contemplando a arena.
11. `setor10_05_portico_do_juramento.png`: Aren diante do Pórtico Rúnico no extremo leste da fase.
12. `transicao_setor8_para_9.png`: Aren cruzando a fronteira $x=936$ entre Setor 8 e Setor 9.
13. `transicao_setor9_para_10.png`: Aren cruzando a fronteira $x=936$ entre Setor 9 e Setor 10.
14. `aren_salto_abismo_s9.png`: Ação em tempo real de Aren saltando sobre o abismo da ravina no Setor 9.
15. `painel_m6_b4.png`: Painel comparativo consolidado em alta resolução (1980 × 674 px).

---

## 6. VERIFICAÇÃO DE INTEGRIDADE DO SAVE E DOS ARQUIVOS PROTEGIDOS

### 6.1 Save Pessoal
- **Caminho:** `C:\Users\ovohe\AppData\Roaming\Godot\app_userdata\Cinzas do Juramento\cinzas_abbey_progress_v1.json`
- **Tamanho:** 215 bytes
- **SHA-256:** `4DB32167231D18C4B0872C73A8647FE6803C86C3E1FE5B49D68BE8012405797F`
- **Status:** **100% INTACTO E PROTEGIDO**

### 6.2 15 Arquivos Protegidos Canônicos
- `project.godot`: Limpo e idêntico a HEAD no Git.
- 14 imagens e arquivos de importação canônicos: **100% íntegros**.

---

## 7. COMANDO PARA PLAYTEST MANUAL PELO RESPONSÁVEL

O responsável pode iniciar imediatamente o playtest manual executando no terminal PowerShell:

```powershell
& "C:\Users\ovohe\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe" --path "C:\PROJETOS\CINZAS DO JURAMENTO" "res://scenes/forest/forest_pilots.tscn"
```

### Controles no Playtest:
- **A / D:** Mover para esquerda / direita.
- **Espaço:** Saltar (impulso vertical calibrado em $-230\text{ px/s}$).
- **Shift:** Passo das Sombras (Dash desbloqueado para a Fase 3).
- **J:** Golpe de espada.
- **F1 / H:** Alternar exibição de ajuda e textos narrativos no HUD.
- **F7:** Reiniciar a demonstração da fase.
