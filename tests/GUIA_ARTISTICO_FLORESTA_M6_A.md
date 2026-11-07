# Floresta dos Ossos — transferência artística M6-A

## Estado e proteção

Em 06/11/2026 o responsável informou a aprovação visual da reconstrução dos setores 1 e 2. Esta aprovação é informada pelo responsável; o relatório histórico `tests/VALIDACAO_M6_A_CODEX_ART_RECOVERY.md` reflete a situação anterior e não foi reescrito. A implementação M6-A permanece **local, fora do commit**. O HEAD inspecionado é `e90dfc0c2de67023ea2d3bc7979a145a2cad033d`; o identificador fornecido no pedido é seu prefixo.

Os **118 caminhos** de arte, cenas, scripts, importações, evidências e testes foram conferidos individualmente com SHA-256: nenhum divergiu do inventário [INVENTARIO_M6_A_EXCLUIDO_M5_H.md](INVENTARIO_M6_A_EXCLUIDO_M5_H.md), que contém a lista completa e os hashes. A aprovação visual se refere à reconstrução atual, não implica aprovação de todas as variantes históricas ou dos futuros setores. Copiar os recursos e dependências antes de transferir; um checkout limpo do HEAD sozinho **não contém** esses arquivos locais. Não importar cegamente capturas antigas como arte final.

## Arquitetura que existe

| Arquivo | Responsabilidade efetiva |
| --- | --- |
| `scenes/forest/forest_pilots.tscn` | Cena de demonstração, Aren, câmera, HUD, contêiner de salas e checkpoints. |
| `scripts/forest/forest_demo.gd` | Instancia uma sala por vez, troca nos limites, acompanha Aren e controla o piloto. Desbloqueia dash em memória para o piloto; isto não prova nem altera progressão normal. |
| `scenes/forest/sector_01.tscn`, `scenes/forest/sector_02.tscn` | Cada cena contém `ForestSector` e filho `Art` com o mesmo `sector_id`, respectivamente 0 e 1. |
| `scripts/forest/forest_layout.gd` | Fonte única dos retângulos físicos, origens, nomes e pontos de entrada. |
| `scripts/forest/forest_sector.gd` | Constrói `StaticBody2D` e `RectangleShape2D` para cada retângulo de `ForestLayout.surfaces()`. |
| `scripts/forest/forest_art.gd` | Desenha fundo, árvores, solo, raízes, altar, detalhes e esporos com CanvasItem; não é um TileMap nem usa shader próprio. |
| `scenes/player/knight.tscn`, `scenes/ui/health_hud.tscn`, `scenes/props/respawn_checkpoint.tscn` | Dependências já existentes do piloto: personagem, vida e checkpoint. Reutilizar sem modificá-las para uma tarefa de arte. |

As salas têm `ROOM_SIZE = (960, 420)` e origens `(0, 0)` e `(1200, 0)`. Coordenadas dos retângulos e da arte são **locais à sala**; ao instanciar, `forest_demo.gd` desloca a sala para sua origem. O piloto tem somente dois IDs: `@export_range(0, 1, 1)`, dois caminhos, dois nomes, e `surfaces()` trata qualquer ID diferente de 0 como setor 2. Uma expansão não deve apenas acrescentar um `sector_id = 2`: requer projeto explícito e autorizado de dados, cenas, transições e limites. Nesta transferência não se alteram esses sistemas.

## Arte e dependências de verdade

| Recurso | Uso atual |
| --- | --- |
| `assets/art/m6a/forest_sector1_bg.png` | Fundo distante do setor 1, em `BACKGROUNDS[0]`. |
| `assets/art/m6a/forest_bosque_codex.png` | Fundo distante aprovado do setor 2, em `BACKGROUNDS[1]`. |
| `assets/art/m6a/forest_ground_codex.png` | Textura independente de terra, raízes e musgo para superfícies. |
| `assets/art/m6a/forest_root_codex.png` | Raiz independente com transparência, usada sob ramos e nas bases dos troncos; sem colisão. |
| `assets/art/m6a/forest_materials.png` | Atlas usado para cogumelos `(256,128,64,64)`, espículas `(448,128,64,64)` e véu `(576,128,64,128)` no abismo. |
| `assets/art/m6a/forest_props.png` | Atlas: árvore `(0,0,240,480)` e altar `(640,0,280,360)`. |
| `assets/art/m6a/forest_stag_crest.png` | Brasão usado no HUD da cena piloto. |
| `assets/art/m6a/forest_sector2_bg.png` | Recurso anterior preservado: **não** é o fundo atualmente selecionado para o setor 2. |

Preservar os `.import` e `.gd.uid` correspondentes como parte do estado local; caches gerados em `.godot` não são recursos-fonte. `assets/art/m6a/PROVENANCE.md` descreve o FIX03, mas é histórico: sua indicação do fundo do setor 2 e suas descrições dos ladrilhos não substituem o código da recuperação. Algumas constantes de atlas (`REG_PLATFORM_MID`, caps, `REG_ELEVATED_BRANCH`, arcos e chifres) existem sem serem usadas no desenho aprovado. `_draw_foreground_framing()` também existe, mas não é chamada por `_draw()`. Não presumir que essas partes estejam ativas.

Os atlas podem fornecer cogumelos e elementos ósseos discretos; tronco, altar e raiz são reutilizáveis com critério. Para ambientes novos, produzir variações próprias de fundo, silhueta, prop e material quando a repetição ficar aparente; não repetir a árvore monumental em intervalos óbvios nem reutilizar o altar como marco de todas as salas. Novas imagens devem ser independentes e sem interface, personagem ou plataformas pintadas no fundo; elementos sobrepostos precisam de alfa limpo. Não copiar assets de referências externas.

## Construção e alinhamento

`ForestLayout.surfaces(id)` retorna os retângulos principais seguidos dos elevados. O setor instancia um corpo por retângulo: corpo em `rect.position`, retângulo de colisão com `shape.size = rect.size` e centro `rect.size * 0.5`; camada 1, máscara `2 | 256`. `ForestArt._draw_playfield_surfaces()` percorre os **mesmos** retângulos. Arte não cria colisão e raízes/decoração não devem sugerir uma plataforma sólida inexistente.

Exemplo efetivamente existente, setor 1: `Rect2(190, 246, 70, 12)` é um galho com colisão de 70 × 12; a superfície desenhada começa no mesmo topo `y=246`. Para retângulos de altura até 16, `_draw_organic_surface(rect)` desenha o material e uma saia `forest_root_codex.png` em `(x-2, y+3, largura+4, 24)`. A saia é apenas decorativa e pode exceder a caixa física. Outro exemplo: `Rect2(0,300,260,120)` é solo principal; os retângulos seguintes mudam de altura conforme `SECTOR_1_MAIN`.

O terreno é ancorado no **x mundial local ao setor**, não reiniciado a cada colisor: período `384.0`, `scale_factor = ORGANIC_GROUND.get_width() / 384.0`, recorte da fonte a partir de `y=130`. `_draw_organic_surface()` recorta a área visível e desenha fundo `#121a14` quando a profundidade excede a textura. Inspecionar mudanças de altura, bordas verticais e a repetição após 384 unidades: a recuperação reduziu emendas, mas não garante encaixe perfeito. A camada das raízes conecta visualmente troncos e solo; não desloque a linha do piso para encaixar uma textura.

No setor 2, o vão de `x=200` a `260` possui 60 unidades e faz parte do desafio existente; há outro entre `650` e `704`. O altar é desenhado em `(812,196)`, tamanho `(76,52)`, sobre a estrutura física em `Rect2(810,246,80,42)`. Preserve a distinção entre o desenho, a caixa sólida e o espaço de travessia. Não modificar geometria, dificuldade, movimento, dash ou câmera durante a transferência artística.

## Escala, camadas e paralaxe

O projeto local inspecionado usa viewport lógico **320 × 180**, janela inicial 960 × 540, `canvas_items`, escala inteira, filtro de textura padrão nearest e GL Compatibility em `project.godot`. `ForestArt._ready()` fixa também nearest e `z_index=-1`; Aren está em `z_index=2` e o `ForestHUD` é `CanvasLayer` 2. A apresentação depende da configuração real de cada cópia; `project.godot` é protegido e não deve ser modificado para produzir uma captura.

A câmera segue Aren com antecipação horizontal de 24 unidades, limites locais x=160..800 e y=90..330, e posição arredondada. A arte calcula janela visível de 320 × 180 a partir do centro arredondado. No desenho, ordem: panorama, árvores, superfícies, desafio/altar do setor 2, cogumelos e ossos, esporos. O panorama ocupa 480 × 240, com deslocamento por `(0.12, 0.08)` em relação ao centro `(480,210)`; troncos principais ficam fixos no mundo para tocar o chão. Esporos têm deslocamento próprio. Isso é paralaxe desenhada manualmente, não um `Parallax2D` configurado em cena.

Nearest e escala inteira favorecem nitidez, mas não garantem ausência de aliasing ou distorção: o panorama é ajustado ao retângulo de desenho e as raízes são esticadas a destinos específicos. Avalie proporções, suavidade e emendas em movimento em vez de prometer perfeição pixel a pixel. Não aplicar repetição automática de fragmentos recortados no céu nem halos fortes que confundam ameaças.

## Novas entregas para expansão — proposta, não execução

Criar arquivos novos, por exemplo `scenes/forest/sector_03.tscn`, imagens próprias em `assets/art/m6a/` com nomes por setor e capturas em uma pasta de evidências nova. Se forem necessários dados e renderizador compartilhados novos, planejá-los separadamente e compatibilizá-los com a fonte única de geometria; não sobrescrever os dois pilotos. Novos `.gd.uid` e metadados de importação devem acompanhar os novos recursos quando a Godot os gerar. Os nomes e quantidade de setores futuros dependem do planejamento aprovado; não foram criados aqui.

## Capturas reais e validação

1. Trabalhar em **cópia isolada** que inclua os 118 caminhos inventariados e as dependências do HEAD. Selecionar perfil de dados isolado e nunca copiar ou utilizar o save pessoal. Não executar scripts de captura na árvore original: eles escrevem nomes fixos e podem sobrescrever evidências existentes.
2. Abrir a cópia com Godot 4.7.2 e executar `scenes/forest/forest_pilots.tscn` como cena atual (F6). No piloto: A/D, Espaço, Shift e J; F1 alterna ajuda. Percorrer com controles reais ida e volta, inclusive as bordas da tela, plataformas altas, vão e santuário. Observar a câmera acompanhando Aren e registrar trechos em caminhada, salto e dash; incluir estados parado e movimento.
3. Para evidências controladas, `tests/m6_a_visual_capture.gd` instancia a cena real e salva PNGs a partir de `root.get_texture().get_image()` após `RenderingServer.frame_post_draw`; exige renderização gráfica, pois `--headless` ignora capturas. Em uma cópia descartável, pode executar, com os caminhos ajustados à instalação local:

   ```powershell
   $env:APPDATA = 'C:\CAMINHO\PERFIL_ISOLADO_NOVO'
   & 'C:\CAMINHO\Godot_v4.7.2-stable_win64_console.exe' --path 'C:\CAMINHO\COPIA_ISOLADA' --resolution 1280x720 --script res://tests/m6_a_visual_capture.gd
   ```

   O script usa `reset_to` e troca direta de sala para compor as imagens; a captura de dash dispara a entrada. São evidências gráficas reais, **não** prova de travessia contínua. Ele grava em `tests/evidencias/m6a/` dentro da cópia e usa nomes existentes. Confira arquivo, tamanho, imagem e log. Preserve as evidências aprovadas originais.
4. Comparar a reconstrução em `tests/evidencias/m6a_codex_recovery/` com a execução atual, sem exigir enquadramento idêntico. Verificar 320 × 180 lógico e saídas 1280 × 720, 1920 × 1080, 2560 × 1440 e 3840 × 2160, registrando resolução efetiva, proporção, GPU e configuração; capturas estáticas não substituem observação em movimento.
5. Quando houver implementação futura autorizada, validar a navegação física real, colisões, transições e regressões relevantes em perfil isolado. Os resultados anteriores do relatório de recuperação são históricos; não tratá-los como testes desta transferência. A medição anterior de 300 quadros por setor foi breve e não constitui benchmark 4K.

## Checklist de revisão de novos setores

- [ ] Identidade do local distinta, horizonte e iluminação coerentes com os vizinhos; sem troca brusca durante a câmera em movimento.
- [ ] Piso e limites visíveis coincidem com as caixas sólidas; raízes ornamentais não prometem apoio físico.
- [ ] Fundo distante sem Aren, HUD ou plataformas integradas; objetos com alfa sem retângulos, halos ou recortes de vizinhos.
- [ ] Superfícies, troncos e raízes parecem conectados; verificar repetição após 384 unidades, bordas de patamares e encontros de materiais.
- [ ] Aren, inimigos, projéteis e pousos distinguíveis de fungos, bruma e decoração durante deslocamento.
- [ ] Parallax sem saltos, cintilação ou elementos presos à câmera; conferir os dois sentidos e limites de sala.
- [ ] Nitidez e enquadramento avaliados nas quatro saídas, inclusive HUD e escala inteira; documentar eventuais barras ou áreas adicionais.
- [ ] Testar acesso e retorno com os controles reais; manter física e progressão existentes sem alterações não autorizadas.
- [ ] Capturas e logs em destino novo, isolado; nomear resolução, setor, posição e estado de movimento.

## Não modificar

Preservar integralmente os 118 caminhos do inventário aprovado ao realizar esta transferência; em particular `scripts/forest/*`, `scenes/forest/*`, `assets/art/m6a/*`, testes e evidências existentes. Evolução posterior exige autorização e deve preservar versões ou criar arquivos novos. Não editar os scripts, cenas, colisores, checkpoints, personagem, combate ou progressão já homologados para compensar arte.

Os 15 protegidos adicionais são `project.godot`, `The Art of the Pixel.jpg` e seu `.import`, `The Siege and the Sandfox _ Le metroidvania en 2D de Cardboard Sword et PLAION sortira le 20 mai sur PC.jpg` e seu `.import`, mais `tests/evidencias/m3d/fix03-after-sector1.png.import` até `fix03-after-sector6.png.import`, `fix03-attack--1-8.png.import`, `fix03-attack-1-8.png.import`, `fix03-detail-cp1-active.png.import` e `fix03-detail-cp2-active.png.import`. Os 15 hashes foram comparados com o baseline, sem divergência.

Não acessar, copiar ou modificar o save pessoal durante a produção de arte. Nenhuma importação ou captura foi executada nesta auditoria documental; a verificação foi de arquivos, código e hashes. Sem staging, commit, push, deploy ou início de M6-B.
