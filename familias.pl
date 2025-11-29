% ============================================
% RENDA_FAMILIAR/2
% ============================================
% Descrição: Calcula a renda total de uma família somando as rendas individuais
%            de todos os seus membros.
%
% Parâmetros:
%   - F: átomo identificando a família
%   - R: número representando a renda total (saída)
%
% Comportamento:
%   - Coleta todas as rendas individuais dos membros da família
%   - Usa findall/3 para agregar valores
%   - Soma todos os valores com sum_list/2
%   - Retorna renda total
%
% Exemplos de uso:
%   ?- renda_familiar(fam1, R).
%   R = 2500.0.  % soma das rendas de todos os membros
%
renda_familiar(F, R) :- 
    findall(Renda, (membro(F, Pessoa), renda_pessoa(Pessoa, Renda)), Rendas), 
    sum_list(Rendas, R).

% ============================================
% TAMANHO_FAMILIA/2
% ============================================
% Descrição: Conta o número total de membros de uma família.
%
% Parâmetros:
%   - F: átomo identificando a família
%   - N: número inteiro representando o tamanho (saída)
%
% Comportamento:
%   - Coleta todos os membros da família
%   - Usa findall/3 para agregar membros
%   - Conta com length/2
%   - Retorna número de membros
%
% Exemplos de uso:
%   ?- tamanho_familia(fam1, N).
%   N = 4.  % família com 4 membros
%
% tamanho_familia(F, N).
tamanho_familia(F, N) :- 
    findall(Pessoa, membro(F, Pessoa), Pessoas), 
    length(Pessoas, N).

% ============================================
% NUM_DEPENDENTES/2
% ============================================
% Descrição: Conta o número de dependentes em uma família, com limite maximo de 5
%            para fins de desconto. Dependentes são membros que atendem ao
%            predicado dependente/1.
%
% Parametros:
%   - F: atomo identificando a família
%   - N: número inteiro representando o número de dependentes (saída)
%
% Comportamento:
%   - Coleta todos os membros que são dependentes
%   - Conta o número total (N0)
%   - Aplica limite maximo de 5: N = min(5, N0)
%   - Limite evita descontos excessivos
%
% Política:
%   - Máximo de 5 dependentes contam para desconto
%   - Famílias com mais de 5 dependentes têm desconto limitado
%
% Exemplos de uso:
%   ?- num_dependentes(fam1, N).
%   N = 2.  % família com 2 dependentes
%
%   ?- num_dependentes(fam2, N).
%   N = 5.  % família com 7 dependentes, mas limite é 5
%
% num_dependentes(F, N).
num_dependentes(F, N) :- 
    findall(Pessoa, (membro(F, Pessoa), dependente(Pessoa)), DependentesFamilia), 
    length(DependentesFamilia, N0), 
    N is min(5, N0).

% ============================================
% RENDA_PER_CAPITA/2
% ============================================
% Descrição: Calcula a renda per capita bruta da família (renda total dividida
%            pelo número de membros). Não considera ajustes por dependentes.
%
% Parâmetros:
%   - F: átomo identificando a família
%   - RPC: número representando a renda per capita (saída)
%
% Comportamento:
%   - Obtém renda total da família
%   - Obtém tamanho da família
%   - Verifica que família não está vazia (N > 0)
%   - Calcula RPC = R / N
%   - Retorna renda per capita bruta
%
% Uso:
%   - Base para cálculos de elegibilidade
%   - Usado em benefícios que não consideram ajustes
%
% Exemplos de uso:
%   ?- renda_per_capita(fam1, RPC).
%   RPC = 625.0.  % 2500 / 4 = 625
%
% renda_per_capita(F, RPC).
renda_per_capita(F, RPC) :- 
    tamanho_familia(F, Tamanho), 
    renda_familiar(F, Renda), 
    (Tamanho =:= 0 -> RPC is 0; RPC is Renda / Tamanho).

% ============================================
% RENDA_PER_CAPITA_AJUSTADA/2
% ============================================
% Descrição: Calcula a renda per capita ajustada, aplicando desconto por
%            dependentes. Usada para benefícios mais sensíveis à composição familiar.
%
% Parâmetros:
%   - F: átomo identificando a família
%   - RPCA: número representando a renda per capita ajustada (saída)
%
% Comportamento:
%   - Obtém renda per capita bruta
%   - Obtém número de dependentes (limitado a 5)
%   - Obtém taxa de desconto por dependente
%   - Obtém salário minimo
%   - Calcula desconto: ND * Disc * SM
%   - Calcula RPCA = max(0, RPC - desconto)
%   - Garante que RPCA não seja negativa
%
% Fórmula:
%   RPCA = max(0, RPC - num_dependentes * desconto_dependente * salario_minimo)
%
% Política:
%   - Cada dependente reduz a renda per capita ajustada
%   - Reconhece custo adicional de dependentes
%   - Torna elegibilidade mais inclusiva para famílias grandes
%
% Exemplos de uso:
%   ?- renda_per_capita_ajustada(fam1, RPCA).
%   RPCA = 425.0.  % RPC 625 - 2 dependentes * 0.1 * 1000 = 425
%
% renda_per_capita_ajustada(F, RPCA).

renda_per_capita_ajustada(F, RPCA) :- 
    salario_minimo(SalMin), 
    desconto_dependente(DescDep), 
    renda_per_capita(F, RPC),
    num_dependentes(F, NumDependentes),
    RPCA is max(0, RPC - NumDependentes * DescDep * SalMin).

% ============================================
% FAMILIA_DE/2
% ============================================
% Descrição: Predicado auxiliar que obtém a família de uma pessoa. Inverte a
%            relação membro/2 para facilitar consultas.
%
% Parâmetros:
%   - P: átomo identificando a pessoa
%   - F: átomo identificando a família (saída)
%
% Comportamento:
%   - Inverte membro(F, P) para familia_de(P, F)
%   - Facilita leitura e uso em regras de elegibilidade
%
% Exemplos de uso:
%   ?- familia_de(joao, F).
%   F = fam1.
%
% familia_de(P, F).
familia_de(P, F) :- membro(F, P).
