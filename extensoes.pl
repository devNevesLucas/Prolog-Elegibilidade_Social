% ===========================
% Critérios de Patrimônio
% ===========================
% 
% Excluir quando patrimonio_familia > K * SM. Verificação de bens além de renda.
% 
% Fato - patrimonio_familia(F, P).
% Fato - limite_patrimonio(beneficio, K).
%

criterio_patrimonio(F, Auxilio) :-
    salario_minimo(SM),
    patrimonio_familia(F, P),
    limite_patrimonio(Auxilio, K),
    P < K * SM.


% ===========================
% Regras Regionais
% ===========================
% 
% obter_limite(Municipio, Bolsa, Limite)
% 
% Caso municípo nao possua limite para o RPC, assume valor pre definido
%

obter_limite(Mun, Bolsa, L) :- limite_rpc_regional(Mun, Bolsa, L), !.

obter_limite(_, bolsa_basica, L) :- limite_rpc_bolsa_basica(L).  
obter_limite(_, bolsa_idoso, L) :- limite_rpc_bolsa_idoso(L).
obter_limite(_, auxilio_desemprego, L) :- limite_rpc_auxilio_desemprego(L).
obter_limite(_, creche, L) :- limite_rpc_creche(L).