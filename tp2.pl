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
llega(cordoba, roma, 16).


%% Aviones y sus autonomías.

% autonomia(?avion, ?horas)
autonomia(boeing_767, 15).
autonomia(airbus_a320, 9).
autonomia(boeing_747, 10).


%% Predicados pedidos:

% ciudades(-Ciudades)
ciudadesQueAlcanzan(Xs):-setof(X,Y^Z^llega(X,Y,Z),Xs).

%ciudadesSonAlcanzadas(Xs):- setof(X,Y^Z^llega(Y,X,Z),Ls) .

esCiudad(X):- llega(_,X,_).
%esCiudad(X):- llega(X,_,_).
destino(X):- llega(X,_,_).

destinos(Xs):-setof(X,esCiudad(X),Xs).

ciudades(Xs):- setof(X,(Y^Z^llega(X,Y,Z),Xs).




% viajeDesde(+Origen,?Destino,-Recorrido,-Tiempo) -- Devuelve infinitos resultados.


primero([X|_],X).

ultimo(L,R):- append(_,[R],L).
%viajeDesde(O,D,R,X):- primero(R,O), ultimo(R,D), tiempoRecorrido(R,X), esRuta(R).

viajeDesde(O,D,R,X):- primero(R,O), ultimo(R,D),  esRuta(R),tiempoRecorrido(R,X).


tiempoRecorrido([X],0).
tiempoRecorrido([X,Y|L],T):- llega(X,Y,Z),tiempoRecorrido([Y|L],K), T is K+Z.

esRuta([_]).
esRuta([X,Y|Ts]):- llega(X,Y,_),esRuta([Y|Ts]).


esRutaSC([X], F2):-not(member(X,F2)).

esRutaSC([X,Y|Ts], F):- llega(X,Y,_), not(member(X,F)), append([X],F,F2), esRutaSC([Y|Ts], F2).


%viajeSinCiclos(+Origen,?Destino,-Recorrido,-Tiempo)

viajeSinCiclos(O,D,R,X):- primero(R,O), esRutaSC(R, []), tiempoRecorrido(R,X), ultimo(R,D).


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


%algunas pruebas
t1:- ciudades(X), X == [atlanta, buenos_aires, cordoba, lisboa, madrid, mdq, new_york, rio, salta].

t2:- viajeSinCiclos(buenos_aires,buenos_aires,X,T), X==[buenos_aires], T == 0.
t2:- viajeSinCiclos(buenos_aires,lisboa,X,T), X==[buenos_aires, madrid, lisboa], T == 13.
t2:- viajeSinCiclos(buenos_aires,lisboa,X,T), X==[buenos_aires, atlanta, new_york, madrid, lisboa], T == 24.
t2:- viajeSinCiclos(buenos_aires,lisboa,X,T), X==[buenos_aires, rio, new_york, madrid, lisboa], T == 24.

t3:- viajeSinCiclos(rio,buenos_aires,X,T), X==[rio, buenos_aires], T == 4.
t3:- viajeSinCiclos(rio,buenos_aires,X,T), X==[rio, new_york, madrid, buenos_aires], T == 31.
t3:- viajeSinCiclos(rio,buenos_aires,X,T), X==[rio, new_york, buenos_aires], T == 21.

t4:- viajeMasCorto(buenos_aires,lisboa, R,T), R==[buenos_aires, madrid, lisboa], T ==13.
t5:- viajeMasCorto(rio,buenos_aires, R,T), R==[rio, buenos_aires], T == 4.
t5:- viajeMasCorto(buenos_aires,new_york,R,T), R==[buenos_aires, atlanta, new_york], T == 14.
t5:- viajeMasCorto(buenos_aires,new_york,R,T), R==[buenos_aires, rio, new_york], T == 14.

t5:- viajeMasCorto(X,X,R,T), R==[X], T == 0.


tt:- dynamic llega/3.

t6:- grafoCorrecto.
%t7:- assert(llega(cordoba, roma, 16)).
%t10:- retract(llega(cordoba, salta, 1)).
t8:- grafoCorrecto.

t9:- cubreDistancia([rio, new_york, madrid, buenos_aires],X ), X==boeing_767.
t9:- cubreDistancia([atlanta, new_york, madrid, lisboa],X ), X==boeing_767.
t9:- cubreDistancia([atlanta, new_york, madrid, lisboa],X ), X==airbus_a320.






% Descomentar si se usa un archivo separado para las pruebas.
% - [pruebas].
