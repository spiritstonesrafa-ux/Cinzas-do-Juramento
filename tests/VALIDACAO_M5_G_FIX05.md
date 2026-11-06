# M5-G FIX05 — apoio, aviso e barra do Abade

> Nota da consolidação: a seleção Git mantém as imagens representativas vinculadas abaixo. As demais capturas históricas das quatro resoluções permanecem locais e não integram o commit.

**Resultado: PARTIAL, aguardando conferência visual em movimento pelo responsável.** As alterações e verificações abaixo foram realizadas; não se declara a homologação do M5-G. O responsável aprovou a identidade visual e considerou aceitável a dificuldade no playtest anterior.

## Apoio no piso

A plataforma da arena tem topo em y=156. O corpo do Abade nasce em y=156 e sua colisão de 48 px termina na origem: o descompasso era visual. O retângulo desenhado terminava em y=1, mas as poses tinham margens inferiores transparentes diferentes; com alfa >= 128, as margens medidas iam de aproximadamente 4,25 a 11,22 px na escala desenhada. A pose de morte tinha uma das maiores margens.

Foram aplicados offsets exclusivamente ao desenho de cada uma das 12 poses e ao rastro do dash. A transição de dano para a pose de derrota usa uma mistura visual curta de 0,20 s, com ambas as poses apoiadas; uma revisita já derrotada abre diretamente na pose final. Não houve alteração de corpo, física, geometria, fonte de dano ou atlas. Os testes calcularam o contato do último pixel com alfa >= 128 em todas as poses, com tolerância de 0,7 px; esse cálculo não substitui avaliação artística de movimento ou de sombras semitransparentes.

Capturas da cena real, com estados preparados como fixture: [parado](evidencias/m5g-fix05/parado_1280x720.png), [corrente](evidencias/m5g-fix05/corrente_1280x720.png), [dash](evidencias/m5g-fix05/dash_1280x720.png), [recuperação](evidencias/m5g-fix05/recuperacao_1280x720.png) e [derrotado](evidencias/m5g-fix05/derrota_1280x720.png). Há também perseguição, dano, transição e preparações na pasta; são estados ajustados para inspeção, não provas de uma luta completa.

## Linha amarela e avisos

A linha mostrada pelo responsável era desenhada no `_draw()` do visual, de (6,-5) a (87,-5), durante WARNING. Essa chamada foi removida sem condição de debug: não é exibida por F6 ou pela execução normal. As poses de preparação, exclamação existente e detalhes violetas do aviso do dash permanecem. Não foi adicionado outro indicador de alcance.

Os avisos de corrente, varredura e dash foram capturados em ambos os sentidos; por exemplo, [varredura à direita](evidencias/m5g-fix05/aviso_p1_lado1.png). A [captura durante combate por controles](evidencias/m5g-fix05/combate-real/aviso_1280x720.png) também não mostra a linha. O teste físico de direção e esquiva registrou **64/64**, incluindo ambas as direções e paredes; ele verifica comportamento, não a percepção humana do aviso. A fonte de dano e o código que calcula o alcance permaneceram idênticos ao FIX04.

## Barra de vida

O modelo é `scripts/boss/boss_hud.gd`, utilizado pelo Guardião: fundo x=62 y=19 de 196×24, moldura x=76 y=32 de 168×6, preenchimento interno 166×4, mesmas cores, fonte, nome centralizado e marcador II. O novo `scripts/ui/abbot_boss_bar.gd` reproduz esses parâmetros sem modificar a implementação do primeiro chefe; não é uma refatoração compartilhada do HUD antigo. A largura do preenchimento acompanha `health/max_health`, limitada entre zero e um. A barra vazia permanece visível após a derrota e na revisita; ao retornar ao setor, ela é ocultada e o título do setor retorna.

Comparação: [Guardião](evidencias/m5g-fix05/guardiao_referencia_1280x720.png) e [Abade](evidencias/m5g-fix05/parado_1280x720.png). Em combate por golpes reais foram observados HP 10, 9, 5, 1 e 0 com proporção coerente; retorno e revisita também passaram. Capturas de cada estado preparado foram produzidas em 1280×720, 1920×1080, 2560×1440 e 3840×2160. A posição da barra está abaixo da vida de Aren e a mensagem de recompensa continua no rodapé. As capturas são evidência das resoluções, não avaliação de desempenho gráfico.

## Regressões e limitações

- Godot 4.7.2: 12 verificações de apoio por alfa, 12 proporções em fixtures e capturas em quatro resoluções passaram.
- Matriz física FIX01: 64/64; combate real com duas fases, vitória sem dash prévio, recompensa e revisita: passou.
- Teste de barra em combate real observou 10, 9, 5, 1, 0, e ocultação no retorno: passou.
- Morte de Aren, CP7 e reentrada; leitura da recompensa em outro processo; revisita com Abade derrotado e retorno: passaram.
- Regressão do primeiro chefe: 59/59.
- Capturas adicionais de luta acionada por controles em quatro resoluções estão em `evidencias/m5g-fix05/combate-real/`. Parte das capturas de cada estado é fixture; não foram examinadas todas as transições quadro a quadro, e a leitura da preparação sem a linha e a naturalidade da queda precisam de playtest humano. Não se afirma que todos os estados possíveis de combate foram provados justos.
- Os diagnósticos históricos de certificados e ObjectDB reapareceram na Godot; nenhuma auditoria histórica foi reaberta.

## Arquivos e segurança

Modificados nesta etapa: `scripts/abbey/abbot_visual.gd`, `scripts/abbey/chapter.gd`; criado `scripts/ui/abbot_boss_bar.gd`, os testes `m5_g_fix05_*.gd`, capturas em `tests/evidencias/m5g-fix05/` e este relatório. As alterações anteriores nesses arquivos foram preservadas. Hashes de `abbot.gd`, `abbot_arena.gd`, `guardian_attack.gd`, cena do Abade, controlador de Aren e atlas coincidiram com a cópia anterior ao FIX05.

Os 15 hashes protegidos coincidiram com o baseline antes e após os testes. Perfis APPDATA isolados foram usados nas execuções; o save pessoal não foi modificado. Branch `main`, HEAD `a10f654f6cc4efcb2c68ede3b3254b2f09ed8d7e`; sem staging, commit, push ou deploy. `git diff --check` não apontou erros, com aviso preexistente de normalização em `project.godot`.

Para playtest direto, no projeto execute `powershell -ExecutionPolicy Bypass -File .\tools\playtest_m5g.ps1 -Cenario Boss`. Confira apoio durante perseguição, golpes, dash e derrota; reconhecimento dos três avisos sem linha; queda e barra em toda a luta. Uma nova execução sem perfil cria outra batalha inédita.
