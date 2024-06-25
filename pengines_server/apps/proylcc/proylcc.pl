:- module(proylcc,
	[  
		put/8,
		solucionGrilla/4,
		verificarPistasInciales/5
	]).

:-use_module(library(lists)).

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% replace(?X, +XIndex, +Y, +Xs, -XsY)
%
% XsY es el resultado de reemplazar la ocurrencia de X en la posición XIndex de Xs por Y.

replace(X, 0, Y, [X|Xs], [Y|Xs]).

replace(X, XIndex, Y, [Xi|Xs], [Xi|XsY]):-
    XIndex > 0,
    XIndexS is XIndex - 1,
    replace(X, XIndexS, Y, Xs, XsY).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% put(+Contenido, +Pos, +PistasFilas, +PistasColumnas, +Grilla, -GrillaRes, -RowSat, -ColSat).
%

put(Contenido, [RowN, ColN], PistasFilas, PistasColumnas, Grilla, NewGrilla, RowSat, ColSat):-
	% NewGrilla es el resultado de reemplazar la fila Row en la posición RowN de Grilla
	% (RowN-ésima fila de Grilla), por una fila nueva NewRow.

	%Si la pos es X o vacio verifica fila y columna si y solo el contenido es #.

	replace(Row, RowN, NewRow, Grilla, NewGrilla),

	% NewRow es el resultado de reemplazar la celda Cell en la posición ColN de Row por _,
	% siempre y cuando Cell coincida con Contenido (Cell se instancia en la llamada al replace/5).
	% En caso contrario (;)
	% NewRow es el resultado de reemplazar lo que se que haya (_Cell) en la posición ColN de Row por Contenido.

	(replace(Cell, ColN, _, Row, NewRow),
	Cell == Contenido
		;
	replace(_Cell, ColN, Contenido, Row, NewRow)),

	% Verifica si para la fila se cumplen las pistas y RowSat es 1, sino es 0.
	verificarFila(RowN,PistasFilas,NewGrilla,RowSat),		
	% Verifica si para la columna se cumplen las pistas y ColSat es 1, sino es 0.					
    verificarColumna(ColN,PistasColumnas,NewGrilla, ColSat).					


% obtener_columna(+Grilla,+Columna,-ListaDeElementosDeLaColumna)
	
obtenerColumna(Grilla, Col, Columna) :-
	maplist(nth0(Col), Grilla, Columna).

% verifica que la fila/columna cumpla sus pistas.
% 1==TRUE, 0==FALSE
% verificarColumna(+IndiceColumna,+ListaPistas,+GrillaRes,-verifica)

verificarColumna(IndiceColumna,PistasCol,GrillaRes, 1) :-
	nth0(IndiceColumna,PistasCol,PistasAVerificar),
	obtenerColumna(GrillaRes,IndiceColumna,ColumnaDeGrilla),
	verificarPistasEnLista(PistasAVerificar,ColumnaDeGrilla).
verificarColumna(_,_,_,0).

% verificarFila(+IndiceFila,+ListaPistas,+GrillaRes,-verifica)

verificarFila(IndiceFila,PistasFilas,GrillaRes, 1) :-
	nth0(IndiceFila,PistasFilas,PistasAVerificar),				
	nth0(IndiceFila,GrillaRes,FilaDeGrilla),					
	verificarPistasEnLista(PistasAVerificar,FilaDeGrilla).		
verificarFila(_,_,_,0).											

% verificarPistasEnLista(+Pistas, -)

verificarPistasEnLista([0],ListaFila):-not(member("#",ListaFila)).
verificarPistasEnLista([],ListaFila):-not(member("#",ListaFila)).
verificarPistasEnLista([X|PistasRestantes],[Y|ListaFilaSiguiente]):-Y == "#",
	verificarPistasConsecutivas(X,[Y|ListaFilaSiguiente],Restante),
	verificarPistasEnLista(PistasRestantes,Restante).
verificarPistasEnLista(Pistas,[Y|ListaFilaSiguiente]):- Y \== "#", 			
	verificarPistasEnLista(Pistas,ListaFilaSiguiente).

% verificarPistasConsecutivas( +NumeroPista, +FilaARecorrer, -FilaRestante)
verificarPistasConsecutivas(0,[],[]).														   
verificarPistasConsecutivas(0,[X|FilaRestante],FilaRestante):- X \== "#".
verificarPistasConsecutivas(N,[X|FilaRestante],Frestante):- X == "#", N > 0, Naux is N-1,   
	verificarPistasConsecutivas(Naux,FilaRestante,Frestante).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
verificarPistasInciales(Grid,RowClues,ColClues,RowsSat,ColsSat):-
    findall([RowIndex, RowSat], (nth0(RowIndex, Grid, _), verificarFila(RowIndex, RowClues, Grid, RowSat)), RowsSat),
    findall([ColIndex, ColSat], (nth0(ColIndex, Grid, _), verificarColumna(ColIndex, ColClues, Grid, ColSat)), ColsSat).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

solucionGrilla(GrillaOriginal,PistasFilas,PistasColumnas,GrillaNueva):-
	length(PistasFilas, LongFilas),
	length(PistasColumnas,LongColumnas),
(   LongColumnas \== LongFilas ->  resolverTriviales(GrillaOriginal, PistasFilas, PistasColumnas,LongColumnas,LongFilas, GrillaResultante), solucionGrillaAux(GrillaResultante, LongColumnas,LongFilas,PistasFilas,PistasColumnas,SolucionAux);
	resolverTriviales(GrillaOriginal, PistasFilas, PistasColumnas,LongFilas,LongColumnas, GrillaResultante),
	solucionGrillaAux(GrillaResultante, LongFilas,LongColumnas,PistasFilas,PistasColumnas,SolucionAux)),
	trasponer(SolucionAux, LongFilas, [] , Grilla),
	contieneCeldaVacia(Grilla,N), %mira si hay espacios vacios
	completarGrilla(N, Grilla, LongFilas, LongColumnas, PistasFilas, PistasColumnas,GrillaNueva).
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

solucionGrillaAux(GrillaOriginal,LongFilas,LongColumnas, PistasFilas,PistasColumnas,SolucionAux):-
	solucionFilas(GrillaOriginal, LongFilas, PistasFilas,SolAux),
	solucionColumna(SolAux, LongColumnas, PistasColumnas,SolucionAux).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

solucionFilas(Grilla ,LongAuxFilas,PistasFilas, Solucion):-
	solucionRec(Grilla,PistasFilas, LongAuxFilas, [], Solucion).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

solucionColumna(Grilla, LongAuxColumnas,PistasColumna, Solucion):-
	length(PistasColumna, L),
	trasponer(Grilla, L,[], ListaColumnas),
	solucionRec(ListaColumnas,PistasColumna, LongAuxColumnas,[], Solucion).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

solucionRec([Fila|Grilla] ,[Pista|ListaPistas], Longitud, Aux, Solucion):-
	findall(Fila, ( length(Fila, Longitud), controlarPistas(Pista, Fila)),Resultado),
	interseccion(Resultado,Longitud, Res),
	append(Aux,[Res],ListaSolucionFila),
	solucionRec(Grilla, ListaPistas, Longitud,ListaSolucionFila,Solucion).


solucionRec( [], [], _Longitud, Aux, Aux).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
calcularConsecutivos(0,[],[]).														   

calcularConsecutivos(0,[X|Filarestante],Filarestante):- X = "X".

calcularConsecutivos(N,[X|Filarestante],Filarestante2):- X = "#", N > 0, Naux is N-1,   
	calcularConsecutivos(Naux,Filarestante,Filarestante2).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
controlarPistas([0],[Y|Ys]):- Y = "X", controlarPistas([],Ys).
controlarPistas([],[Y|Ys]):- Y = "X", controlarPistas([],Ys).
controlarPistas([],[]).
controlarPistas([X|Xs], [Y|Ys]):- Y = "#", (   calcularConsecutivos(X,[Y|Ys],Res), controlarPistas(Xs,Res)).
controlarPistas([X|Xs], [Y|Ys]):- Y = "X", controlarPistas([X|Xs], Ys).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


interseccion( JugadasPosibles, Longitud, Salida):-
	AuxLongitud is Longitud -1,
	interseccionR( JugadasPosibles, AuxLongitud, [], Salida).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%caso base.
interseccionR(_,-1,Aux,Aux).

%% Caso: Agregar #
interseccionR(JugadasPosibles,AuxLongitud, Aux, Salida):-
	obtenerColumna(JugadasPosibles, AuxLongitud, ListaElementos),
	todosIguales("#", ListaElementos),
	append(["#"], Aux, ListaValida), % agrego # 
	AuxL is AuxLongitud - 1,
	interseccionR(JugadasPosibles,AuxL, ListaValida, Salida).

%% Caso: Agregar X
interseccionR(JugadasPosibles,AuxLongitud, Aux, Salida):-
	obtenerColumna(JugadasPosibles, AuxLongitud, ListaElementos),
	todosIguales("X", ListaElementos),
	append(["X"], Aux, ListaValida), % agrego X
	AuxL is AuxLongitud - 1,
	interseccionR(JugadasPosibles,AuxL, ListaValida, Salida).

%% Caso: Agregar espacio vacio 
interseccionR(JugadasPosibles,AuxLongitud,Aux,Salida):-
	append([_], Aux,ListaValida), % agrego vacio
	AuxL is AuxLongitud - 1,
	interseccionR(JugadasPosibles,AuxL , ListaValida,Salida).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

todosIguales(_Elem,[]).

todosIguales(Elem, [E|ListaE]):-
	E == Elem,
	todosIguales(Elem, ListaE).


solucionUnicaFila(Fila, PistaFila, Longitud, SolucionFila):-
	findall(Fila, ( length(Fila, Longitud), controlarPistas(PistaFila, Fila)), Resultado),
	interseccion(Resultado, Longitud, SolucionFila).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

trasponer( Grilla , Long, ListaAux, ListaColumnas):-
	Pos is Long - 1,   
	obtenerColumna(Grilla,Pos, AuxLista),
	append([AuxLista], ListaAux, ListaA),
	Pos \== -1 ->  trasponer(Grilla, Pos, ListaA, ListaColumnas) ; ListaColumnas = ListaAux.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

resolverTriviales(GrillaIn, PistasFila, PistasCol, LengthFila, LengthColum, GrillaAcomodada):-
	resolverFilaTrivial(GrillaIn, PistasFila, GrillaRes, LengthFila),
	trasponer(GrillaRes,LengthFila, [], ListaColumnas),
	resolverColumnaTrivial(ListaColumnas, PistasCol, GrillaResultado, LengthColum, 0),
	trasponer(GrillaResultado, LengthColum, [] , GrillaAcomodada).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

resolverFilaTrivial([], [], [], _).

resolverFilaTrivial([Fila|RestoGrilla], [Pista|RestoPista], [FilaSalida|RestoSalida], L):-
	esListaConUnicaSol(Pista, Fila),
	solucionUnicaFila(Fila, Pista, L, FilaSalida),
	resolverFilaTrivial(RestoGrilla, RestoPista, RestoSalida, L).
	

resolverFilaTrivial([Fila|Resto], [_Pista|RestoPista], [Fila|RestoSalida], L):-
	resolverFilaTrivial(Resto, RestoPista, RestoSalida, L).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

resolverColumnaTrivial([], [], [], _, _).

resolverColumnaTrivial([PrimerColumnaGrilla|Grilla], [Pista|RestoPista], [ColumnaSalida|RestoSalida],L,Indice):-
	IndiceAux is Indice +1,
	esListaConUnicaSol(Pista, PrimerColumnaGrilla),
	solucionUnicaFila(PrimerColumnaGrilla, Pista, L, ColumnaSalida), 
	resolverColumnaTrivial(Grilla, RestoPista, RestoSalida, L, IndiceAux).

resolverColumnaTrivial([PrimerColumnaGrilla|Grilla], [_Pista|RestoPista], [PrimerColumnaGrilla|RestoGrilla],Lpc,Indice):-
	resolverColumnaTrivial(Grilla, RestoPista, RestoGrilla, Lpc, Indice).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sumaPistasFila([], 0).
sumaPistasFila([Elemento | Lista], Suma) :-
	sumaPistasFila(Lista, SumaAux),
	Suma is SumaAux + Elemento.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
% Solucion unica si la cantidad de pistas + la Longitud de las pistas - 1 es igual a Longitud de la Lista

esUnicaSolucion(Suma_pistas, Longitud_pistas, Longitud_lista) :-
	(Suma_pistas + Longitud_pistas) - 1 =:= Longitud_lista.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%

esListaConUnicaSol(Lista_pistas, Lista_grilla) :-
	sumaPistasFila(Lista_pistas, Suma_pistas),
	length(Lista_pistas, Longitud_pistas),
	length(Lista_grilla, Longitud_lista),
	esUnicaSolucion(Suma_pistas, Longitud_pistas, Longitud_lista).

%%%%%%%%%%%%%%%%%%%%%%%%

completarGrilla(N, Grilla, LongFilas, LongColumnas, PistasFilas, PistasColumnas, SolucionFinal):-
	(     N \==1 -> SolucionFinal = Grilla, !;
	solucionFinal(Grilla, LongFilas, LongColumnas, PistasFilas, PistasColumnas, Aux),
	contieneCeldaVacia( Aux, M),
	completarGrilla(M, Aux, LongFilas, LongColumnas, PistasFilas, PistasColumnas,  SolucionFinal)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        

solucionFinal(Grilla, LongFilas, LongColumnas ,PistasFilas, PistasColumnas, SolucionFinal):-
	verificarGrillaFinal(Grilla, PistasFilas, GrillaNuevaA),
	trasponer(GrillaNuevaA,LongColumnas,[], GrillaCol),
	verificarGrillaFinal(GrillaCol, PistasColumnas,SolAux),
	trasponer(SolAux, LongFilas,[], SolucionFinal).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

verificarGrillaFinal(Grilla, PistasFila, Solucion):-
	verificarGrillaAux( Grilla, PistasFila, [], Solucion).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% caso base
verificarGrillaAux(  [] ,[], ListaAux, ListaAux).
	
%% Caso: Fila completa
verificarGrillaAux(  [Fila|Grilla] , [_P|PistasFila], ListaAux, Solucion):-
	filaCompleta(Fila),
	append(ListaAux, [Fila], ListaAux2),
	verificarGrillaAux( Grilla, PistasFila, ListaAux2, Solucion).

%% Caso: Fila incompleta
verificarGrillaAux(  [Fila|Grilla] , [Pista|PistasFila], ListaAux, Solucion):-
	length(Fila,N),
	solucionUnicaFila(Fila,Pista, N, Resultado),
	append(ListaAux, [Resultado], ListaAux2),
	verificarGrillaAux(Grilla,PistasFila, ListaAux2, Solucion).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

filaCompleta([]).
filaCompleta([Elem|Lista]):-
	forall(member(E,Elem), (E == "#"; E == "X")),
	filaCompleta(Lista).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

contieneCeldaVacia([Fila|Grilla] , N):-
	filaCompleta(Fila),
	contieneCeldaVacia(Grilla,N).
contieneCeldaVacia([],0).
contieneCeldaVacia(_Fila, 1). % lugar vacio
