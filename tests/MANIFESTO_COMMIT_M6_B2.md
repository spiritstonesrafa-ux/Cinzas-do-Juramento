# MANIFESTO SELETIVO DE CONSOLIDAÇÃO GIT — M6-B2
## EXPANSÃO DA FLORESTA DOS OSSOS (SETORES 5 E 6)

**Projeto:** `C:\PROJETOS\CINZAS DO JURAMENTO`
**Branch:** `main` | **HEAD:** `a326176db337bbad6fe663a5efce1e63178e9e36`
**Data:** 07/11/2026
**Total de Arquivos Selecionados:** 30

---

## TABELA GERAL DO MANIFESTO

| # | Caminho Relativo | Cat | Marco | Estado Git | SHA-256 | Justificativa |
|---|---|---|---|---|---|---|
| 1 | `scenes/forest/sector_05.tscn` | A | M6-B2 | Novo | `A1ADE1D5CBBF86FDB575A11F170D5929B7C28A7A3476CBC7A5BC305EA81D742A` | Cena modular do Setor 5 (Passagem das Raízes Profundas) |
| 2 | `scenes/forest/sector_06.tscn` | A | M6-B2 | Novo | `EE729BB0B144F4B10E2A959F4AF8845BEBEEA79A1BC7E8EBD6453D1BF983EEA0` | Cena modular do Setor 6 (Galeria dos Ossos Antigos) |
| 3 | `scripts/forest/forest_art.gd` | A | M6-B2 | Modificado | `369B2C265FC635F2D394DF1576B65ADD5EB6A9D627AAC304FADB6EA1DB829671` | Renderizador CanvasItem e paralaxe dos 6 setores com features S5/S6 |
| 4 | `scripts/forest/forest_demo.gd` | A | M6-B2 | Modificado | `2511BEBA96D48C35250F4B6ED40CBAB64E984096DF0378EB88A812332210AD2E` | Controlador de cenas dos 6 setores, transições e checkpoints |
| 5 | `scripts/forest/forest_layout.gd` | A | M6-B2 | Modificado | `B92278AC6DC5E7E46DF52E3D56FAA25FD87E5FE3D9E1BAE40DEEC067D29ABC80` | Topografia, origens, geometrias e limiares dos 6 setores |
| 6 | `scripts/forest/forest_sector.gd` | A | M6-B2 | Modificado | `B55F83CE1F67A5A4663E7F99230452135E789D5C0ABB94589DAB79FC4A553764` | Corpos estáticos expandido para 6 setores (@export_range(0, 5, 1)) |
| 7 | `assets/art/m6a/forest_sector5_bg.png` | B | M6-B2 | Novo | `6DE8B50A0F6819C177DBD73674354F520F23F9FE885F7C9EC25DE94C3402CF35` | Panorama noturno distante do Setor 5 (1774 × 887, RGB) |
| 8 | `assets/art/m6a/forest_sector5_bg.png.import` | B | M6-B2 | Novo | `D505D2BD804077D7602FF1298DEAAE1C0E2C9A355536E13B4AA0D62323CB2A87` | Metadados de importação Godot 4.7.2 do fundo do Setor 5 |
| 9 | `assets/art/m6a/forest_sector6_bg.png` | B | M6-B2 | Novo | `D952058C2164CBA15EAAD54E0E7DA9B83524B4AC7AAC5BB2BAF4458BA8D136A8` | Panorama noturno distante do Setor 6 (1774 × 887, RGB) |
| 10 | `assets/art/m6a/forest_sector6_bg.png.import` | B | M6-B2 | Novo | `025A9A101376BCFF7C64CB4BA135A27BF631F7AAAA8956BED8CD391369E08F29` | Metadados de importação Godot 4.7.2 do fundo do Setor 6 |
| 11 | `tests/m6_b1_expansion_test.gd` | C | M6-B2/Regressão | Modificado | `2126203686AE4D3073FD2F821A948CCDDB282DBF26F331F7AF6CAD468ED22E74` | Regressão M6-B1 adaptada com contagem flexível (>= 4) |
| 12 | `tests/m6_b2_expansion_test.gd` | C | M6-B2 | Novo | `517F5B06C530071434CDC3ECC57996A621F27DA3C6549AF950669868066F2CF9` | Suíte de testes dos 6 setores (46 verificações aprovadas) |
| 13 | `tests/m6_b2_visual_capture.gd` | C | M6-B2 | Novo | `26A4CF4345C11221B23508676AF5BDAEF86C70E30637F7D887D9EB8ED36895B2` | Script oficial de captura visual na GPU RTX 2060 SUPER |
| 14 | `ROADMAP.md` | D | M6-B2 | Modificado (Patch) | `2F5EE1F34A7AFB495C03AE129B97886A41FEE9ACD6FB05F51E2B0D3623B5C355` | Atualização de status: M6-B2 homologado e M6-B3 pendente |
| 15 | `assets/art/m6a/PROVENANCE.md` | D | M6-B2 | Modificado | `8DA86DFCAFECEDE4703089BF3643E2A8DA171C8E8E82B2C583F987FD9B8FB3A4` | Documentação aditiva de proveniência dos fundos 5 e 6 |
| 16 | `tests/VALIDACAO_M6_B2.md` | D | M6-B2 | Novo | `F88FB7914EF12CDDD2E17F0906D7A48DCBD8005E7757C8543656EE4CC7324D94` | Relatório técnico de validação da expansão dos setores 5 e 6 |
| 17 | `tests/evidencias/m6b2/setor3_referencia.png` | E | M6-B2 | Novo | `65752C6DFB610E3EB8086A350E583E28E126B28924141F3A890DDEAB5A02D20A` | Referência visual preservada do Setor 3 |
| 18 | `tests/evidencias/m6b2/setor4_referencia.png` | E | M6-B2 | Novo | `C95C9F423CA2D644D27086A427B7CA3547E212295B566301BDC9BBC66A02A0F1` | Referência visual preservada do Setor 4 |
| 19 | `tests/evidencias/m6b2/setor5_01_entrada.png` | E | M6-B2 | Novo | `67DA1174B7B316E4FAC861DB41A8234B0757E36CF81C7F73E66258D11041B69D` | Captura da entrada do Setor 5 |
| 20 | `tests/evidencias/m6b2/setor5_02_meio.png` | E | M6-B2 | Novo | `DAD75F208AB72DC29669C5DADF5F1DFBF876E593A8F708C03692B8B208467F3C` | Captura da bacia e raízes gigantes no Setor 5 |
| 21 | `tests/evidencias/m6b2/setor5_03_plataformas.png` | E | M6-B2 | Novo | `11756FCAEEF5B421D01C65C0C4DDE1819CD79839B6A4DC79B454EFC92312302E` | Captura das plataformas e ramos elevados no Setor 5 |
| 22 | `tests/evidencias/m6b2/setor5_04_saida.png` | E | M6-B2 | Novo | `8AF52E8B5E92A4504A4F7DFE2D53ADFE3708401E14A6F0337708B068D53594FF` | Captura do terraço de saída do Setor 5 |
| 23 | `tests/evidencias/m6b2/setor6_01_entrada.png` | E | M6-B2 | Novo | `903149E0898E38D0B59895C065AF23F039E4F6842EC4320786772849521574C5` | Captura da entrada do Setor 6 |
| 24 | `tests/evidencias/m6b2/setor6_02_meio.png` | E | M6-B2 | Novo | `71F9DB42F072C178EC10586175A94E95E24077504E34D9827B1C83D51ACCE217` | Captura do patamar de vértebras e ruínas no Setor 6 |
| 25 | `tests/evidencias/m6b2/setor6_03_estruturas_osseas.png` | E | M6-B2 | Novo | `D1875FC481B0EBD5039C836D6EF3818CD64414A61A236FC8F3CDCF6653A80E08` | Captura do Grande Ossuário e arcadas no Setor 6 |
| 26 | `tests/evidencias/m6b2/setor6_04_saida.png` | E | M6-B2 | Novo | `EBAB7FDE62BA0BEB69F47E1B26D1A98796EFFEB6E4C324D9E07392AAC0DA40F8` | Captura da área final sólida e margem leste no Setor 6 |
| 27 | `tests/evidencias/m6b2/aren_travessia_obstaculo.png` | E | M6-B2 | Novo | `743DDD94AC8948771260FB5AB6839D5BC67C9A7AF56A9E503A0D9FD43F14F22C` | Captura de Aren transpondo o abismo de raízes do Setor 5 |
| 28 | `tests/evidencias/m6b2/transicao_setor5_para_6.png` | E | M6-B2 | Novo | `00B0561F73C77006CCC611EB4D86EF1F8FDAF9288229CFD15C819279C2266EB5` | Captura da transição nivelada entre Setor 5 e Setor 6 |
| 29 | `tests/evidencias/m6b2/comparacao_setores_4_5_6.png` | E | M6-B2 | Novo | `E67F412A28C7E9446D0D655B3BEF0EE7B145DF1582B80C5F39DAF6FC0555D510` | Painel comparativo vertical dos setores 4, 5 e 6 |
| 30 | `tests/MANIFESTO_COMMIT_M6_B2.md` | D | M6-B2 | Novo | `[DOCUMENTO DE AUDITORIA DESTA OPERAÇÃO]` | Manifesto seletivo e inventário criptográfico de M6-B2 |

---

## EXCLUSÕES EXPLÍCITAS (ARQUIVOS NÃO RELACIONADOS PERMANECEM NA WORKING TREE)

1. `project.godot`: Arquivo de configuração de projeto protegido (SHA-256 mantido: `63FDDFB4...`).
2. Os outros 14 arquivos protegidos do projeto (`The Art of the Pixel.jpg`, `The Siege and the Sandfox...`, etc.).
3. `cinzas_abbey_progress_v1.json`: Save pessoal do usuário (215 bytes, SHA-256 `4DB32167...`).
4. `docs/PLANEJAMENTO_ATAQUE_AEREO_AREN.md`: Planejamento residual de M5-H mantido na working tree.
5. `scripts/abbey/abbot_conclusion.gd`: Alteração residual de quebra de linha fora de escopo.
6. `scripts/player/knight_visual.gd`: Formatação residual de espaços fora de escopo.
7. `tests/VALIDACAO_M5_H_DASH_VFX.md`: Documentação de validação de M5-H.
8. `tests/VALIDACAO_RECOMPENSAS_BOSSES.md`: Documentação de validação de recompensas.
9. `tests/abbot_cinematic_test.gd`: Quebra de linha residual fora de escopo.
10. `tests/dash_vfx_test.gd`: Espaços residuais fora de escopo.
11. Diretórios e arquivos temporários de teste (`tests/evidencias/m5*`, `tests/evidencias/candidata*`).
