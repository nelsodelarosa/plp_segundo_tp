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
ciudades(Xs):- setof(X,Y^Z^llega(X,Y,Z),Xs).


% viajeDesde(+Origen,?Destino,-Recorrido,-Tiempo) -- Devuelve infinitos resultados.

%primero([X],X).
primero([X|_],X).

% suma(?L,-X).
suma([],0).
suma([X|Xs], Y):- suma(Xs,K), Y is K+X. 
% suma([X|Xs], Y):-   suma(Xs,K), K = (Y-X). 

ultimo(L,R):- append(_,[R],L).
%viajeDesde(O,D,R,X):- primero(R,O), ultimo(R,D), tiempoRecorrido(R,X), esRuta(R).

viajeDesde(O,D,R,X):- primero(R,O), ultimo(R,D),  esRuta(R),tiempoRecorrido(R,X).


tiempoRecorrido([X],0).
tiempoRecorrido([X,Y|L],T):- llega(X,Y,Z),tiempoRecorrido([Y|L],K), T is K+Z.

esRuta([_]).
esRuta([X,Y|Ts]):- llega(X,Y,_),esRuta([Y|Ts]).


esRutaSC([_]).
esRutaSC([X,Y|Ts]):-  llega(X,Y,_), esRutaSC([Y|Ts]),not(member(X,[Y|Ts])).

%viajeSinCiclos(+Origen,?Destino,-Recorrido,-Tiempo)
%viajeSinCiclos(O,D,R,X):- esCamino(O,D,R),tiempoRecorrido(R,X).

viajeSinCiclos(O,D,R,X):- primero(R,O), esRutaSC(R, []), tiempoRecorrido(R,X), ultimo(R,D).
esRutaSC([X], F2):-not(member(X,F2)).
esRutaSC([X,Y|Ts], F):- llega(X,Y,_), not(member(X,F)), append([X],F,F2), esRutaSC([Y|Ts], F2).

% viajeMasCorto(+Origen,+Destino,-Recorrido,-Tiempo)

viajes(O,D,Rs):-setof(RR,Y^viajeSinCiclos(O,D,RR,Y),Rs).

%menorTiempo([A],A,T):- tiempoRecorrido(A,T).
%menorTiempo([A,B|Ts],X,T ):- tiempoRecorrido(A,Ta), tiempoRecorrido(B,Tb),Ta >= Tb, menorTiempo([B|Ts],X,T). 
%menorTiempo([A,B|Ts],X,T ):- tiempoRecorrido(A,Ta), tiempoRecorrido(B,Tb),Ta < Tb, menorTiempo([A|Ts],X,T). 

menorTiempo([A],T):- tiempoRecorrido(A,T).
menorTiempo([A,B|Ts],T):- tiempoRecorrido(A,Ta), tiempoRecorrido(B,Tb),Ta >= Tb, menorTiempo([B|Ts],T). 
menorTiempo([A,B|Ts],T):- tiempoRecorrido(A,Ta), tiempoRecorrido(B,Tb),Ta < Tb, menorTiempo([A|Ts],T). 

viajeMasCorto(O,D,R,T):- viajes(O,D,Rs), menorTiempo(Rs,T),member(R,Rs),tiempoRecorrido(R,T).

% grafoCorrecto

alcanzaALasDemas(X,[]).
alcanzaALasDemas(X,[Y|Ys]):- viajeSinCiclos(X,Y,_,_),alcanzaALasDemas(X,Ys).

todasLLeganA([],Y).
todasLLeganA([X|Xs],Y):- viajeSinCiclos(X,Y,_,_),todasLLeganA(Xs,Y).

grafoCorrecto:- ciudades(L),member(X,L),alcanzaALasDemas(X,L),todasLLeganA(L,X). 


% cubreDistancia(+Recorrido, ?Avion)

cubreDistancia([ _ ],_).
cubreDistancia([X,Y|Rs], A):- llega(X,Y,T),autonomia(A,Auto), T =< Auto, cubreDistancia([Y|Rs],A).   

% vueloSinTransbordo(+Aerolinea, +Ciudad1, +Ciudad2, ?Tiempo, ?Avion)

aviones(Xs):- setof(A, Y^autonomia(A,Y),Xs).

sonAviones([]).
sonAviones([X|Xs]):- aviones(Aviones), member(X,Aviones),sonAviones(Xs).

esAerolinea([]).
esAerolinea([(C,L)|Aes]):- ciudades(Ciudades),member(C,Ciudades),sonAviones(L),esAerolinea(Aes).  

estaEnCiudad(A,Ciudad,[(C,L)|Aero]):- Ciudad == C, member(A,L).  
estaEnCiudad(A,Ciudad,[(C,L)|Aero]):- Ciudad \= C , estaEnCiudad(A,Ciudad,[Aero]).


vueloSinTransbordo(Aero, Ciudad1, Ciudad2, Tiempo, Avion):- esAerolinea(Aero), 
ciudades(Ciudades), member(Ciudad1,Ciudades),member(Ciudad2,Ciudades), estaEnCiudad(Avion,Ciudad1,Aero),
viajeMasCorto(Ciudad1,Ciudad2,R,Tiempo), cubreDistancia(R,Avion).														


%avionesDeAerolinea(Aero,Xs):- setof(A, Y^estaEnCiudad(A,Y,Aero),Xs).

%ejemplo
%[(rio,[airbus_a320]), (buenos_aires, [airbus_a320, boeing_767]),
%(cordoba, [airbus_a320]), (atlanta, [boeing_747])].



% Descomentar si se usa un archivo separado para las pruebas.
% - [pruebas].
