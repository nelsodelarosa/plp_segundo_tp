%% Rutas aéreas predefinidas.

% llega(?origen, ?destino, ?tiempo)
llega(buenos_aires, mdq, 1).
llega(buenos_aires, cordoba, 2).
llega(buenos_aires, rio, 4).
llega(buenos_aires, madrid, 12).
llega(buenos_aires, atlanta, 11).
llega(mdq, buenos_aires, 1).
llega(cordoba, salta, 1).
llega(salta, buenos_aires, 2).
llega(rio, buenos_aires, 4).
llega(rio, new_york, 10).
llega(atlanta, new_york, 3).
llega(new_york, madrid, 9).
llega(madrid, lisboa, 1).
llega(madrid, buenos_aires, 12).
llega(lisboa, madrid, 1).
llega(new_york, buenos_aires, 11).

%% Aviones y sus autonomías.

% autonomia(?avion, ?horas)
autonomia(boeing_767, 15).
autonomia(airbus_a320, 9).
autonomia(boeing_747, 10).

% entre(X, Y, X) :- X =< Y.
% entre(X, Y, Z) :- X < Y, N is X+1, entre(N, Y, Z).

ciudad(buenos_aires).
ciudad(mdq).
ciudad(lisboa).
ciudad(madrid).
ciudad(new_york).
ciudad(rio).
ciudad(atlanta).
ciudad(salta).
ciudad(cordoba).

%% Predicados pedidos:

% ciudades(-Ciudades)
ciudades(X):-ciudad(X).





% viajeDesde(+Origen,?Destino,-Recorrido,-Tiempo) -- Devuelve infinitos resultados.

%ultimo([X],X).
%ultimo([ Z,Y| T],X) :- ultimo([Y|T],X).




%primero([X],X).
primero([X|_],X).

% suma(?L,-X).
suma([],0).
suma([X|Xs], Y):- suma(Xs,K), Y is K+X. 
% suma([X|Xs], Y):-   suma(Xs,K), K = (Y-X). 

ultimo(L,R):- append(_,[R],L).
%viajeDesde(O,D,R,X):- primero(R,O), ultimo(R,D), tiempoRecorrido(R,X), esRuta(R).

viajeDesde(O,D,R,X):- primero(R,O), ultimo(R,D),  esRuta(R),tiempoRecorrido(R,X).

%pasaTiempo([_],[0]).
%pasaTiempo([X,Y|Xs],[T|Ts]):- llega(X,Y,T), pasaTiempo([Y|Xs],Ts).

%tiempoRecorrido(R,X):-pasaTiempo(R,L), suma(L,X).
tiempoRecorrido([X],0).
tiempoRecorrido([X,Y|L],T):- llega(X,Y,Z),tiempoRecorrido([Y|L],K), T is K+Z.

esRuta([_]).
esRuta([X,Y|Ts]):- llega(X,Y,_),esRuta([Y|Ts]).



esRutaSC([_]).
%esRutaSR([X,Y|Ts]):- X\=Y, llega(X,Y,_),ultimo([Y|Ts],Z),append(L2,[Z],[Y|Ts]),not(member(Z,[X,Y|L2])), esRutaSR([Y|Ts]).
esRutaSC([X,Y|Ts]):-  llega(X,Y,_), esRutaSC([Y|Ts]),not(member(X,[Y|Ts])).


%esRuta(R):- pasaTiempo(R).

%viajeSinCiclos(+Origen,?Destino,-Recorrido,-Tiempo)
viajeSinCiclos(O,D,R,X):- primero(R,O),ultimo(R,D), esRutaSC(R),tiempoRecorrido(R,X).


% viajeMasCorto(+Origen,+Destino,-Recorrido,-Tiempo)

% grafoCorrecto

% cubreDistancia(+Recorrido, ?Avion)

% vueloSinTransbordo(+Aerolinea, +Ciudad1, +Ciudad2, ?Tiempo, ?Avion)

% Descomentar si se usa un archivo separado para las pruebas.
% - [pruebas].
