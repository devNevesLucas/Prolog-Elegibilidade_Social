% ============================================
% TEM_DIREITO/2
% ============================================
% Descrição: Verifica se uma pessoa tem direito a um benefício social específico.
%            Implementa regras de elegibilidade para 5 benefícios diferentes.
%
% Parâmetros:
%   - P: átomo identificando a pessoa
%   - Beneficio: átomo representando o benefício
%
% Benefícios e Regras:
%
%   1. **bolsa_basica**: RPCA <= 50% SM
%      - Usa renda per capita ajustada (considera dependentes)
%      - Critério mais restritivo
%      - Benefício universal para extrema pobreza
%
%   2. **bolsa_idoso**: idoso (65+) E RPC <= 100% SM
%      - Usa renda per capita bruta (não ajustada)
%      - Critério menos restritivo que bolsa básica
%      - Específico para idosos
%
%   3. **auxilio_desemprego**: desempregado E RPC <= 120% SM
%      - Usa renda per capita bruta
%      - Critério mais flexível
%      - Suporte temporário para desempregados
%
%   4. **auxilio_creche**: família com criança pequena E RPC <= 120% SM
%      - Verifica presença de criança pequena na família
%      - Usa renda per capita bruta
%      - Suporte para famílias com crianças
%
%   5. **bonus_monoparental**: família monoparental
%      - Independe de renda
%      - Reconhece desafio adicional de famílias monoparentais
%
% Observações:
%   - Pessoa pode ter direito a multiplos benefícios
%   - Cada benefício tem critérios independentes
%   - Limiares são configuráveis via fatos
%
% Exemplos de uso:
%   ?- tem_direito(joao, bolsa_idoso).
%   true.  % joao é idoso e RPC <= 1.0 * SM
%
%   ?- tem_direito(maria, B).
%   B = bolsa_basica ;
%   B = auxilio_desemprego ;
%   B = bonus_monoparental.
%
% tem_direito(P, Beneficio).

tem_direito(P, bolsa_basica) :- 
    familia_de(P, F), 
    municipio_familia(F, Mun),
    renda_per_capita_ajustada(F, RPCA), 
    salario_minimo(SalMin),
    criterio_patrimonio(F, bolsa_basica),
    obter_limite(Mun, bolsa_basica, Coeficiente),
    RPCA =< SalMin * Coeficiente.

tem_direito(P, bolsa_idoso) :-
    familia_de(P, F),
    municipio_familia(F, Mun),
    renda_per_capita(F, RPC),
    categoria_de(P, idoso),
    salario_minimo(SalMin),
    criterio_patrimonio(F, bolsa_idoso),
    obter_limite(Mun, bolsa_idoso, Coeficiente),
    RPC =< SalMin * Coeficiente.

tem_direito(P, auxilio_desemprego) :-
    familia_de(P, F),
    municipio_familia(F, Mun),
    renda_per_capita(F, RPC),
    categoria_de(P, desempregado),
    salario_minimo(SalMin),
    criterio_patrimonio(F, auxilio_desemprego),
    obter_limite(Mun, auxilio_desemprego, Coeficiente),
    RPC =< SalMin * Coeficiente.

tem_direito(P, auxilio_creche) :-
    familia_de(P, F),
    municipio_familia(F, Mun),
    renda_per_capita(F, RPC),
    num_dependentes(F, Num),
    Num > 0,
    salario_minimo(SalMin),
    criterio_patrimonio(F, auxilio_creche),
    obter_limite(Mun, auxilio_creche, Coeficiente),
    RPC =< SalMin * Coeficiente.

tem_direito(P, bonus_monoparental) :-
    familia_de(P, F),
    criterio_patrimonio(F, bonus_monoparental),
    monoparental(F, P).