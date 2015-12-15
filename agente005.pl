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
:-dynamic([
agent_angulo/1,
antiga_posicao/1,
atual_posicao/1,
casas_seguras/1,
agent_flecha/1,
agent_ouro/1,
wumpus/1,
hole/1
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
    assert(wumpus(1)),
    assert(agent_ouro(0)),
    assert(agent_flecha(1)),
    %assert(antiga_posicao([1,1])),
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
writeln(Percepcao), % apague para limpar a saida. Coloque aqui seu codigo.
  doido(Percepcao, Acao),
  %agent_arrows(Arrow),
  %write('Quantidade de Flechas: '),
  %writeln(Arrow),
  write('Minha orientacao: '),
  imprima_orien,
  write('Minha Atual Posicao: '),
  imprima_pos,
  write('Minha Antiga Posicao: '),
  imprima_antpos,
  imprima_flecha,
  imprima_ouro,
  imprima_casas,
  imprima_wumpus.
  %forca(Percepcao, Acao).
  %inicio da inteligencia/reacoes do agente...

  doido([_,_,_,_,_], climb):- atual_posicao([1,1]), agent_ouro(1).
  doido([_,_,_,_,_], climb):- atual_posicao([1,1]),wumpus(0).



doido([no,_,no,no,no],goforward):-
      atual_posicao([X,Y]),
      agent_angulo(Z),
      nova_posicao(X,Y,Z,K,W),
      retractall(atual_posicao([_,_])),
      retractall(antiga_posicao([_,_])),
      assert(antiga_posicao([X,Y])),
      assert(atual_posicao([K,W])),
      salva_pos_segura.

doido([_,_,no,yes,_], turnleft):- 
      atual_posicao([X,Y]),
      agent_angulo(Rotacao),
      ((Rotacao=:=0,X1 is (X-1),Y1 is Y)|(Rotacao=:=90,X1 is X,Y1 is (Y-1))|(Rotacao=:=180,X1 is (X+1),Y1 is Y)|(Rotacao=:=270,X1 is X,Y1 is (Y+1))),
      retract(atual_posicao([X,Y])),
      assert(atual_posicao([X1,Y1])),
      Rotacao2 is (Rotacao + 90) mod 360,
      retractall(agent_angulo(Rotacao)),
      assert(agent_angulo(Rotacao2)). %se trombrar na parede, vira a esquerda.

doido([_,_,yes,_,_], grab):-set_ouro. %se sentir o brilhodo ouro, pagar

doido([yes,_,_,_,_], shoot):- agent_flecha(X),X>0,dec_flecha. %se sentir fedor, pode atirar sua flecha que vai em linha ate o fim do mapa.
doido([yes,_,_,_,yes], goforward):- retractall(wumpus(_)),
        assert(wumpus(0)),
        atual_posicao([X,Y]),
        agent_angulo(Z),
        nova_posicao(X,Y,Z,K,W),
        retractall(atual_posicao([_,_])),
        retractall(antiga_posicao([_,_])),
        assert(antiga_posicao([X,Y])),
        assert(atual_posicao([K,W])),
        salva_pos_segura.

doido([yes,_,_,_,_],goforward):-atual_posicao([X,Y]),
        agent_angulo(Z),
        nova_posicao(X,Y,Z,K,W),
        retractall(atual_posicao([_,_])),
        retractall(antiga_posicao([_,_])),
        assert(antiga_posicao([X,Y])),
        assert(atual_posicao([K,W])),
        salva_pos_segura.



imprima_orien:-agent_angulo(X), writeln(X).  
imprima_pos:- atual_posicao(LIST),writeln(LIST).
imprima_antpos:- antiga_posicao(LIST),writeln(LIST).
imprima_flecha:- agent_flecha(X), write('Flechas do agente: '), writeln(X).
imprima_ouro:- agent_ouro(X), ((X=:=0, writeln('Estou sem Ouro')) | (X=:=1, writeln('Estou com o ouro'))).
imprima_wumpus:- wumpus(X), ((X=:=0, writeln('Wumpus esta morto')) | (X=:=1, writeln('Wumpus esta vivo'))).
imprima_casas:-casas_seguras(List), writeln(List).


nova_posicao(X,Y,0,X1,Y):- X1 is (X+1).%o agent só andou pra frente.
nova_posicao(X,Y,90,X,Y1):- Y1 is (Y+1). %o agent só andou pra cima.
nova_posicao(X,Y,180,X1,Y):- X1 is (X-1).%o agent só andou para trás.
nova_posicao(X,Y,270,X,Y1):- Y1 is (Y-1). %o agent só andou para baixo.

salva_pos_segura:-antiga_posicao(LIST1),  %guardar os locais seguros para a volta
            casas_seguras(List),
          ((not(pertence(LIST1,List)),
            append(List,[LIST1],NewList),
            retractall(casas_seguras(_)),
            assert(casas_seguras(NewList)))|(true)).
dec_flecha:-agent_flecha(X), X1 is (X-1), retractall(agent_flecha(_)), assert(agent_flecha(X1)).
set_ouro:-agent_ouro(X), X1 is (X+1), retractall(agent_ouro(_)), assert(agent_ouro(X1)).




pertence(X,[X|_]).
pertence(X,[_|Y]):-pertence(X,Y).

%Casas adjacentes - Talvez precise de mais ajustes

adjacentes([R,P],L):-
    R\==1,
    R\==4,
    P\==1,
    P\==4,
    cima([R,P],L1),
    baixo([R,P],L2),
    esquerda([R,P],L3),
    direita([R,P],L4),
    L=[L1,L2,L3,L4],
    write('Adjacentes:'),
    writeln(L).

adjacentes([R,P],L):-
    R==1,
    P==1,
    cima([R,P],L1),
    direita([R,P],L4),
    L=[L1,L4],
    write('Adjacentes:'),
    writeln(L).

adjacentes([R,P],L):-
    R==4,
    P==1,
    cima([R,P],L1),
    esquerda([R,P],L3),
    L=[L1,L3],
    write('Adjacentes:'),
    writeln(L).

adjacentes([R,P],L):-
    R==1,
    P==1,
    direita([R,P],L4),
    baixo([R,P],L2),
    L=[L2,L4],
    write('Adjacentes:'),
    writeln(L).

adjacentes([R,P],L):-
    R==4,
    P==4,
    baixo([R,P],L2),
    esquerda([R,P],L3),
    L=[L2,L3],
    write('Adjacentes:'),
    writeln(L).

adjacentes([R,P],L):-
    R\==1,
    R\==4,
    P==1,
    esquerda([R,P],L3),
    direita([R,P],L4),
    cima([R,P],L1),
    L=[L1,L3,L4],
    write('Adjacentes:'),
    writeln(L).

adjacentes([R,P],L):-
    R\==1,
    R\==4,
    P==4,
    esquerda([R,P],L3),
    direita([R,P],L4),
    baixo([R,P],L2),
    L=[L2,L3,L4],
    write('Adjacentes:'),
    writeln(L).

adjacentes([R,P],L):-
    P\==1,
    P\==4,
    R==1,
    cima([R,P],L1),
    baixo([R,P],L2),
    direita([R,P],L4),
    L=[L1,L2,L4],
    write('Adjacentes:'),
    writeln(L).

adjacentes([R,P],L):-
    P\==1,
    P\==4,
    R==4,
    cima([R,P],L1),
    baixo([R,P],L2),
    esquerdaa([R,P],L3),
    L=[L1,L2,L3],
    write('Adjacentes:'),
    writeln(L).

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



