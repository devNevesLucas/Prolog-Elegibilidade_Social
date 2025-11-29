% ============================================
% E_IDOSO/1, E_DESEMPREGADO/1, E_ATIVO/1, E_ESTUDANTE/1
% ============================================
% Descrição: Predicados auxiliares que verificam se uma pessoa pertence a cada
%            categoria social baseado em seus atributos.
%
% Parâmetros:
%   - P: átomo identificando a pessoa
%
% Comportamento:
%   - e_idoso(P): idade >= 65 anos
%   - e_desempregado(P): ocupacao = desempregado OU fato desempregado(P)
%   - e_ativo(P): ocupacao = formal OU informal
%   - e_estudante(P): ocupacao = estudante
%
% Exemplos de uso:
%   ?- e_idoso(joao).
%   true.  % joao tem 70 anos
%
%   ?- e_desempregado(maria).
%   true.  % maria está desempregada
%
e_idoso(P) :- ocupacao(P, aposentada).
e_desempregado(P) :- ocupacao(P, desempregado).
e_ativo(P) :- (ocupacao(P, formal); ocupacao(P, informal)).
e_estudante(P) :- ocupacao(P, estudante).

% ============================================
% CATEGORIA_DE/2
% ============================================
% Descrição: Mapeia uma pessoa para suas categorias aplicáveis, com regras de
%            precedência para evitar sobreposição indesejada.
%
% Parâmetros:
%   - P: átomo identificando a pessoa
%   - Cat: átomo representando a categoria (saída)
%
% Comportamento:
%   - idoso: se e_idoso(P) (sem restrições)
%   - desempregado: se e_desempregado(P) E NÃO e_idoso(P)
%   - ativo: se e_ativo(P) E NÃO e_idoso(P) E NÃO e_desempregado(P)
%   - estudante: se e_estudante(P) (sem restrições, complementar)
%
% Regras de precedência:
%   1. Idoso tem precedência sobre desempregado e ativo
%   2. Desempregado tem precedência sobre ativo
%   3. Estudante é complementar (pode coexistir)
%
% Exemplos de uso:
%   ?- categoria_de(joao, C).
%   C = idoso.  % joao é idoso (mesmo se desempregado)
%
%   ?- categoria_de(maria, C).
%   C = desempregado ;  % maria é desempregada
%   C = estudante.      % maria também é estudante
%
categoria_de(P, idoso) :- e_idoso(P).
categoria_de(P, desempregado) :- e_desempregado(P), \+ e_idoso(P).
categoria_de(P, ativo) :- e_ativo(P), \+ e_idoso(P), \+ e_desempregado(P).
categoria_de(P, estudante) :- e_estudante(P).

% ============================================
% CATEGORIA_MAIS_ALTA/2
% ============================================
% Descrição: Determina a categoria de maior prioridade aplicável a uma pessoa.
%            Usado para desambiguação quando pessoa tem multiplas categorias.
%
% Parâmetros:
%   - P: átomo identificando a pessoa
%   - Cat: átomo representando a categoria de maior prioridade (saída)
%
% Comportamento:
%   - Coleta todas as categorias aplicáveis à pessoa
%   - Verifica que há pelo menos uma categoria
%   - Mapeia cada categoria para seu nível de prioridade
%   - Encontra o nível maximo
%   - Retorna categoria com nível maximo
%
% Lógica:
%   - Usa findall/3 para coletar categorias
%   - Usa maplist/3 para obter prioridades
%   - Usa max_member/2 para encontrar maximo
%   - Usa member/2 e prioridade/2 para encontrar categoria
%
% Exemplos de uso:
%   ?- categoria_mais_alta(joao, C).
%   C = idoso.  % joao é idoso e desempregado, mas idoso tem prioridade 3
%
%   ?- categoria_mais_alta(maria, C).
%   C = desempregado.  % maria é desempregada (prioridade 2) e estudante (prioridade 0)
%
% categoria_mais_alta(P, Cat).
categoria_mais_alta(P, Cat) :- 
    findall(Categoria, categoria_de(P, Categoria), Categorias), 
    maplist(prioridade, Categorias, PrioridadesObtidas),
    max_member(MaiorPrioridade, PrioridadesObtidas),
    prioridade(Cat, MaiorPrioridade).



