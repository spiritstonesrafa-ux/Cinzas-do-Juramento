# M5-F — checklist para playtest final do responsável

> **Homologação posterior M5-F:** o responsável informou “playtest ok” e homologou o M5-F com as ressalvas documentadas. O mínimo físico global de 12.227,52 px continua não comprovado e não bloqueante; o modelo horizontal não é distância física. M5-C3, ObjectDB e o pico histórico de 183,878 ms permanecem registrados. Esta informação não representa nova execução automatizada.

**Estado:** o responsável informou “playtest ok” e homologou M5-F com ressalvas; os itens abaixo permanecem sem marcação individual, pois resultados item a item não foram informados. A revisão do critério de distância foi aprovada; a referência original de 12.227,52 px permanece não comprovada e não bloqueante. Não considerar itens marcados sem execução humana. À época deste playtest o Abade e o dash ainda não estavam implementados; eles não integraram a homologação M5-F. O M5-G agora possui implementação experimental em validação; ataque aéreo continua não implementado.

## Preparação

- Abrir o projeto na Godot 4.7.2. Para testar a Abadia, selecionar `scenes/abbey/abbey_chapter.tscn` e executar a cena com **F6**; F7 reinicia a Abadia e restaura a sessão inicial.
- Controles: A/D ou setas movem, Espaço salta, J usa espada; E interage com as portas dos atalhos. A progressão atual é temporária na sessão.
- Jogar preferencialmente na tela/resolução habitual e, se disponível, conferir 4K real. Estas instruções descrevem a versão testada antes do M5-G; para o chefe experimental, consulte o relatório M5-G.

## Lista de verificação

- [ ] Percorrer os 12 setores até o fim estrutural e retornar; observar entradas, saídas, plataformas, câmera, HUD e ameaças sem saltos de tela ou bloqueios que impeçam a progressão.
- [ ] Usar movimento, salto e espada; confirmar que inimigos e perigos sejam visíveis, legíveis e respondam ao combate de forma justa.
- [ ] Ativar os sete checkpoints ao longo da jornada; verificar ao menos uma morte com reaparecimento seguro e uma queda viva, observando a regra de vida existente. As sete ativações e respawns já possuem evidência automatizada, mas o jogador pode repetir outras tentativas se desejar.
- [ ] Encontrar as seis inscrições e explorar O1–O6; confirmar sinalização, leitura, acesso, retorno e retomada da rota principal.
- [ ] Antes de concluir cada setor avançado, verificar que o atalho correspondente está fechado. Após sair normalmente do setor avançado e voltar, usar E para abri-lo e percorrê-lo nos dois sentidos: S4↔S3, S8↔S7 e S11↔S9. No terceiro par, visitar primeiro S10.
- [ ] Após abrir atalhos, morrer e testar uma queda; confirmar que continuam abertos na mesma sessão. Reiniciar com F7 e confirmar que uma nova sessão começa com atalhos fechados.
- [ ] Observar legibilidade de Aren, inimigos, perigos, pistas e HUD durante movimento e salto; se houver 4K, verificar escala e enquadramento. A [folha de contato do FIX01](evidencias/m5_f_fix01_contato.png) ajuda a localizar os setores, mas não substitui o jogo.
- [ ] Confirmar F5 no projeto principal após o teste, verificando que o Capítulo 1 abre. Registrar qualquer erro, local e sequência de ações reproduzível.

## Resultado do responsável

Resultado geral informado pelo responsável: **“playtest ok”**. Nenhuma observação ou resultado individual adicional foi fornecido; a Abadia continua sem conclusão definitiva até o desenvolvimento e a homologação do Abade.
