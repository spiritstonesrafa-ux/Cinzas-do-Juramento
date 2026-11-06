# Encerramento M5-E — exploração, segredos e atalhos

**M5-E homologado visual e funcionalmente pelo responsável.** Após o playtest dos três atalhos, o responsável informou “Tudo OK” e aprovou o marco. A aprovação também contempla as seis inscrições e os seis percursos O1–O6 já aprovados. Ela registra a avaliação humana, não uma nova execução automatizada. M5-F permanece em preparação, não homologado.

## Escopo e acesso

Foram entregues seis inscrições nos setores 2, 3, 5, 7, 9 e 10; seis percursos opcionais com acesso e retorno; e três atalhos entre S4↔S3, S8↔S7 e S11↔S9. As pistas reaproveitam a linguagem visual aprovada. Os atalhos são abertos pelo lado avançado após conclusão do trecho obrigatório; os dois setores precisam ter sido visitados e A3 exige primeira visita ao S10. Depois de abertos, permanecem na sessão após morte e queda. F7 reinicia a sessão; não há save em disco. A passagem é fisicamente percorrida, com a troca de sala existente nas extremidades. A trava é lógica e a porta é decorativa, conforme [lote 09](VALIDACAO_M5_E_LOTE09.md).

## Testes e evidências anteriores

- Lote 01: validações do piloto e capturas reais de aproximação, salto e caminhada em quatro resoluções; homologação visual do piloto informada separadamente.
- Lotes 02–08: seis inscrições, desenvolvimento dos ramos e provas físicas de O1–O6; o lote 08 registrou a aprovação humana dos percursos e regressão da entrada intencional (15/15). Relatórios preservam tentativas parciais, resultados e limitações de cada etapa.
- Lote 09: ensaios por atalho a partir da entrada do trecho com ameaças ativas; bloqueio, conclusão, abertura, ida/volta e visita obrigatória ao S10. Teste isolado verificou persistência dos três desbloqueios após dano letal/respawn e queda induzida por posição fora dos limites; esta última não prova uma trajetória manual de queda. Suíte dos seis ramos sem falhas, distribuição 157/157, sete checkpoints testados e jornada principal de 12 setores nos dois sentidos com código 0.
- Doze capturas reais dos corredores, nas quatro resoluções, estão em `tests/evidencias/m5_e_lote09_A{1,2,3}_{1280x720,1920x1080,2560x1440,3840x2160}.png`. Outros quadros estão nos diretórios externos citados nos respectivos relatórios. Logs `.godot/` são locais e ignorados pelo Git. Nenhum teste de engine foi executado nesta etapa documental.

## Medições e limites

As economias físicas observadas foram **246,97 px** (S4↔S3), **185,74 px** (S8↔S7) e **573,50 px** (S11↔S9). A soma aritmética de **1.006,21 px**, superior em 46,21 px à meta histórica de 960 px, deriva de ensaios independentes: não é economia comprovada da jornada completa nem mede o menor caminho. Os 17.360,42 px da espinha são referência histórica e não foram remedidos no lote 09. A referência do planejamento original de caminho mínimo pós-atalhos e a meta de 3.000 px opcionais não foram demonstradas por uma medição integrada equivalente; sua avaliação é prevista no plano M5-F, sem desfazer a homologação concedida.

M5-C3 foi encerrado administrativamente com ressalvas nos sete encontros combinados; a combinação avançada em S11 permanece para revisão posterior sem bloquear o roadmap. O aviso ObjectDB continua histórico e sem causa conclusiva. O pico isolado de **183,878 ms** no M5-D tem causa indeterminada e não é bloqueante por si só. Diagnósticos de certificado e escrita de log no perfil também foram documentados; não se afirma sua resolução.

## Git e proposta de consolidação

O [inventário completo](INVENTARIO_M5_E.md) separa arquivos candidatos, evidências e alterações protegidas ou preexistentes. A proposta é um único commit seletivo futuro com implementação, dependências de código e `.uid`, testes válidos, documentação e as evidências de Lote 09 cuja inclusão for aprovada; a amostra exploratória anterior que falhou não é evidência final. Excluir os 15 arquivos protegidos e quaisquer alterações preexistentes sem autorização. O README e ROADMAP devem ser revisados por conteúdo e por trechos, pois o ROADMAP já tinha edição local anterior.

Há uma dependência aberta: `project.godot` pertence aos 15 protegidos, mas seu conteúdo local difere do HEAD (inclui configuração de janela e serialização de input). Os testes e a aprovação ocorreram no estado local. Um commit que omita esse arquivo não comprova por si só que o checkout limpo tenha apresentação e comportamento equivalentes; verificar a versão candidata com a configuração do HEAD e reportar o resultado antes de autorizar qualquer inclusão, exclusão ou ajuste. Não há autorização para modificá-lo nesta etapa.

Próximo marco: [planejamento M5-F](../docs/PLANEJAMENTO_M5_F.md). Nenhum staging, commit, push ou deploy foi realizado neste encerramento.
