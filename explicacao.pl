% ============================================
% MOTIVO/3
% ============================================
% Descrição: Gera justificativa técnica formatada explicando por que uma pessoa
%            tem direito a um benefício específico. Inclui valores calculados.
%
% Parâmetros:
%   - P: átomo identificando a pessoa
%   - Beneficio: átomo representando o benefício
%   - Motivo: átomo contendo a justificativa formatada (saída)
%
% Comportamento:
%   - Cada benefício tem sua própria cláusula
%   - Calcula valores relevantes (RPC, RPCA, SM)
%   - Formata mensagem com format/2
%   - Inclui valores numéricos para transparência
%
% Formatos de mensagem:
%   - bolsa_basica: "RPCA=X <= 0.5*SM(Y) "
%   - bolsa_idoso: "idoso e RPC=X <= 1.0*SM (Y)"
%   - auxilio_desemprego: "desempregado e RPC=X <= 1.2*SM (Y)"
%   - auxilio_creche: "familia com crianca pequena e RPC=X <= 1.2*SM (Y)"
%   - bonus_monoparental: "familia monoparental"
%
% Uso:
%   - Transparência para beneficiários
%   - Auditoria de decisões
%   - Debugging de elegibilidade
%
% Exemplos de uso:
%   ?- motivo(joao, bolsa_idoso, M).
%   M = 'idoso e RPC=800.00 <= 1.0*SM (1000.00)'.
%

motivo(P, bolsa_basica, Motivo) :-
    familia_de(P, FAM),
    renda_per_capita_ajustada(FAM, RPCA),
    salario_minimo(SM),
    limite_patrimonio(bolsa_basica, K),
    patrimonio_familia(FAM, PF),
    format(atom(Motivo), 'RPCA=~2f <= 0.5*SM (~2f) e patrimonio familia (~2f) < limite patrimonio para bolsa basica (K (~2f) * SM (~2f))', [RPCA, SM, PF, K, SM])
    .

motivo(P, bolsa_idoso, Motivo) :-
    familia_de(P, FAM),
    renda_per_capita(FAM, RPC),
    salario_minimo(SM),
    limite_patrimonio(bolsa_idoso, K),
    patrimonio_familia(FAM, PF),
    format(atom(Motivo), 'idoso, RPCA=~2f <= 1.0*SM (~2f) e patrimonio familia (~2f) < limite patrimonio para bolso idoso (K (~2f) * SM (~2f))', [RPC, SM, PF, K, SM])
    .

motivo(P, auxilio_desemprego, Motivo) :-
    familia_de(P, FAM),
    renda_per_capita(FAM, RPC),
    salario_minimo(SM),
    limite_patrimonio(auxilio_desemprego, K),
    patrimonio_familia(FAM, PF),
    format(atom(Motivo), 'desempregado, RPC=~2f <= 1.2*SM (~2f) e patrimonio familia (~2f) < limite patrimonio para auxilio desemprego (K (~2f) * SM (~2f))', [RPC, SM, PF, K, SM])
    .

motivo(P, auxilio_creche, Motivo) :-
    familia_de(P, FAM),
    renda_per_capita(FAM, RPC),
    salario_minimo(SM),
    limite_patrimonio(auxilio_creche, K),
    patrimonio_familia(FAM, PF),
    format(atom(Motivo), 'familia com crianca pequena, RPC=~2f <= 1.2*SM (~2f) e patrimonio familia (~2f) < limite patrimonio para auxilio creche (K (~2f) * SM (~2f))', [RPC, SM, PF, K, SM])
    .

motivo(P, bonus_monoparental, Motivo) :-
    familia_de(P, FAM),
    salario_minimo(SM),
    limite_patrimonio(bonus_monoparental, K),
    patrimonio_familia(FAM, PF),
    format(atom(Motivo), 'familia monoparental e patrimonio familia (~2f) < limite patrimonio para auxilio creche (K (~2f) * SM (~2f))', [PF, K, SM])
    .

% ============================================
% ELEGIBILIDADE/3
% ============================================
% Descrição: Gera relatório completo de elegibilidade de uma pessoa, incluindo
%            todos os benefícios aos quais tem direito e fundamentação detalhada.
%
% Parâmetros:
%   - P: átomo identificando a pessoa
%   - Beneficios: lista ordenada de benefícios (saída)
%   - Fundamentacao: lista de justificativas (saída)
%
% Comportamento:
%   - Coleta todos os benefícios aos quais pessoa tem direito
%   - Remove duplicatas e ordena (sort/2)
%   - Para cada benefício, obtém motivo técnico
%   - Obtém categoria prioritária da pessoa
%   - Formata fundamentação: [categoria_prioritaria | motivos]
%   - Retorna benefícios e fundamentação
%
% Estrutura da fundamentação:
%   - Primeiro elemento: categoria prioritária
%   - Demais elementos: motivos técnicos de cada benefício
%
% Uso:
%   - Relatório completo para beneficiário
%   - Documentação de decisão
%   - Interface com sistema de pagamentos
%
% Exemplos de uso:
%   ?- elegibilidade(joao, B, F).
%   B = [bolsa_idoso, bonus_monoparental],
%   F = ['categoria_prioritaria=idoso',
%        'idoso e RPC=800.00 <= 1.0*SM (1000.00)',
%        'familia monoparental'].
% 

elegibilidade(P, Beneficios, Fundamentacao) :-
    findall(DIREITO, tem_direito(P, DIREITO), Beneficios),
    categoria_mais_alta(P, Cat),
    format(atom(PrioTexto), 'categoria_prioritaria=~w', [Cat]),
    maplist({P}/[V,R]>>motivo(P,V,R), Beneficios, MotivosSaida),
    Fundamentacao = [PrioTexto|MotivosSaida]
    .

% ============================================
% MOTIVOS/2
% ============================================
% Descrição: Gera lista simplificada combinando benefícios e fundamentação em
%            uma única lista. Versão mais compacta de elegibilidade/3.
%
% Parâmetros:
%   - P: átomo identificando a pessoa
%   - Lista: lista combinada de benefícios e fundamentação (saída)
%
% Comportamento:
%   - Obtém benefícios e fundamentação via elegibilidade/3
%   - Concatena ambas as listas com append/3
%   - Retorna lista unificada
%
% Uso:
%   - Visualização rápida
%   - Logging simplificado
%   - Interface textual
%
% Exemplos de uso:
%   ?- motivos(joao, L).
%   L = [bolsa_idoso, bonus_monoparental,
%        'categoria_prioritaria=idoso',
%        'idoso e RPC=800.00 <= 1.0*SM (1000.00)',
%        'familia monoparental'].
%
motivos(P, Lista) :-
    elegibilidade(P, BEN, FUN),
    append(BEN, FUN, Lista)
    .