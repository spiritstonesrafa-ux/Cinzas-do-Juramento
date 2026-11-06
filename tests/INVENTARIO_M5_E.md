# Inventário completo — proposta seletiva M5-E

Retrato da pasta de trabalho após a preparação documental. O índice estava vazio. Candidato não significa autorização de staging; conferir novamente antes de qualquer operação. Entradas `M` já eram rastreadas e `??` ainda não são rastreadas. Os arquivos `.uid` acompanham os scripts de origem; metadados `.import` das imagens são opcionais e devem ser revisados com as imagens. Nenhum arquivo abaixo foi preparado nesta etapa.

Os 15 protegidos coincidem com o baseline local de hashes; `project.godot` está modificado em relação ao HEAD, embora coincida com esse baseline protegido. As referências JPG e os `.import` M3-D são preexistentes, não candidatos. O ROADMAP possuía alteração local antes do M5-E; revisar trechos e preservar a alteração anterior. `chapter.gd` e `chapter_sector.gd` concentram contribuições M5-E de diversos lotes. O histórico de relatórios reflete estágios intermediários, não estados finais.

A validação foi realizada com o `project.godot` local: o futuro commit que o exclua precisa de uma verificação de integração com a configuração do HEAD, sem mexer no protegido, e de decisão do responsável para qualquer diferença relevante. As capturas dos lotes 01–08 referenciadas fora do projeto não entram automaticamente no commit; logs `.godot/` são cache ignorado.

Proposta: incluir os grupos de implementação, documentação e testes válidos; incluir evidências do lote 09 se desejadas, com seus metadados necessários. Não incluir grupo protegido ou amostra exploratória. `README.md` e `ROADMAP.md` devem ser revisados por conteúdo e `ROADMAP.md` também por trechos, dada a edição preexistente. Testar a versão candidata sem adicionar arquivos protegidos antes de pedir autorização de commit.

## Entradas por categoria

### Protegidos e preexistentes — excluir (15)

- `??` `The Art of the Pixel.jpg`
- `??` `The Art of the Pixel.jpg.import`
- `??` `The Siege and the Sandfox _ Le metroidvania en 2D de Cardboard Sword et PLAION sortira le 20 mai sur PC.jpg`
- `??` `The Siege and the Sandfox _ Le metroidvania en 2D de Cardboard Sword et PLAION sortira le 20 mai sur PC.jpg.import`
- `M` `project.godot`
- `??` `tests/evidencias/m3d/fix03-after-sector1.png.import`
- `??` `tests/evidencias/m3d/fix03-after-sector2.png.import`
- `??` `tests/evidencias/m3d/fix03-after-sector3.png.import`
- `??` `tests/evidencias/m3d/fix03-after-sector4.png.import`
- `??` `tests/evidencias/m3d/fix03-after-sector5.png.import`
- `??` `tests/evidencias/m3d/fix03-after-sector6.png.import`
- `??` `tests/evidencias/m3d/fix03-attack--1-8.png.import`
- `??` `tests/evidencias/m3d/fix03-attack-1-8.png.import`
- `??` `tests/evidencias/m3d/fix03-detail-cp1-active.png.import`
- `??` `tests/evidencias/m3d/fix03-detail-cp2-active.png.import`

### Candidatos de implementação e dependências (20)

- `M` `scripts/abbey/chapter.gd`
- `M` `scripts/abbey/chapter_sector.gd`
- `??` `scripts/abbey/m5e_discoveries.gd`
- `??` `scripts/abbey/m5e_discoveries.gd.uid`
- `??` `scripts/abbey/m5e_garden_overlook.gd`
- `??` `scripts/abbey/m5e_garden_overlook.gd.uid`
- `??` `scripts/abbey/m5e_names_relief.gd`
- `??` `scripts/abbey/m5e_names_relief.gd.uid`
- `??` `scripts/abbey/m5e_o1_chapel.gd`
- `??` `scripts/abbey/m5e_o1_chapel.gd.uid`
- `??` `scripts/abbey/m5e_service_passage.gd`
- `??` `scripts/abbey/m5e_service_passage.gd.uid`
- `??` `scripts/abbey/m5e_shortcuts.gd`
- `??` `scripts/abbey/m5e_shortcuts.gd.uid`
- `??` `scripts/abbey/m5e_silent_bell_gallery.gd`
- `??` `scripts/abbey/m5e_silent_bell_gallery.gd.uid`
- `??` `scripts/abbey/m5e_stair_cistern_annex.gd`
- `??` `scripts/abbey/m5e_stair_cistern_annex.gd.uid`
- `??` `scripts/abbey/m5e_unsigned_record_gallery.gd`
- `??` `scripts/abbey/m5e_unsigned_record_gallery.gd.uid`

### Candidatos de documentação e planejamento (15)

- `M` `README.md`
- `M` `ROADMAP.md`
- `??` `docs/PLANEJAMENTO_M5_E.md`
- `??` `docs/PLANEJAMENTO_M5_F.md`
- `??` `tests/ENCERRAMENTO_M5_E.md`
- `??` `tests/INVENTARIO_M5_E.md`
- `??` `tests/VALIDACAO_M5_E_LOTE01.md`
- `??` `tests/VALIDACAO_M5_E_LOTE02.md`
- `??` `tests/VALIDACAO_M5_E_LOTE03.md`
- `??` `tests/VALIDACAO_M5_E_LOTE04.md`
- `??` `tests/VALIDACAO_M5_E_LOTE05.md`
- `??` `tests/VALIDACAO_M5_E_LOTE06.md`
- `??` `tests/VALIDACAO_M5_E_LOTE07.md`
- `??` `tests/VALIDACAO_M5_E_LOTE08.md`
- `??` `tests/VALIDACAO_M5_E_LOTE09.md`

### Candidatos de testes (46)

- `??` `tests/m5_e_lote01_test.gd`
- `??` `tests/m5_e_lote01_test.gd.uid`
- `??` `tests/m5_e_lote02_test.gd`
- `??` `tests/m5_e_lote02_test.gd.uid`
- `??` `tests/m5_e_lote03_o1_test.gd`
- `??` `tests/m5_e_lote03_o1_test.gd.uid`
- `??` `tests/m5_e_lote04_geometry_audit.gd`
- `??` `tests/m5_e_lote04_geometry_audit.gd.uid`
- `??` `tests/m5_e_lote04_o1_fixture.gd`
- `??` `tests/m5_e_lote04_o1_fixture.gd.uid`
- `??` `tests/m5_e_lote04_o1_journey.gd`
- `??` `tests/m5_e_lote04_o1_journey.gd.uid`
- `??` `tests/m5_e_lote04_other_fixtures.gd`
- `??` `tests/m5_e_lote04_other_fixtures.gd.uid`
- `??` `tests/m5_e_lote05_clearance_fixture.gd`
- `??` `tests/m5_e_lote05_clearance_fixture.gd.uid`
- `??` `tests/m5_e_lote05_o1_test.gd`
- `??` `tests/m5_e_lote05_o1_test.gd.uid`
- `??` `tests/m5_e_lote06_o1_clearance.gd`
- `??` `tests/m5_e_lote06_o1_clearance.gd.uid`
- `??` `tests/m5_e_lote06_o1_journey.gd`
- `??` `tests/m5_e_lote06_o1_journey.gd.uid`
- `??` `tests/m5_e_lote06_o1_metric.gd`
- `??` `tests/m5_e_lote06_o1_metric.gd.uid`
- `??` `tests/m5_e_lote07_o4_test.gd`
- `??` `tests/m5_e_lote07_o4_test.gd.uid`
- `??` `tests/m5_e_lote07_o5_test.gd`
- `??` `tests/m5_e_lote07_o5_test.gd.uid`
- `??` `tests/m5_e_lote07_o6_test.gd`
- `??` `tests/m5_e_lote07_o6_test.gd.uid`
- `??` `tests/m5_e_lote08_o2_test.gd`
- `??` `tests/m5_e_lote08_o2_test.gd.uid`
- `??` `tests/m5_e_lote08_o3_test.gd`
- `??` `tests/m5_e_lote08_o3_test.gd.uid`
- `??` `tests/m5_e_lote08_o4_test.gd`
- `??` `tests/m5_e_lote08_o4_test.gd.uid`
- `??` `tests/m5_e_lote08_o5_test.gd`
- `??` `tests/m5_e_lote08_o5_test.gd.uid`
- `??` `tests/m5_e_lote08_o6_test.gd`
- `??` `tests/m5_e_lote08_o6_test.gd.uid`
- `??` `tests/m5_e_lote08_short_jump_test.gd`
- `??` `tests/m5_e_lote08_short_jump_test.gd.uid`
- `??` `tests/m5_e_lote09_segment_journey.gd`
- `??` `tests/m5_e_lote09_segment_journey.gd.uid`
- `??` `tests/m5_e_lote09_shortcut_fixture.gd`
- `??` `tests/m5_e_lote09_shortcut_fixture.gd.uid`

### Candidatos de evidências visuais e metadados (24)

- `??` `tests/evidencias/m5_e_lote09_A1_1280x720.png`
- `??` `tests/evidencias/m5_e_lote09_A1_1280x720.png.import`
- `??` `tests/evidencias/m5_e_lote09_A1_1920x1080.png`
- `??` `tests/evidencias/m5_e_lote09_A1_1920x1080.png.import`
- `??` `tests/evidencias/m5_e_lote09_A1_2560x1440.png`
- `??` `tests/evidencias/m5_e_lote09_A1_2560x1440.png.import`
- `??` `tests/evidencias/m5_e_lote09_A1_3840x2160.png`
- `??` `tests/evidencias/m5_e_lote09_A1_3840x2160.png.import`
- `??` `tests/evidencias/m5_e_lote09_A2_1280x720.png`
- `??` `tests/evidencias/m5_e_lote09_A2_1280x720.png.import`
- `??` `tests/evidencias/m5_e_lote09_A2_1920x1080.png`
- `??` `tests/evidencias/m5_e_lote09_A2_1920x1080.png.import`
- `??` `tests/evidencias/m5_e_lote09_A2_2560x1440.png`
- `??` `tests/evidencias/m5_e_lote09_A2_2560x1440.png.import`
- `??` `tests/evidencias/m5_e_lote09_A2_3840x2160.png`
- `??` `tests/evidencias/m5_e_lote09_A2_3840x2160.png.import`
- `??` `tests/evidencias/m5_e_lote09_A3_1280x720.png`
- `??` `tests/evidencias/m5_e_lote09_A3_1280x720.png.import`
- `??` `tests/evidencias/m5_e_lote09_A3_1920x1080.png`
- `??` `tests/evidencias/m5_e_lote09_A3_1920x1080.png.import`
- `??` `tests/evidencias/m5_e_lote09_A3_2560x1440.png`
- `??` `tests/evidencias/m5_e_lote09_A3_2560x1440.png.import`
- `??` `tests/evidencias/m5_e_lote09_A3_3840x2160.png`
- `??` `tests/evidencias/m5_e_lote09_A3_3840x2160.png.import`

### Exploratório — excluir da proposta (2)

- `??` `tests/m5_e_lote09_journey.gd`
- `??` `tests/m5_e_lote09_journey.gd.uid`

### Não classificado — revisar antes de qualquer commit (0)

- Nenhuma.

Total: **122 entradas** (inclui este inventário). Nenhuma operação de staging, commit, push ou deploy foi executada.
