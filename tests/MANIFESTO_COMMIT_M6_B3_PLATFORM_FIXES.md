# MANIFESTO DE COMMIT — M6-B3 + PLATFORM ACCESSIBILITY FIX01 + FIX02
## Floresta dos Ossos — Setores 7 e 8, Acessibilidade Geral de Plataformas e Desbloqueio do Setor 1

> [!CAUTION]
> **DOCUMENTO DE PRÉ-CONSOLIDAÇÃO — COMMIT E STAGING NÃO AUTORIZADOS**
> Este manifesto cataloga com precisão cirúrgica todos os arquivos candidatos para a futura consolidação em um único commit local.
> Conforme as diretrizes do projeto e a governança de versões, **NENHUM COMMIT (`git commit`) OU STAGING (`git add`) FOI EXECUTADO**.
> O repositório permanece no HEAD `c819dfb67eafc61516ee68ff36500ab8888539bd` com `git diff --cached` nulo (0 bytes).
> A consolidação depende estritamente da homologação visual dos Setores 7 e 8 e da autorização formal expressa do responsável.

---

## 1. Contexto e Identificação

- **Projeto:** `C:\PROJETOS\CINZAS DO JURAMENTO`
- **Engine:** Godot 4.7.2 (`Godot_v4.7.2-stable_win64_console.exe`)
- **Branch:** `main`
- **HEAD Consolidado de Referência:** `c819dfb67eafc61516ee68ff36500ab8888539bd`
- **Mensagem Sugerida para Futuro Commit:**
  `feat(forest): conclui setores 7 e 8, calibra plataformas aereas e desobstrui setor 1`
- **Save Pessoal Auditado:** `C:\Users\ovohe\AppData\Roaming\Godot\app_userdata\Cinzas do Juramento\cinzas_abbey_progress_v1.json`
  - Tamanho: 215 bytes
  - SHA-256: `4DB32167231D18C4B0872C73A8647FE6803C86C3E1FE5B49D68BE8012405797F`
  - Estado: 100% íntegro e inalterado.

---

## 2. Escopo Abrangido pela Consolidação Candidata

A futura consolidação unifica três entregas fundamentais para a conclusão do M6 (Fase 3 — Floresta dos Ossos):
1. **M6-B3 (Expansão dos Setores 7 e 8):**
   - Criação do Setor 7 (*Fenda das Vértebras*, $1280 \times 360\text{ px}$) e do Setor 8 (*Bosque dos Ecos / Monólito*, $960 \times 360\text{ px}$).
   - Cenários panorâmicos gerados em pixel art autoral conforme a identidade estética do Codex.
   - Conexões bidirecionais contínuas (Setor 6 $\leftrightarrow$ Setor 7 $\leftrightarrow$ Setor 8).
   - Checkpoint final da fase registrado no Setor 8.
2. **M6 PLATFORM ACCESSIBILITY FIX01 (Acessibilidade de Plataformas Aéreas):**
   - Auditoria e calibração das plataformas suspensas nos 8 setores da floresta.
   - Garantia matemática de acessibilidade baseada estritamente na cinemática nativa de Aren ($h_{\max} \approx 38.85\text{ px}$ com impulso $v_0 = -260\text{ px/s}$ e gravidade $870\text{ px/s}^2$).
   - Alturas de salto escalonadas entre $24\text{ px}$ e $36\text{ px}$ e vãos horizontais de $32\text{ px}$ a $48\text{ px}$.
   - Preservação de $40\text{ px}$ de pé-direito livre sobre o chão para trânsito sem impacto na cabeça.
3. **M6 PLATFORM FIX02 (Desobstrução do Retorno no Setor 1):**
   - Remoção da plataforma aérea obsoleta `Rect2(690, 254, 80, 12)` que colidia com a cabeça de Aren durante a subida do degrau de retorno no Setor 1.
   - Recalibração do pé-direito dos galhos remanescentes (`Branch 0` e `Branch 3`) para $\ge 40\text{ px}$.
   - Retorno desimpedido em todo o trajeto do Setor 1 ($x=887 \to x=24$).

---

## 3. Manifesto Detalhado dos Arquivos Candidatos

O pacote consolidado abrange exatamente **54 arquivos** (cenas, scripts, texturas, imports, testes, suítes de validação e capturas gráficas dos três marcos).

### 3.1. Cenas e Composição Godot (2 arquivos)

| Caminho Relativo | Tamanho (bytes) | SHA-256 | Descrição / Função |
| :--- | :---: | :--- | :--- |
| `scenes/forest/sector_07.tscn` | 369 | `61E0CDFF74AD15639657B3D3E183508F803112F0D054EBA4E8034BFBFE4B1642` | Instância de cena do Setor 7 (Fenda das Vértebras). |
| `scenes/forest/sector_08.tscn` | 369 | `9951586901E8E4D48338B365166A61113792BCC8925B937BE478CCE75D97909C` | Instância de cena do Setor 8 (Bosque dos Ecos). |

### 3.2. Recursos Visuais e Proveniência (5 arquivos)

| Caminho Relativo | Tamanho (bytes) | SHA-256 | Descrição / Função |
| :--- | :---: | :--- | :--- |
| `assets/art/m6a/forest_sector7_bg.png` | 2,281,792 | `09DE158640B2B9DC3E115D9995A620908141E3BAEF35792F9E3E4DF23A81834A` | Fundo panorâmico em pixel art para o Setor 7 ($1280 \times 360$). |
| `assets/art/m6a/forest_sector7_bg.png.import` | 970 | `E5D5ED7EBE1B4DA26B77A0197D1B4D06F6B8C65A677653FB64003EDD10275033` | Configuração de importação 2D sem compressão destrutiva do S7. |
| `assets/art/m6a/forest_sector8_bg.png` | 2,240,282 | `C03FBEC170FB92B6FAA0751FED2459DBCEB6E9756A0EE877C34A60245336F64C` | Fundo panorâmico em pixel art para o Setor 8 ($960 \times 360$). |
| `assets/art/m6a/forest_sector8_bg.png.import` | 970 | `CABFB74DBF6FA607FF274A6439018C13B27851F9AEEFA7FE223B968C2769F7D9` | Configuração de importação 2D sem compressão destrutiva do S8. |
| `assets/art/m6a/PROVENANCE.md` | 7,529 | `5F8A2A039443C050DDC79B279DABCB91FF93F9014B2EA9860203724583E8CFFC` | Registro de proveniência artística dos setores 7 e 8 da floresta. |

### 3.3. Scripts de Lógica e Level Design (4 arquivos)

| Caminho Relativo | Tamanho (bytes) | SHA-256 | Descrição / Função |
| :--- | :---: | :--- | :--- |
| `scripts/forest/forest_layout.gd` | 10,477 | `BAA62E5782146898496BC25150C76C9B739F571350FDCFEBD1646584AEB218EC` | Geometria, colisões, conexões, calibração de plataformas aéreas S1-S8 e fix S1. |
| `scripts/forest/forest_sector.gd` | 1,130 | `65BDFC50C60A1BAE9C3482A24B04557D7A897BCA86CF156D3C5559078DFA02DC` | Enumerações e propriedades temáticas dos 8 setores. |
| `scripts/forest/forest_art.gd` | 23,915 | `147FFD2283223B8DC02F9CCB3EDE734FC270BFB9F6157950D1BB4BE6430763E9` | Renderizador procedimental, arcos ósseos, iluminação, névoa e cogumelos dos 8 setores. |
| `scripts/forest/forest_demo.gd` | 7,225 | `2EAE008C6D78B499251999F9731405604E3167895763BED38BAB40AC421996C3` | Seletor de debug interativo com suporte às teclas `[1]` a `[8]`. |

### 3.4. Suítes de Testes Automatizados e Scripts de Captura dos Marcos (7 arquivos)

| Caminho Relativo | Tamanho (bytes) | SHA-256 | Descrição / Função |
| :--- | :---: | :--- | :--- |
| `tests/m6_b1_expansion_test.gd` | 13,349 | `BABF39810FEB2A26752B2C0A76947071F4BF606605752B840ECF9A57BD8D0ED1` | Suíte M6-B1 atualizada para asserção de 9 superfícies no S1 após remoção de obstáculo. |
| `tests/m6_b2_expansion_test.gd` | 14,871 | `0CB0FE45F2C5B5F8D9A5EC50FA1C92558939F1DAE030245F659C2168B87D573C` | Suíte M6-B2 atualizada para asserção de 9 superfícies no S1 após remoção de obstáculo. |
| `tests/m6_b3_expansion_test.gd` | 20,112 | `CD5F900BF28336B89C3336A0E1CFFCBE97E7504AB09E8105828FE5B93CBE78F0` | Suíte M6-B3 com 59 verificações aprovadas para os Setores 7 e 8. |
| `tests/m6_b3_visual_capture.gd` | 6,999 | `63D7118EDB4337CCDC851238B0EC6BEE3E974E83CA8E08754BF4AFBC48C3946E` | Script gerador de capturas GPU em 960x540 para M6-B3. |
| `tests/m6_platform_accessibility_test.gd` | 29,347 | `1DB02ABB8B22937AFF79F707167A580763C22959792AAF0FFE4C3EA957F22388` | Suíte com 44 verificações de física e alcance das plataformas nos 8 setores. |
| `tests/m6_platform_accessibility_capture.gd` | 5,636 | `1232C8183BCB9A2AA188D957E8E9FE33A665340A63F7857335E753FB5822E964` | Script gerador de capturas GPU para auditoria FIX01. |
| `tests/m6_platform_fix02_visual_capture.gd` | 3,271 | `C77C1C6B68F5DC4673E7BEC5850C544BD1072C6D915DDA3FF0A42C009F1AE047` | Script gerador de capturas GPU para auditoria FIX02 no Setor 1. |

### 3.5. Relatórios Técnicos de Validação (5 arquivos)

| Caminho Relativo | Tamanho (bytes) | SHA-256 | Descrição / Função |
| :--- | :---: | :--- | :--- |
| `tests/VALIDACAO_M6_B3.md` | 14,974 | `B23686D212B44DCDE981D35ADA90DE9CDD4A9C9875FD327020B8BB9F71C03940` | Relatório de homologação técnica do M6-B3 (Setores 7 e 8). |
| `tests/VALIDACAO_M6_PLATFORM_ACCESSIBILITY_FIX01.md` | 15,776 | `D50D101129D48234EA1CBD0A9C6655FCE7D9EB2B486F2FAA0F25A9992F0A7698` | Relatório técnico de calibração física das plataformas nos 8 setores. |
| `tests/VALIDACAO_M6_PLATFORM_FIX02.md` | 9,669 | `E1257DF1B2333348C8C8C22CE604F32E431EF398204DFB1E5D4E34333C50FA55` | Relatório de desobstrução e teste de travessia reversa no Setor 1. |
| `tests/VALIDACAO_FINAL_M6_B3_PLATFORM_FIXES.md` | 16,339 | `4A16D2D6AC90547CF3C710A32BA4FEE53EFAE4678BA5E6AD8512417A546528BE` | Relatório geral de auditoria e prontidão para consolidação. |
| `tests/MANIFESTO_COMMIT_M6_B3_PLATFORM_FIXES.md` | Auto-referência | *Verificado no fechamento* | Manifesto seletivo de commit pré-aprovado. |

### 3.6. Evidências Gráficas em GPU Real dos Três Marcos (31 arquivos)

#### M6-B3 — Expansão Setores 7 e 8 (`tests/evidencias/m6b3/` — 15 arquivos)
- `tests/evidencias/m6b3/aren_travessia_obstaculo_s7.png` (1,572,347 bytes | SHA-256 `90903E4B...`)
- `tests/evidencias/m6b3/comparacao_setores_6_7_8.png` (4,537,051 bytes | SHA-256 `7221C5C4...`)
- `tests/evidencias/m6b3/setor6_referencia.png` (1,702,438 bytes | SHA-256 `3EC47C19...`)
- `tests/evidencias/m6b3/setor7_01_entrada.png` (1,708,824 bytes | SHA-256 `294A8373...`)
- `tests/evidencias/m6b3/setor7_02_meio.png` (1,765,717 bytes | SHA-256 `C88C2721...`)
- `tests/evidencias/m6b3/setor7_03_estruturas_fossilizadas.png` (1,745,897 bytes | SHA-256 `7D86B1F7...`)
- `tests/evidencias/m6b3/setor7_04_plataformas.png` (1,490,012 bytes | SHA-256 `12433B06...`)
- `tests/evidencias/m6b3/setor7_05_saida.png` (1,707,760 bytes | SHA-256 `945F8F43...`)
- `tests/evidencias/m6b3/setor8_01_entrada.png` (1,656,038 bytes | SHA-256 `3A9BE910...`)
- `tests/evidencias/m6b3/setor8_02_meio.png` (1,657,363 bytes | SHA-256 `CC13BBF9...`)
- `tests/evidencias/m6b3/setor8_03_area_monumental.png` (1,692,533 bytes | SHA-256 `7CC8D7F0...`)
- `tests/evidencias/m6b3/setor8_04_plataformas.png` (1,416,656 bytes | SHA-256 `91951DC9...`)
- `tests/evidencias/m6b3/setor8_05_saida.png` (1,690,306 bytes | SHA-256 `6DC9B680...`)
- `tests/evidencias/m6b3/transicao_setor6_para_7.png` (1,679,842 bytes | SHA-256 `B71B2555...`)
- `tests/evidencias/m6b3/transicao_setor7_para_8.png` (1,707,900 bytes | SHA-256 `E73066F4...`)

#### M6 PLATFORM ACCESSIBILITY FIX01 (`tests/evidencias/m6_platform_accessibility/` — 10 arquivos)
- `tests/evidencias/m6_platform_accessibility/setor1_01_branch0_acessivel.png` (1,031,028 bytes | SHA-256 `883AEECD...`)
- `tests/evidencias/m6_platform_accessibility/setor1_02_canopea_central.png` (981,538 bytes | SHA-256 `58588F4E...`)
- `tests/evidencias/m6_platform_accessibility/setor2_01_dossel_raizes.png` (1,077,938 bytes | SHA-256 `D2C23EE6...`)
- `tests/evidencias/m6_platform_accessibility/setor2_02_sobrevoo_abismo.png` (1,064,546 bytes | SHA-256 `7016E05C...`)
- `tests/evidencias/m6_platform_accessibility/setor3_arco_desfiladeiro.png` (866,132 bytes | SHA-256 `0D1A53FB...`)
- `tests/evidencias/m6_platform_accessibility/setor4_arco_gotico.png` (850,586 bytes | SHA-256 `7D557358...`)
- `tests/evidencias/m6_platform_accessibility/setor5_abismo_raizes.png` (1,039,773 bytes | SHA-256 `22123208...`)
- `tests/evidencias/m6_platform_accessibility/setor6_costelas_monumentais.png` (982,336 bytes | SHA-256 `CFC74304...`)
- `tests/evidencias/m6_platform_accessibility/setor7_ponte_vertebras.png` (997,616 bytes | SHA-256 `4FA37321...`)
- `tests/evidencias/m6_platform_accessibility/setor8_abobada_ecos.png` (944,140 bytes | SHA-256 `04D6E289...`)

#### M6 PLATFORM FIX02 (`tests/evidencias/m6_platform_fix02/` — 6 arquivos)
- `tests/evidencias/m6_platform_fix02/01_setor1_aren_ida_terreno.png` (1,051,517 bytes | SHA-256 `6C0965DA...`)
- `tests/evidencias/m6_platform_fix02/02_setor1_aren_transicao_descida.png` (1,070,542 bytes | SHA-256 `14FB157C...`)
- `tests/evidencias/m6_platform_fix02/03_setor1_aren_retorno_degrau.png` (1,089,708 bytes | SHA-256 `365B8D76...`)
- `tests/evidencias/m6_platform_fix02/04_setor1_aren_retorno_salto.png` (1,043,518 bytes | SHA-256 `8D2F7098...`)
- `tests/evidencias/m6_platform_fix02/05_setor1_vista_ampla_pos_remocao.png` (1,050,801 bytes | SHA-256 `3AE9E3E2...`)
- `tests/evidencias/m6_platform_fix02/painel_m6_platform_fix02.png` (3,688,416 bytes | SHA-256 `D9487BAA...`)

---

## 4. Exclusões Expressas e Justificativa de Blindagem

Os seguintes arquivos presentes na árvore de trabalho **NÃO SERÃO ADICIONADOS AO ÍNDICE GIT NEM COMITADOS**:

| Arquivo / Diretório | Status no Repositório | Motivo da Exclusão / Blindagem |
| :--- | :---: | :--- |
| `tests/m6_auditoria_final_visual_capture.gd` | Untracked | Ferramenta temporária de auditoria integrada; não versionada. |
| `tests/evidencias/m6_auditoria_final/` | Untracked | Capturas redundantes geradas na auditoria final; evidências dos marcos estão em m6b3, m6_platform_accessibility e m6_platform_fix02. |
| `project.godot` | Modificado localmente | Arquivo protegido canônico. Não deve ser alterado em marcos de fase. |
| `ROADMAP.md` | Modificado localmente | Planejamento de alto nível; atualizações de roadmap são geridas à parte. |
| `docs/PLANEJAMENTO_ATAQUE_AEREO_AREN.md` | Modificado localmente | Pertence a escopo futuro de combate/mecânica aérea. |
| `scripts/abbey/abbot_conclusion.gd` | Modificado localmente | Pertence ao marco da Abadia (M5), congelado. |
| `scripts/player/knight_visual.gd` | Modificado localmente | Pertence ao marco visual do jogador (M5-H), congelado. |
| `tests/VALIDACAO_M5_H_DASH_VFX.md` | Modificado localmente | Relatório de validação de marco anterior. |
| `tests/VALIDACAO_RECOMPENSAS_BOSSES.md` | Modificado localmente | Relatório de validação de marco anterior. |
| `tests/abbot_cinematic_test.gd` | Modificado localmente | Suíte de teste da cinemática do Abade (M5). |
| `tests/dash_vfx_test.gd` | Modificado localmente | Suíte de teste de VFX do dash (M5-H). |
| `The Art of the Pixel.jpg` (+ `.import`) | Untracked | Material de referência artística externo ao pacote de código. |
| `The Siege and the Sandfox...` (+ `.import`) | Untracked | Material de referência artística externo ao pacote de código. |
| `assets/art/m5g/abbot_fix02.png.import` | Untracked | Artefato temporário de marco anterior. |
| `tests/MANIFESTO_CANDIDATA_M5_H_SAVE.md` | Untracked | Documento histórico de marcos passados. |
| `tests/MANIFESTO_COMMIT_M6_A_M6_B1.md` | Untracked | Documento histórico de marcos passados. |
| `tests/RESULTADO_CONSOLIDACAO_M5_E_F_G.md` | Untracked | Documento histórico de marcos passados. |
| `tests/TRANSICAO_CODEX_ANTIGRAVITY.md` | Untracked | Documento histórico de transição. |
| `tests/VALIDACAO_CANDIDATA_M5_H_SAVE.md` | Untracked | Documento histórico de marcos passados. |
| `tests/VALIDACAO_COMMIT_M6_A_M6_B1.md` | Untracked | Documento histórico de marcos passados. |
| `tests/VALIDACAO_COMMIT_M6_B2.md` | Untracked | Documento histórico de marcos passados. |
| `tests/evidencias/candidata-m5/` | Untracked | Evidências de marcos anteriores. |
| `tests/evidencias/dash_vfx/` | Untracked | Evidências de marcos anteriores. |
| `tests/evidencias/m3d/` | Untracked | Evidências de marcos anteriores. |
| `tests/evidencias/m5-aspect/` | Untracked | Evidências de marcos anteriores. |
| `tests/evidencias/m5_e_lote09*` | Untracked | Evidências de marcos anteriores. |
| `tests/evidencias/m5g*` | Untracked | Evidências de marcos anteriores. |
| `tests/evidencias/m5h*` | Untracked | Evidências de marcos anteriores. |
| `tests/evidencias/m6a/` | Untracked | Evidências de marcos anteriores. |
| `tests/evidencias/m6a_fix03/` | Untracked | Evidências de marcos anteriores. |
| `tests/evidencias/m6b1/` | Untracked | Evidências de marcos anteriores. |
| `tests/evidencias/m6b1_fix01/` | Untracked | Evidências de marcos anteriores. |
| `tests/evidencias/m6b2/` | Untracked | Evidências de marcos anteriores. |
| `tests/evidencias/recompensas/` | Untracked | Evidências de marcos anteriores. |
| `*.uid` | Untracked | Arquivos internos efêmeros de indexação do Godot. |

---

## 5. Procedimento de Consolidação Autorizado (Quando Aprovado)

Quando o responsável emitir a autorização expressa, o comando de staging seletivo deverá adicionar rigorosamente e exclusivamente os 67 arquivos mapeados neste manifesto:

```powershell
# 1. Staging cirúrgico exclusivo dos 54 componentes M6-B3 + PLATFORM FIXES
git add scenes/forest/sector_07.tscn `
        scenes/forest/sector_08.tscn `
        assets/art/m6a/forest_sector7_bg.png `
        assets/art/m6a/forest_sector7_bg.png.import `
        assets/art/m6a/forest_sector8_bg.png `
        assets/art/m6a/forest_sector8_bg.png.import `
        assets/art/m6a/PROVENANCE.md `
        scripts/forest/forest_layout.gd `
        scripts/forest/forest_sector.gd `
        scripts/forest/forest_art.gd `
        scripts/forest/forest_demo.gd `
        tests/m6_b1_expansion_test.gd `
        tests/m6_b2_expansion_test.gd `
        tests/m6_b3_expansion_test.gd `
        tests/m6_b3_visual_capture.gd `
        tests/m6_platform_accessibility_test.gd `
        tests/m6_platform_accessibility_capture.gd `
        tests/m6_platform_fix02_visual_capture.gd `
        tests/VALIDACAO_M6_B3.md `
        tests/VALIDACAO_M6_PLATFORM_ACCESSIBILITY_FIX01.md `
        tests/VALIDACAO_M6_PLATFORM_FIX02.md `
        tests/MANIFESTO_COMMIT_M6_B3_PLATFORM_FIXES.md `
        tests/VALIDACAO_FINAL_M6_B3_PLATFORM_FIXES.md `
        tests/evidencias/m6b3/ `
        tests/evidencias/m6_platform_accessibility/ `
        tests/evidencias/m6_platform_fix02/

# 2. Verificação de índice estrito
git status -s

# 3. Commit local atômico
git commit -m "feat(forest): conclui setores 7 e 8, calibra plataformas aereas e desobstrui setor 1"
```

> [!IMPORTANT]
> **REAFIRMAÇÃO:** Os comandos acima são meramente documentais e descritivos.
> Não foram executados e aguardam ordem direta do usuário.
