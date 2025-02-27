:- discontiguous grandparent/2.
:- discontiguous aunt/2.

% Relaciones de parentesco
parent(fulano, jose). %30
grandparent(pedro, fulano). %20
grandparent(lucia, fulano). %20
aunt(lucA, fulano). %10
aunt(lucB, fulano). %10
aunt(lucC, fulano). %10
aunt(lucD,fulano). %10

% Relaciones de género (masculino)
male(fulano).
male(jose).
male(pedro).

% Relaciones de género (femenino)
female(lucia).
female(lucA).
female(lucB).
female(lucC).
female(lucD).

% Relaciones entre familiares
father(X,Y) :- parent(X,Y), male(X).
mother(X,Y) :- parent(X,Y), female(X).
sibling(X,Y) :- parent(Z,X), parent(Z,Y).
grandparent(X, Y) :- parent(X, Z), parent(Z, Y).
brother(X, Y) :- sibling(X, Y), male(X).
sister(X, Y) :- sibling(X, Y), female(X).
uncle(X, Y) :- parent(Z, Y), brother(X, Z).
aunt(X, Y) :- parent(Z, Y), sister(X, Z).
cousin(X,Y) :- (aunt(Z,Y);uncle(Z,Y)),parent(Z,X). 

% Regla para determinar el nivel de una persona
level(Difunto, Persona, 1) :- parent(Difunto, Persona); parent(Persona, Difunto).
level(Difunto, Persona, 2) :- sibling(Persona, Difunto); grandparent(Difunto, Persona); grandparent(Persona, Difunto).
level(Difunto, Persona, 3) :- uncle(Persona, Difunto); aunt(Persona, Difunto); cousin(Persona, Difunto); uncle(Difunto,Persona); aunt(Difunto,Persona); cousin(Difunto,Persona).

% Regla principal para distribuir la herencia a varios herederos
distribuir_herencia(Difunto, DineroTotal, DistribucionFinal) :-
    findall((Persona, DineroAsignado), distribuir_dinero(Difunto, Persona, DineroTotal, DineroAsignado), DistribucionTemp),
    normalizar_distribucion(DistribucionTemp, DineroTotal, DistribucionFinal).

% Regla para calcular la cantidad de dinero asignada según el nivel
distribuir_dinero(Difunto, Persona, DineroTotal, DineroAsignado) :-
    level(Difunto, Persona, Level),
    (   Level == 1 -> DineroAsignado is DineroTotal * 0.3;
        Level == 2 -> DineroAsignado is DineroTotal * 0.2;
        Level == 3 -> DineroAsignado is DineroTotal * 0.1).

% Normaliza la distribución si la suma supera el total disponible
normalizar_distribucion(DistribucionTemp, DineroTotal, DistribucionNormalizada) :-
    sumar_dineros_asignados(DistribucionTemp, TotalAsignado),
    (   TotalAsignado =< DineroTotal -> 
        DistribucionNormalizada = DistribucionTemp;
        distribucion_ajustada(DistribucionTemp, TotalAsignado, DineroTotal, DistribucionNormalizada)
    ).

% Suma el dinero asignado temporalmente para verificar si supera el total
sumar_dineros_asignados(DistribucionTemp, TotalAsignado) :-
    findall(DineroAsignado, member((_, DineroAsignado), DistribucionTemp), Cantidades),
    sumlist(Cantidades, TotalAsignado).

% Ajusta la distribución proporcionalmente si el total supera el 100%
distribucion_ajustada(DistribucionTemp, TotalAsignado, DineroTotal, DistribucionNormalizada) :-
    FactorAjuste is DineroTotal / TotalAsignado,
    findall((Persona, DineroAjustado), 
        (   member((Persona, Dinero), DistribucionTemp),
            DineroAjustado is Dinero * FactorAjuste
        ),
        DistribucionNormalizada).
