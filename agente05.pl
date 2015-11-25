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
:-dynamic(agent_angulo/1).

:- load_files([wumpus3]).
wumpusworld(pit3, 4). %definindo 3 buracos fixos

init_agent :- % se nao tiver nada para fazer aqui, simplesmente termine com um ponto (.)
    writeln('Agente iniciando...'), % apague esse writeln e coloque aqui as acoes para iniciar o agente
    retractall(agent_angulo(_)),
    assert(agent_angulo(0)).

% esta funcao permanece a mesma. Nao altere.
restart_agent :- 
    init_agent.

% esta e a funcao chamada pelo simulador. Nao altere a "cabeca" da funcao. Apenas o corpo.
% Funcao recebe Percepcao, uma lista conforme descrito acima.
% Deve retornar uma Acao, dentre as acoes validas descritas acima.
write('Valor da flecha: '), %introducao dos dados da fecha
writeln(Flecha).
  run_agent(Percepcao, Acao) :-
   write('percebi: '), % pode apagar isso se desejar. Imprima somente o necessario.
  writeln(Percepcao), % apague para limpar a saida. Coloque aqui seu codigo.
  write('Minha orientacao: '),
  %listing(agent_direction(X)),
  imprima_orien,
  forca(Percepcao, Acao). 
  %inicio da inteligencia/reacoes do agente...

  forca([_,_,no,no,_], goforward). %sem problemas a vista, continuapra frente
  forca([_,_,no,yes,_], turnleft):- agent_angulo(Rotacao),  
  Rotacao2 is (Rotacao + 90) mod 360,
  retractall(agent_angulo(Rotacao)),
  assert(agent_angulo(Rotacao2)). %se trombrar na parede, vira a esquerda.
  forca([_,_,yes,_,_], grab). %se sentir o brilhodo ouro, pagar
  forca([yes,_,no,_,no], shoot):- agent_arrows(1). %se sentir fedor, pode atirar sua flecha que vai em linha ate o fim do mapa.
  imprima_orien:-agent_angulo(X), write(X).  


