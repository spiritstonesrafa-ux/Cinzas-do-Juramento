# MANIFESTO DE COMMIT — M6-B4 + FIX01
## Floresta dos Ossos — Setores 9 e 10, Conclusão Estrutural da Fase 3 e Futura Arena do Cervo

> [!NOTE]
> **DOCUMENTO OFICIAL DE MANIFESTO SELETIVO**
> Este manifesto detalha os 35 arquivos candidatos para a consolidação atômica e seletiva do marco **M6-B4 + FIX01** em um único commit local na branch `main`.
> Nenhuma alteração alheia ao marco foi incluída.

---

## 1. Identificação da Consolidação

- **Projeto:** `C:\PROJETOS\CINZAS DO JURAMENTO`
- **Engine:** Godot 4.7.2 (`Godot_v4.7.2-stable_win64_console.exe`)
- **Branch:** `main`
- **HEAD Anterior:** `388dc848ac71d8d8e0294139ead7e78e066fbbab`
- **Mensagem Autorizada do Commit:**
  `feat(forest): consolida M6-B4 e FIX01 setores 9 e 10`
- **Save Pessoal:** `cinzas_abbey_progress_v1.json` (215 bytes, SHA-256 `4DB32167...`) — **Preservado e Intocado**.

---

## 2. Escopo Consolidado

1. **M6-B4 (Expansão dos Setores 9 e 10):**
   - **Setor 9 (Ravina das Sombras Fósseis):** relevo cavernoso profundo, desfiladeiro com vão de 46 px, escadarias e plataformas aéreas sobre costelas monumentais, fundo panorâmico autoral (`forest_sector9_bg.png`).
   - **Setor 10 (Clareira da Bruma Espectral):** encerramento estrutural da Fase 3 com 10 setores, chão plano contínuo em y=260 de 960 px para futura arena do chefe **Cervo Espectral**, Altar da Bruma Espectral, abóbada ogival de costelas com poleiros táticos, Pórtico Rúnico do Juramento e fundo panorâmico autoral (`forest_sector10_bg.png`).
   - Conexão e nivelamento bidirecional contínuo: Setor 8 $\leftrightarrow$ Setor 9 $\leftrightarrow$ Setor 10.
2. **M6-B4 FIX01 (Auditoria e Correção de Conclusão Prematura):**
   - Remoção de `completed = true` ao entrar no Setor 10 em `scripts/forest/forest_demo.gd`.
   - Exploração livre da clareira/arena sem encerramento antecipado nem falsas telas de vitória.
   - Retorno físico bidirecional por caminhada validado (Setor 10 $\to$ Setor 9 $\to$ Setor 8).
   - Suíte de testes M6-B4 expandida para 77 verificações (100% PASS).
   - Evidências GPU dedicadas demonstrando ausência de mensagens de vitória e retorno à esquerda.

---

## 3. Manifesto dos 35 Arquivos Candidatos

### 3.1. Cenas e Composição Godot (2 arquivos)

| Caminho Relativo | Tamanho | SHA-256 | Função no Escopo |
| :--- | :---: | :--- | :--- |
| `scenes/forest/sector_09.tscn` | 369 B | `CBC33D3707FB5A62E9D8796B567A14AC02850A04EBDDC3025FC6FD91B68C7BDC` | Cena do Setor 9 (Ravina das Sombras Fósseis). |
| `scenes/forest/sector_10.tscn` | 369 B | `94F5EFEEB0BA44B6D1CA7D96CB17A8BFD5526C277EE1E3419125727CB35B5EFE` | Cena do Setor 10 (Clareira da Bruma Espectral / Arena). |

### 3.2. Arte e Proveniência (5 arquivos)

| Caminho Relativo | Tamanho | SHA-256 | Função no Escopo |
| :--- | :---: | :--- | :--- |
| `assets/art/m6a/forest_sector9_bg.png` | 1.97 MB | `97054B611467FF63EA832FE321B5192A6B8E6B725F5860235B3F27F919023282` | Fundo panorâmico distante do Setor 9 (1774×887 px). |
| `assets/art/m6a/forest_sector9_bg.png.import` | 970 B | `CBDB46EEA5AA511932B597BAC7B9AB57ABD2F4494BB8EA92918B6B5957D2CAF5` | Metadados de importação Godot do fundo do Setor 9. |
| `assets/art/m6a/forest_sector10_bg.png` | 2.15 MB | `D642F821301712BD329CE879475C295E0620E2D787E3EB18459975EDF81AA182` | Fundo panorâmico distante do Setor 10 (1774×887 px). |
| `assets/art/m6a/forest_sector10_bg.png.import` | 972 B | `E757623D62611FBC95A0A664475C52D1720E6FAD9232B6857D8C31155CA394F2` | Metadados de importação Godot do fundo do Setor 10. |
| `assets/art/m6a/PROVENANCE.md` | 8.50 KB | `6754DB4B6C7E7E2F4FEF9F6C41E8CA7D179C167B00D2853D4DF74436EDA118A1` | Registro das seções 12 e 13 descrevendo os novos fundos. |

### 3.3. Scripts de Gameplay e Level Design da Floresta (4 arquivos)

| Caminho Relativo | Tamanho | SHA-256 | Função no Escopo |
| :--- | :---: | :--- | :--- |
| `scripts/forest/forest_art.gd` | 29.78 KB | `342B10A8D724AEE8755BC9FEB1135B80FFCCB8DDE752A88739CA98FBC1FE8EB5` | Paletas atmosféricas e camadas de arte dos Setores 9 e 10. |
| `scripts/forest/forest_demo.gd` | 7.58 KB | `48FA2CBB26E4168BD44DE1B7300C2ED16DDB146E3A2DB3759343FCFAF726ADBE` | Suporte aos 10 setores, subhints narrativos e FIX01 (`completed = false`). |
| `scripts/forest/forest_layout.gd` | 12.98 KB | `A8A933BF8C5A3A790C2BF0658761148D1662A82767A50880AC07D4BA40F59812` | Geometria, plataformas, vãos, origens e nomes dos 10 setores. |
| `scripts/forest/forest_sector.gd` | 1.19 KB | `C163C69076BB10FEE7FA02F0527A7531186F99B151F1D5A888066D59318C2BDF` | Geração física de colisão dos Setores 9 e 10 via ForestLayout. |

### 3.4. Suítes de Testes Automatizados (3 arquivos)

| Caminho Relativo | Tamanho | SHA-256 | Função no Escopo |
| :--- | :---: | :--- | :--- |
| `tests/m6_b3_expansion_test.gd` | 20.21 KB | `8DE28F5450C56177291B08A964D80BC5D52D85B4701A5DA6128E03EBB0F065E7` | Compatibilidade de asserções com $\ge 8$ setores (59 PASS). |
| `tests/m6_b4_expansion_test.gd` | 26.60 KB | `C6D4EA14D24FB07C36E46F6DF741843F97DAE4A4F52862C5846831B54BAE77D0` | Suíte dedicada com 77 verificações físicas e de retorno (100% PASS). |
| `tests/m6_b4_visual_capture.gd` | 8.35 KB | `6DE226A38FD4BBED26756538D3881923DD865685E9215203C99AFC3FFA5ABABA` | Script gerador de evidências gráficas GPU de M6-B4 e FIX01. |

### 3.5. Documentação Técnica e de Consolidação (4 arquivos)

| Caminho Relativo | Tamanho | SHA-256 | Função no Escopo |
| :--- | :---: | :--- | :--- |
| `tests/VALIDACAO_M6_B4.md` | 11.61 KB | `77E3BF07B1D05C1A9ADEBA088D81B4C0356DD73D46444E4A3A3AD54F4D97D44E` | Relatório de validação inicial da expansão dos setores 9 e 10. |
| `tests/VALIDACAO_M6_B4_FIX01.md` | 15.60 KB | `C44BE6E4A7925917CDBC2B28B2664426AE490403AD2FCFE91701B294FCF92CF7` | Relatório de auditoria de preservação e correção FIX01. |
| `tests/MANIFESTO_COMMIT_M6_B4_FIX01.md` | *(este arquivo)* | *(calculado pós-escrita)* | Manifesto seletivo oficial dos 35 arquivos da consolidação. |
| `tests/VALIDACAO_COMMIT_M6_B4_FIX01.md` | *(criado a seguir)* | *(calculado pós-escrita)* | Relatório integrado de auditoria pré-commit e validação da candidata. |

### 3.6. Evidências Gráficas GPU — `tests/evidencias/m6b4/` (17 arquivos)

| Caminho Relativo | Tamanho | SHA-256 | Função no Escopo |
| :--- | :---: | :--- | :--- |
| `tests/evidencias/m6b4/setor8_referencia.png` | 1.05 MB | `3A0D3EF3A859D202510BC5AFF455ECDD8336203F5468BCCA78867E778B372DF3` | Enquadramento de referência do Setor 8 aprovado. |
| `tests/evidencias/m6b4/setor9_01_entrada.png` | 1.01 MB | `F8A2D9F3C887C990D880F757575C9FF97DDC0C10730A98814AC8095E65ED0A9D` | Entrada e patamar oeste do Setor 9. |
| `tests/evidencias/m6b4/setor9_02_ravina_meio.png` | 1.04 MB | `5F43C1F21DCCCB83D0833BFDDA3D8DDFCAEF45453B859F27D7A39A487B4BB4DF` | Relevo acidentado e descida para a ravina. |
| `tests/evidencias/m6b4/setor9_03_abismo_sombras.png` | 1.02 MB | `5F850019C7A841431A369FD6B80334E869C64C9CF92A766A827E149E4AE48273` | Aren diante do abismo central e costelas gigantes. |
| `tests/evidencias/m6b4/setor9_04_plataformas_aereas.png` | 877 KB | `CA44D6237E481799DDB59078E8D8E92FD5AA68F4E041C1C6E49A2C6E1E9516BB` | Aren sobre o arco fóssil suspenso do Setor 9. |
| `tests/evidencias/m6b4/setor9_05_terraco_saida.png` | 1.02 MB | `012C201FB0CF36EDC5DCF36FBB45C4A8E52A556E0A1BE79B341D2894D00AD8BC` | Terraço leste de saída do Setor 9. |
| `tests/evidencias/m6b4/setor10_01_entrada_arena.png` | 1.08 MB | `29D016ABF5548B95BF91AD75D7CA2404D91FE000B498B78CFC0E0C162BD17ADE` | Entrada da Clareira da Bruma Espectral (Setor 10). |
| `tests/evidencias/m6b4/setor10_02_visao_geral_arena.png` | 1.08 MB | `F401695A559CD4D0CA207A2BC77F7A65B4882DB7BB37B8489041684328FE0761` | Aren percorrendo o piso monumental da futura arena. |
| `tests/evidencias/m6b4/setor10_03_altar_bruma_espectral.png` | 1.08 MB | `DB99C894C2663CE8E54D7184340CBEF2928AC12B72C2ECCEC6B18EBD8AAA4F3D` | Altar Corrompido com chama espectral turquesa. |
| `tests/evidencias/m6b4/setor10_04_abobada_costelas_poleiro.png` | 947 KB | `C309D9883E82A0D1394FDCEF1C366FEB9724BA1E31EF73AACEFD05258710CC98` | Poleiro superior tático na abóbada de costelas titânicas. |
| `tests/evidencias/m6b4/setor10_05_portico_do_juramento.png` | 1.08 MB | `022680464CCA34EC95850039797A026CC2CC429B7E97219DD4EAAD9D955C93B3` | Pórtico ancestral com runas no extremo leste da fase. |
| `tests/evidencias/m6b4/transicao_setor8_para_9.png` | 1.05 MB | `8E39FE3FB732D3F10468D1AF562D0B88CDABD69A8C4B97232C16747D6D5DD607` | Transição contínua nivelada entre Setor 8 e 9 (y=240). |
| `tests/evidencias/m6b4/transicao_setor9_para_10.png` | 1.02 MB | `39C0C7A15A4B6810D523BD46C2C35CEC6CE7DB70A569A5A0DEC41336414EF4A3` | Transição contínua nivelada entre Setor 9 e 10 (y=260). |
| `tests/evidencias/m6b4/aren_salto_abismo_s9.png` | 944 KB | `DC384BBE22F7C459CF1D49969876224B2ECE6F9D74B0F8341BCD694F60E9AE86` | Salto de Aren sobre o vão central de 46 px do Setor 9. |
| `tests/evidencias/m6b4/setor10_sem_vitoria_prematura.png` | 1.08 MB | `0681D0B1DA6BFD8BFAE96CDC720F952E8B3A8933FC3A8ED79CC95240BE7E3A14` | FIX01: Aren em movimento livre na arena sem tela de vitória. |
| `tests/evidencias/m6b4/setor10_retorno_setor9.png` | 1.07 MB | `FBF6739F2BA21A187CD2099B60701BE1DDF4B842285C831CA0F341F276F8D97F` | FIX01: Retorno bidirecional físico livre do Setor 10 para o 9. |
| `tests/evidencias/m6b4/painel_m6_b4.png` | 1.96 MB | `AC7E807ACE0A02EE8AB4190826EF39607BEA62349DB9DA9296C6F7F9C2A5B0BC` | Painel visual panorâmico de homologação de M6-B4. |

---

## 4. Alterações Locais Externas Excluídas do Staging

Todas as alterações locais históricas pertencentes a outros escopos foram explicitamente preservadas na working tree e excluídas deste staging:
- Arquivos de combate de M1 e M5.
- Imagens de referência de arte (`The Art of the Pixel.jpg`, `The Siege and the Sandfox...jpg`).
- Arquivos `.import` e evidências de marcos anteriores (M3D, M5-Aspect, M5G, M6B1, M6B2, M6B3, etc.).
- Relatórios e manifestos de marcos consolidados anteriores.
- `project.godot`: mantido intocado e idêntico ao HEAD canônico.
- Save pessoal: intocado e excluído de qualquer versionamento.
