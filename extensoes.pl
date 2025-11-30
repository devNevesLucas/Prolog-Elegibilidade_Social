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

