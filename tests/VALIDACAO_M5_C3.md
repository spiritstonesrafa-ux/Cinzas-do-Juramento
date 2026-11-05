# M5-C3 — distribuição em andamento

> **Atualização posterior:** o responsável determinou o encerramento administrativo do M5-C3 com ressalvas e aprovou critérios por função. As classificações e resultados abaixo são históricos e não foram convertidos em PASS. Consulte [o registro da decisão](ENCERRAMENTO_ADMINISTRATIVO_M5_C3.md).

**Estado: implementação parcial; não homologada e ainda não pronta para aceite técnico.** Os encontros foram adicionados, mas a regressão de jornada falhou e a justiça e travessia integral com ameaças ativas ainda não foram demonstradas. Não se declara ausência de softlock nem de dano inevitável. M5-D e M6 não foram iniciados.

## Baseline e preservação

Branch `main`, HEAD inicial `cda7e40b689e4e7197d2eccfb53e9fbd357032d0`. Índice vazio. `project.godot` já estava modificado; SHA-256 antes e depois `63fddfb499d59cd3ae9b5b70d7d4a8816ccfd8586486c6cfcc3023733bcdcec9`. Os 14 arquivos não rastreados anteriores foram inventariados por hash, sem alteração intencional. M5-A/B/C1/C2 estavam nos quatro commits anteriores. Fontes: layout e cenas reais da Abadia, `docs/PLANEJAMENTO_CAPITULO_02.md` e o planejamento histórico externo, relatórios dos marcos anteriores. O planejamento original propunha 14.400 px; M5-B homologou geometria diferente e prevalece sobre esse orçamento inicial.

## Inventário e proposta implementada

Coordenadas são locais, em pixels, com y na superfície. Entradas a x=48 e largura−48; saídas nas bordas. As superfícies e tetos exatos vêm de `AbbeyChapterLayout`; nenhum foi alterado. Setores 4, 5 e 9 têm tetos baixos; a ponte 8 tem três vãos. O setor 2 tem rota opcional elevada e o setor 6 contém as instâncias homologadas de Monge `(388,300)` e Prensa `(588,300)`. Não há nova ameaça no Átrio, reservado à recepção. A tabela descreve a distribuição atual, não comprova equilíbrio ou visual.

| Setor | Geometria, entradas e checkpoint | Ameaças existentes e novas (posição local) | Ritmo pretendido |
|---|---|---|---|
| 1 Átrio dos Votos | largura 1024, chão 268–300; início seguro | nenhuma | descanso introdutório |
| 2 Claustro Fraturado | largura 1280, escadaria 156–300, rota opcional; CP `(1120,228)` | Monge novo `(580,180)` | primeiro combate isolado |
| 3 Escadaria dos Contrapesos | largura 1216, piso 588→252; CP `(1178,252)` | Pêndulo `(340,516)` | primeiro mecanismo isolado |
| 4 Dormitório das Vigílias | largura 1216, piso 252→444 e tetos | Acólito `(550,324)` | introdução à distância |
| 5 Cisternas Votivas | largura 1344, piso 300→516→444 e tetos; CP `(1302,444)` | Comporta `(780,492)`; Acólito `(950,516)` | padrões consecutivos; combinação a validar |
| 6 Galeria dos Turíbulos | largura 1280, piso 300, plataformas 276 | Monge `(388,300)` e Prensa `(588,300)` já existentes; Jato `(850,300)` | alternância de padrões |
| 7 Fundição dos Sinos | largura 1472, cotas 276–348; CP `(1426,348)` | Vigia `(410,300)`; Pêndulo `(690,348)`; Monge `(1080,276)` | introdução do Vigia e alternância |
| 8 Ponte dos Penitentes | largura 1216, cotas 284–316, três vãos | Penitente `(550,300)`; Comporta `(850,300)` | introdução do Penitente; travessia a validar |
| 9 Arquivo dos Juramentos | largura 1344, piso 444→228 e tetos; CP `(1296,228)` | Acólito `(510,372)`; Jato `(800,300)` | posicionamento em subida |
| 10 Jardim Suspenso | largura 1216, cotas 252–324 | Penitente `(450,252)`; Pêndulo `(850,324)` | alternância |
| 11 Campanário Exterior | largura 1280, piso 612→252; CP `(1242.5,252)` | Vigia `(420,516)`; Comporta `(850,372)` | padrões conhecidos em subida |
| 12 Coro das Correntes | largura 1408, cotas 228–300; CP `(1168,300)`, trecho final preservado | Monge `(525,228)` | preparação final |

Novas instâncias: 3 Monges, 3 Acólitos, 2 Penitentes, 2 Vigias; 3 Pêndulos, 3 Comportas e 2 Jatos. Somando o piloto: 11 inimigos e 9 perigos. A Prensa é contada uma só vez. As contagens não medem dificuldade. Primeiras exposições pretendidas: Monge S2, Pêndulo S3, Acólito S4, Comporta S5, Prensa e Jato S6, Vigia S7, Penitente S8. A primeira exposição da Prensa ocorre no piloto ao lado do Monge existente e requer avaliação real. Não se afirma que encontros combinados nem a progressão já estejam aprovados.

As instâncias são filhas da sala residente e usam as cenas homologadas. A vida é registrada ao sair e restaurada ao voltar na mesma vida, de modo semelhante ao piloto; morte/queda limpa os estados e reinicia encontros. Seus processos são desativados durante a transição. O teste ainda não prova todos os casos de projéteis, destruição de referências e retorno durante combate.

## Resultados realizados

- Importação/inicialização Godot 4.7.2: concluídas, com erro de leitura dos certificados do sistema; editor sem permissão para gravar as preferências do perfil. Inicialização isolada registrou 1 aviso ObjectDB.
- `tests/m5_c3_distribution_test.gd`: **157/157**. Carregamento de cada sala via troca direta, suporte geométrico das posições, afastamento horizontal das entradas e CP, 45 quadros físicos parados em cada entrada em ambos os sentidos, ativação física de sete CPs seguida de morte por dano induzido e respawn, rearme, e espada real contra uma instância de cada arquétipo. Para os golpes o inimigo foi colocado em recuperação por fixture; não prova um combate completo. Esta suíte registrou aviso de 4 objetos ObjectDB ao encerrar; origem e relação com histórico não determinadas.
- Regressão aprovada: M0 14, M1 36, M2 59, chefe 59, chefe avançado 152, vitória 59, piloto M5-A 357, estrutura M5-B 105, M5-C1 41/46/116/78, M5-C2 115/239, continuidade gráfica 118 e estabilidade de teto 7. As suítes são sobrepostas e não devem ser somadas como verificações independentes. Algumas suítes gráficas/estrutura registraram aviso ObjectDB.
- **Regressão de jornada `abbey_chapter_test.gd`: falhou**, saída 1, 1.808 linhas PASS e 491 ocorrências FAIL no registro. A primeira falha de navegação contínua ocorreu no setor 8, com falhas posteriores em percurso, retorno e provas físicas. O teste de medição foi concebido para isolar ameaças, mas seu isolador anterior só desativa as instâncias do piloto; as novas permanecem ativas. Não se concluiu quanto das falhas decorre dessa diferença de fixture e quanto revela problemas reais. O teste anterior não foi modificado. Em cópia externa do teste, alterada apenas para desativar também as novas ameaças na medição estrutural, passaram 2.299/2.299 verificações com percurso de **17.360,4069 px**, diferença de aproximadamente 0,013 px em relação aos 17.360,42 históricos. Essa cópia confirma geometria e navegação isoladas, não a jornada com ameaças ativas; a falha do teste original permanece registrada.
- Ensaio gráfico automatizado com viewport 3840×2160, GPU RTX 2060 SUPER, 30 s, setores 2/7/11, vida restaurada continuamente por fixture: 1.780 quadros, média 59,32 FPS, p95 17,098 ms, máximo 171,966 ms, máximo 97 nós/1.701 objetos. Inclui trocas; não discrimina picos por transição, não mede todas as condições solicitadas e não substitui jogo na TCL. Aviso de 3 objetos ObjectDB ao encerrar. A ressalva histórica de sete `RefCounted` continua sem origem conclusiva; não foi estabelecida equivalência ou ausência de vazamento novo.

## Pendências para conclusão

Investigar as falhas de S8 em diante com ameaças ativas, demonstrar ida e volta físicas completas, tempos e estratégias legítimas para todos os encontros e combinações inclusive inimigo+inimigo, reavaliar posições em degraus/vãos, validar sem interrupções o respawn em encontros e o ciclo de projéteis, avaliar carregamento/descarga em ciclos longos e ObjectDB, capturar e inspecionar as quatro resoluções e ampliar benchmark (combate, projéteis, retorno e respawn). O teste automatizado não demonstrou a segurança das saídas ou das trajetórias; afastamento horizontal por si só não a garante. Não há homologação manual nova.

## Checklist de playtest posterior

Abrir `scenes/abbey/abbey_chapter.tscn` na Godot 4.7.2 e usar F6; F7 reinicia a Abadia, F5 abre o Capítulo 1. Para cada setor da tabela, marcar **PASSOU / FALHOU / NÃO TESTADO**: entrada e retorno seguros; posições legíveis; avisos; combate/esquiva e recuperação; nenhuma colisão inevitável; avanço e retorno; morte/respawn no CP aplicável; câmera, visual e fluidez. Ao fim, avaliar progressão, variedade, pausas e preparação para o chefe. Este checklist é para depois da resolução da regressão, não uma homologação presumida.

Evidências locais: `C:/Users/ovohe/.codex/visualizations/2026/11/03/01a19f0a-ee96-7412-bd99-7c6152fadd40/m5c3-20261104-01/`, incluindo `baseline.json`, `inventory.log`, `distribution-4.log`, `regression-results.json`, logs individuais e `bench.log`. Nenhum staging, commit ou push foi realizado.

## Atualização FIX01

A falha em S8 foi reproduzida. A jornada ativa passou de ida e volta com um controlador que espera os ataques das armadilhas. A classificação permanece **FIX01 BLOQUEADO** pelas verificações de integração ainda pendentes. Consulte [o relatório FIX01](VALIDACAO_M5_C3_FIX01.md) para os resultados atuais. Os resultados acima são históricos.

## Atualização FIX02

A jornada ativa voltou a passar e o ciclo de vida passou 104 verificações. O aceite segue bloqueado pela cobertura incompleta de justiça individual e colisões combinadas. Consulte [o relatório FIX02](VALIDACAO_M5_C3_FIX02.md).
