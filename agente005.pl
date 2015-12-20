% Some simple test agents.
%
% To define an agent within the navigate.pl scenario, define:
%   init_agent
%   restart_agent
%   run_agent
%
% Currently set up to solve the wumpus world in Figure 6.2 of Russell and
% Norvig.  You can enforce generation of this world by changing the
% initialize(random,Percept) to initialize(fig62,Percept) in the
% navigate(Actions,Score,Time) procedure in file navigate.pl and then run
% navigate(Actions,Score,Time).

% Lista de Percepcao: [Stench,Breeze,Glitter,Bump,Scream]
% Traducao: [Fedor,Vento,Brilho,Trombada,Grito]
% Acoes possiveis:
% goforward - andar
% turnright - girar sentido horario
% turnleft - girar sentido anti-horario
% grab - pegar o ouro
% climb - sair da caverna
% shoot - atirar a flecha

% Copie wumpus1.pl e agenteXX.pl onde XX eh o numero do seu agente (do grupo)
% para a pasta rascunhos e depois de pronto para trabalhos
% Todos do grupo devem copiar para sua pasta trabalhos, 
% com o mesmo NUMERO, o arquivo identico.

% Para rodar o exemplo, inicie o prolog com:
% swipl -s agente007.pl
% e faca a consulta (query) na forma:
% ?- start.
:-use_module(library(lists)).
:-dynamic([
agent_angulo/1,
antiga_posicao/1,
atual_posicao/1,
casas_seguras/1,
agent_flecha/1,
agent_ouro/1,
wumpus/1,
casas_suspeitas/1,
casas_seguras/1,
casas_suspeitas/1,
hole/1,
fuga/1,
jogadas/1
]).

:- load_files([wumpus3]). %definindo o mundo "3"
wumpusworld(pit3, 4). %definindo 3 buracos fixos

init_agent :- % se nao tiver nada para fazer aqui, simplesmente termine com um ponto (.)
    writeln('Agente iniciando...'), % apague esse writeln e coloque aqui as acoes para iniciar o agente
    retractall(agent_angulo(_)),
    retractall(antiga_posicao(_)),
    retractall(atual_posicao(_)),
    retractall(casas_seguras(_)),
    retractall(agent_flecha(_)),
    retractall(agent_ouro(_)),
    retractall(wumpus(_)),
    retractall(casas_suspeitas(_)),
    retractall(fuga(_)),
    retractall(jogadas(_)),
    assert(jogadas(0)),
    assert(fuga(0)),
    retractall(casas_visitadas(_)),
    assert(casas_suspeitas([_])),
    assert(casas_visitadas([[1,1]])),
    assert(wumpus(1)),
    assert(agent_ouro(0)),
    assert(agent_flecha(1)),
    assert(antiga_posicao([1,1])),
    assert(atual_posicao([1,1])),
    assert(casas_seguras([[1,1]])),
    assert(agent_angulo(0)).


% esta funcao permanece a mesma. Nao altere.
restart_agent :- 
    init_agent.

% esta e a funcao chamada pelo simulador. Nao altere a "cabeca" da funcao. Apenas o corpo.
% Funcao recebe Percepcao, uma lista conforme descrito acima.
% Deve retornar uma Acao, dentre as acoes validas descritas acima.


run_agent(Percepcao, Acao):-
    write('percebi: '), % pode apagar isso se desejar. Imprima somente o necessario.
writeln(Percepcao), % apague paraa limpar a saida. Coloque aqui seu codigo.
set_casas_seguras(Percepcao),
imprima_casas_seguintes,
testa_casas,
mover_agent(Percepcao,Acao),
write('Minha orientacao: '),
imprima_orien,
write('Minha Atual Posicao: '),
imprima_pos,
write('Minha Antiga Posicao: '),
imprima_antpos,
%imprima_adjacentes,
imprima_flecha,
imprima_ouro,
write('Casas visitadas: '),
imprima_casas,
imprima_casas_seg,
imprima_wumpus,
%testa_casas,
atualiza_jogada,
testa_quantidade,
ajusta_casas_seg,
imprima_fuga.

  %inicio da inteligencia/reacoes do agente...

  doido([_,_,_,_,_], climb):- atual_posicao([1,1]), agent_ouro(1).
doido([_,_,_,_,_], climb):- atual_posicao([1,1]),wumpus(0).

imprima_orien:-agent_angulo(X), writeln(X).  
imprima_pos:- atual_posicao(LIST),writeln(LIST).
imprima_antpos:- antiga_posicao(LIST),writeln(LIST).
imprima_flecha:- agent_flecha(X), write('Flechas do agente: '), writeln(X).
imprima_ouro:- agent_ouro(X), ((X=:=0, writeln('Estou sem Ouro')) | (X=:=1, writeln('Estou com o ouro'))).
imprima_wumpus:- wumpus(X), ((X=:=0, writeln('Wumpus esta morto')) | (X=:=1, writeln('Wumpus esta vivo'))).
imprima_casas:-casas_visitadas(List), writeln(List).
imprima_adjacentes:-atual_posicao(LIST),adjacentes(LIST,L),write('Casas Adjacentes'),writeln(L).
imprima_casas_seg:-casas_seguras(LISTA),write('Casas Seguras: '),writeln(LISTA).
imprima_casas_seguintes:-casas_seguintes(X),write('Proximas casas: '), writeln(X).
imprima_casas_wumpus:-casas_suspeitas(X), write('Casas Suspeitas de Wumpus: '), writeln(X).
imprima_fuga:-fuga(X),((X=:=1,writeln('Fugindo'))|writeln('Explorando o mundo')).

nova_posicao(X,Y,0,X1,Y):- X1 is (X+1).%o agent só andou pra frente.
nova_posicao(X,Y,90,X,Y1):- Y1 is (Y+1). %o agent só andou pra cima.
nova_posicao(X,Y,180,X1,Y):- X1 is (X-1).%o agent só andou para trás.
nova_posicao(X,Y,270,X,Y1):- Y1 is (Y-1). %o agent só andou para baixo.

atualiza_jogada:-jogadas(X),X1 is X+1,retractall(jogadas(_)),assert(jogadas(X1)).
testa_quantidade:-jogadas(X),fuga(Y),((X>49,retractall(fuga(_)),assert(fuga(1)))|true).
ajusta_casas_seg:-casas_seguras(S),retract(casas_seguras([_,0])).
ajusta_casas_seg:-casas_seguras(S),retract(casas_seguras([0,_])).
ajusta_casas_seg:-casas_seguras(S),retract(casas_seguras([_,5])).
ajusta_casas_seg:-casas_seguras(S),retract(casas_seguras([5,_])).
ajusta_casas_seg:-casas_seguras([[X,Y]]),X<0,retract(casas_seguras([X,Y])).
ajusta_casas_seg:-casas_seguras([[X,Y]]),Y<0,retract(casas_seguras([X,Y])).
 ajusta_casas_seg:-casas_seguras([[X,Y]]),X>5,retract(casas_seguras([X,Y])).
  ajusta_casas_seg:-casas_seguras([[X,Y]]),Y>5,retract(casas_seguras([X,Y])).
  ajusta_casas_seg:-true.



salva_pos_vis:-atual_posicao(LIST1),%guardar os locais seguros para a volta
[Z,W]=LIST1,
casas_visitadas(List),
((not(pertence(LIST1,List)),
    Z>0,
    Z<5,
    W>0,
    W<5,
    append(List,[LIST1],NewList),
    retractall(casas_visitadas(_)),
    assert(casas_visitadas(NewList)))|(true)).
dec_flecha:-agent_flecha(X), X1 is (X-1), retractall(agent_flecha(_)), assert(agent_flecha(X1)).
set_ouro:-agent_ouro(X), X1 is (X+1), retractall(agent_ouro(_)), assert(agent_ouro(X1)).




pertence(X,[X|_]).
pertence(X,[_|Y]):-pertence(X,Y).

%Casas adjacentes - Talvez precise de mais ajustes
%

adjacentes([R,P],L):-
    R==1,
    P==4,
    baixo([R,P],L1),
    direita([R,P],L4),
    L=[L1,L4].

adjacentes([R,P],L):-
     R==2,
     P==4,
     baixo([R,P],L1),
     esquerda([R,P],L2),
     direita([R,P],L4),
     L=[L1,L2,L4].

 adjacentes([R,P],L):-
       R==3,
       P==4,
       baixo([R,P],L1),
       esquerda([R,P],L2),
       direita([R,P],L4),
       L=[L1,L2,L4].
   adjacentes([R,P],L):-
            R==3,
           P==1,
           cima([R,P],L1),
           esquerda([R,P],L2),
            direita([R,P],L4),
            L=[L1,L2,L4].


 adjacentes([R,P],L):-
        R==1,
        P==1,
        cima([R,P],L1),
        direita([R,P],L4),
        L=[L1,L4].


adjacentes([R,P],L):-
    R\==1,
    R\==4,
    P\==1,
    P\==4,
    cima([R,P],L1),
    baixo([R,P],L2),
    esquerda([R,P],L3),
    direita([R,P],L4),
    L=[L1,L2,L3,L4].


adjacentes([R,P],L):-
    R==1,
    P==1,
    cima([R,P],L1),
    direita([R,P],L4),
    L=[L1,L4].


adjacentes([R,P],L):-
    R==4,
    P==1,
    cima([R,P],L1),
    esquerda([R,P],L3),
    L=[L1,L3].


adjacentes([R,P],L):-
    R==1,
    P==1,
    direita([R,P],L4),
    baixo([R,P],L2),
    L=[L2,L4].


adjacentes([R,P],L):-
    R==4,
    P==4,
    baixo([R,P],L2),
    esquerda([R,P],L3),
    L=[L2,L3].

adjacentes([R,P],L):-
    R\==1,
    R\==4,
    P==1,
    esquerda([R,P],L3),
    direita([R,P],L4),
    cima([R,P],L1),
    L=[L1,L3,L4].

adjacentes([R,P],L):-
    R\==1,
    R\==4,
    P==4,
    esquerda([R,P],L3),
    direita([R,P],L4),
    baixo([R,P],L2),
    L=[L2,L3,L4].

adjacentes([R,P],L):-
    P\==1,
    P\==4,
    R==1,
    cima([R,P],L1),
    baixo([R,P],L2),
    direita([R,P],L4),
    L=[L1,L2,L4].

adjacentes([R,P],L):-
    P\==1,
    P\==4,
    R==4,
    cima([R,P],L1),
    baixo([R,P],L2),
    esquerda([R,P],L3),
    L=[L1,L2,L3].


%Calculos das coordenadas das casas adjacentes

cima([R,P],L1):-
    P1 is P+1,
    L1=[R,P1].

baixo([R,P],L2):-
    P2 is P-1,
    L2=[R,P2].

esquerda([R,P],L3):-
    R2 is R-1,
    L3=[R2,P].

direita([R,P],L4):-
    R1 is R+1,
    L4=[R1,P].

%lembrando que talvez falte alguns ajustes
%
set_casas_seguras([_,no,_,_,_]):-atual_posicao(LIST),
wumpus(W),
W=:=0,
[X1,Y1]=LIST,
X1<5,
Y1<5,
X1>0,
Y1>0,
adjacentes(LIST, T),
casas_seguras(X),
append([LIST], T, LISTA), 
append(LISTA, X, LISTA1), 
not(member([_,0],LISTA1)),
list_to_set(LISTA1,NOVALISTA),
retractall(casas_seguras(_)),
assert(casas_seguras(NOVALISTA)).

set_casas_seguras([no,no,_,_,_]):-atual_posicao(LIST),
[X1,Y1]=LIST,
X1<5,
Y1<5,
X1>0,
Y1>0,
adjacentes(LIST, T),
casas_seguras(X),
append([LIST], T, LISTA),
append(LISTA, X, LISTA1),
not(member([_,0],LISTA1)),
not(member([0,_],LISTA1)),
not(member([_,5],LISTA1)),
not(member([5,_],LISTA1)),
list_to_set(LISTA1,NOVALISTA),
retractall(casas_seguras(_)),
assert(casas_seguras(NOVALISTA)).


set_casas_seguras([_,_,_,no,_]):-((atual_posicao(LIST),
[X,Y]=LIST,
X<5,
Y<5,
X>0,
Y>0,
casas_seguras(T),
append([LIST], T, LISTA),
list_to_set(LISTA, LISTA1),
not(member([_,0],LISTA1)),
not(member([0,_],LISTA1)),
not(member([_,5],LISTA1)),
not(member([5,_],LISTA1)),
retractall(casas_seguras(_)),
assert(casas_seguras(LISTA1)))).


set_casas_seguras([_,_,_,_,_]):-true.

casas_suspeitas_wumpus([yes,_,_,_,_]):-
    casas_seguras(S),
    casas_suspeitas(List),
    atual_posicao(L),
    adjacentes(L, X),
    subtract(X,S,NewList),
    append(List,NewList, Novalista),
    retractall(casas_suspeitas(_)),
    assert(casas_suspeitas(Novalista)).

casas_suspeitas_wumpus([yes,_,_,_,_]):-true.
casas_seguintes(X):-casas_seguras(T),
casas_visitadas(R), 
atual_posicao(LIST), 
adjacentes(LIST,L), 
subtract(T,R,NOVALISTA), 
intersection(NOVALISTA,L,X).

casas_nao_visitadas(X):-casas_seguras(T),
casas_visitadas(R),
subtract(T,R,X).

testa_casas:-casas_seguras(S),
casas_visitadas(L),
(jogadas(J),
J>3,
(subtract(S,L,X),X==[],retractall(fuga(_)),assert(fuga(1)))|true).


esta(X,Y):-casas_seguintes([[X,Y]]).

atualiza_posicao:-atual_posicao([X,Y]),
agent_angulo(I),
nova_posicao(X,Y,I,X1,Y1),
(X1>0,X1<5,Y1>0,Y1<5,
retractall(antiga_posicao(_)),
assert(antiga_posicao([X,Y])),
retractall(atual_posicao(_)),
assert(atual_posicao([X1,Y1]))|true).

vira_esquerda:-agent_angulo(Rotacao),
Rotacao1 is (Rotacao+90) mod 360,
retractall(agent_angulo(_)),
assert(agent_angulo(Rotacao1)).

vira_direita:-agent_angulo(Rotacao),
Rotacao1 is (Rotacao+270) mod 360,
retractall(agent_angulo(_)),
assert(agent_angulo(Rotacao1)).

mover_agent([_,_,yes,_,_],grab):-set_ouro.

mover_agent([yes,no,_,_,no],shoot):-
    atual_posicao([X,Y]),
         agent_angulo(I),
         nova_posicao(X,Y,I,X1,Y1),
         casas_seguras(T),
         append(T,[[X1,Y1]],LISTA),
         list_to_set(LISTA,NOVALISTA),
         retractall(casas_seguras(_)),
         assert(casas_seguras(NOVALISTA)),
         wumpus(P),
         P=:=1,
         agent_flecha(L),
         L>0,
         dec_flecha.

 mover_agent([yes,no,_,_,yes],gofoward):-
    retractall(wumpus(_)),
         assert(wumpus(0)),
         atual_posicao(POS),
         adjacentes(POS,L),
         casas_seguras(T),
         append(T,L,LISTA),
         list_to_set(LISTA,NOVALISTA),
         retractall(casas_seguras(_)),
         assert(casas_seguras(NOVALISTA)).

mover_agent(Percp,TESTE):-atual_posicao(LIST),
agent_angulo(I),
agent_ouro(O),
fuga(X),
not(LIST==[1,1]),
(O=:=1|X=:=1),
    writeln('Vou Voltar!'),
    acao(LIST,I,[1,1],TESTE).

mover_agent(Percp,TESTE):-atual_posicao(LIST),
agent_angulo(I),
agent_ouro(O),
fuga(X),
(LIST==[1,1]),
    ( O=:=1|X=:=1),
        TESTE=climb.

mover_agent(Percp,TESTE):-
    set_casas_seguras(Percp),
    agent_angulo(I),
    atual_posicao(POS),
    casas_seguintes(P),
    [A|B]=P,
    agent_ouro(O),
    O=:=0,
    not(P==[]),
    write('Escolha: '),writeln(A),
    acao(POS,I,A, TESTE),
        salva_pos_vis.

    mover_agent(Percp,TESTE):-
        set_casas_seguras(Percp),
        agent_angulo(I),
        atual_posicao(POS),             
        casas_nao_visitadas(Y),
        agent_ouro(O),
        O=:=0,
        random_member(P1,Y),
        last(Y,P1),
        [A|B]=Y,
        write('Escolha: '),writeln(A),
        acao(POS,I,P1, TESTE),
            salva_pos_vis.

    mover_agent(_,TESTE):-
        atual_posicao(POS),
        agent_angulo(I),
        acao(POS,I,[1,1], TESTE),
        salva_pos_vis.

        acao([X1, Y], 0, [X2, Y], goforward):-
            X1<X2,
            casas_seguras(CasasSeguras),
            atual_posicao([Z,W]),
            nova_posicao(Z,W,0,Z1,W1),
            member([Z1,W1], CasasSeguras),
            atualiza_posicao.


        acao([X1, Y], 0, [X2, Y], turnleft):-
            X1>X2,
            vira_esquerda.

        acao([X, Y1], 0, [X, Y2], turnleft):-
            Y1<Y2,
            vira_esquerda.

        acao([X, Y1], 0, [X, Y2], turnright):-
            Y1>Y2,
            vira_direita.

        acao([X1, Y1], 0, [X2, Y2], turnright):-
            X1>X2,
            Y1>Y2,
            vira_direita.

        acao([X1, Y1], 0, [X2, Y2], goforward):-
            X1<X2,
            Y1>Y2,
            casas_seguras(CasasSeguras),
            atual_posicao([Z,W]),
            nova_posicao(Z,W,0,Z1,W1),
            member([Z1,W1], CasasSeguras),
            atualiza_posicao.

        acao([X1, Y1], 0, [X2, Y2], turnleft):-
            X1>X2,
            Y1<Y2,
            vira_esquerda.

        acao([X1, Y1], 0, [X2, Y2], goforward):-
            X1<X2,
            Y1<Y2,
            casas_seguras(CasasSeguras),
            atual_posicao([Z,W]),
            nova_posicao(Z,W,0,Z1,W1),
            member([Z1,W1], CasasSeguras),
            atualiza_posicao.

        acao([X, Y1], 90, [X, Y2], goforward):-
            Y1<Y2,
            casas_seguras(CasasSeguras),
            atual_posicao([Z,W]),         
            nova_posicao(Z,W,90,Z1,W1),
            member([Z1,W1], CasasSeguras),
            atualiza_posicao.

        acao([X, Y1], 90, [X, Y2], turnleft):-
            Y1>Y2,
            vira_esquerda.

        acao([X1, Y], 90, [X2, Y], turnleft):-
            X1>X2,
            vira_esquerda.

        acao([X1, Y], 90, [X2, Y], turnright):-
            X1<X2,

            vira_direita.


        acao([X1, Y1], 90, [X2, Y2], turnleft):-
            X1>X2,
            Y1>Y2,
            vira_esquerda.

        acao([X1, Y1], 90, [X2, Y2], turnleft):-
            X1<X2,
            Y1>Y2,
            vira_esquerda.

        acao([X1, Y1], 90, [X2, Y2], turnright):-
            X1<X2,
            Y1>Y2,
            vira_direita.

        acao([X1, Y1], 90, [X2, Y2], turnright):-
            X1<X2,
            Y1<Y2,
            vira_direita.

        acao([X1, Y1], 90, [X2, Y2], goforward):-
            X1>X2,
            Y1<Y2,
            casas_seguras(CasasSeguras),
            atual_posicao([Z,W]),
            nova_posicao(Z,W,90,Z1,W1),
            member([Z1,W1], CasasSeguras),
            atualiza_posicao.

        acao([X1, Y1], 90, [X2, Y2], goforward):-
            X1<X2,
            Y1<Y2,
            casas_seguras(CasasSeguras),
            atual_posicao([Z,W]),
            nova_posicao(Z,W,90,Z1,W1),
            member([Z1,W1], CasasSeguras),
            atualiza_posicao.

        acao([X1, Y], 180, [X2, Y], turnleft):-
            X1<X2,
            vira_esquerda.

        acao([X1, Y], 180, [X2, Y], goforward):-
            X1>X2,
            casas_seguras(CasasSeguras),
            atual_posicao([Z,W]),
            nova_posicao(Z,W,180,Z1,W1),
            member([Z1,W1], CasasSeguras),
            atualiza_posicao.

        acao([X, Y1], 180, [X, Y2], turnright):-
            Y1<Y2,
            vira_direita.

        acao([X, Y1], 180, [X, Y2], turnleft):-
            Y1>Y2,
            vira_esquerda.

        acao([X1, Y1], 180, [X2, Y2], goforward):-
            X1>X2,
            Y1<Y2,
            casas_seguras(CasasSeguras),
            atual_posicao([Z,W]),
            nova_posicao(Z,W,180,Z1,W1),
            member([Z1,W1], CasasSeguras),
            atualiza_posicao.

        acao([X1, Y1], 180, [X2, Y2], turnleft):-
            X1<X2,
            Y1>Y2,
            vira_esquerda.

        acao([X1, Y1], 180, [X2, Y2], turnright):-
            X1<X2,
            Y1<Y2,
            vira_direita.

         acao([X1, Y1], 180, [X2, Y2], turnleft):-
                         X1>X2,
                         Y1>Y2,
                         vira_esquerda.

        acao([X1, Y1], 180, [X2, Y2], goforward):-
            X1>X2,
            Y1>Y2,
            casas_seguras(CasasSeguras),
            atual_posicao([Z,W]),
            nova_posicao(Z,W,180,Z1,W1),
            member([Z1,W1], CasasSeguras),
            atualiza_posicao.

        acao([X1, Y], 270, [X2, Y], turnleft):-
            X1<X2,
            vira_esquerda.

        acao([X1, Y], 270, [X2, Y], turnright):-
            X1>X2,
            vira_direita.

        acao([X, Y1], 270, [X, Y2], goforward):-
            Y2<Y1,
            casas_seguras(CasasSeguras),
            atual_posicao([Z,W]),
            nova_posicao(Z,W,270,Z1,W1),
            member([Z1,W1], CasasSeguras),
            atualiza_posicao.

        acao([X, Y1], 270, [X, Y2], turnleft):-
            Y2>Y1,
            vira_esquerda.

        acao([X1, Y1], 270, [X2, Y2], goforward):-
            X1>X2,
            Y1>Y2,
            casas_seguras(CasasSeguras),
            atual_posicao([Z,W]),
            nova_posicao(Z,W,270,Z1,W1),
            member([Z1,W1], CasasSeguras),
            atualiza_posicao.

        acao([X1, Y1], 270, [X2, Y2], goforward):-
            X1<X2,
            Y1>Y2,
            casas_seguras(CasasSeguras),
            atual_posicao([Z,W]),
            nova_posicao(Z,W,270,Z1,W1),
            member([Z1,W1], CasasSeguras),
            atualiza_posicao.

        acao([X1, Y1], 270, [X2, Y2], turnleft):-
            X1<X2,
            Y1<Y2,
            vira_esquerda.

        acao([X1, Y1], 270, [X2, Y2], turnright):-
            X1>X2,
            Y1<Y2,
            vira_direita.
         
        acao([_,_],I,[_,_],goforward):-
            casas_seguras(CasasSeguras),
                         atual_posicao([Z,W]),
                         nova_posicao(Z,W,I,Z1,W1),
                         member([Z1,W1], CasasSeguras),
                         atualiza_posicao.



