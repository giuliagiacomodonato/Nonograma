import React, { useEffect, useState } from 'react';
import PengineClient from './PengineClient';
import Board from './Board';
import HandleClick from './HandleClick';

let pengine;

function Game() {

  const [grid, setGrid] = useState(null);
  const [rowsClues, setRowsClues] = useState(null);
  const [colsClues, setColsClues] = useState(null);
  const [waiting, setWaiting] = useState(false);
  const [clickActual, setClickActual] = useState("#");
  const [listaColumnaSatisfechaInicial, setListaColumnaSatisfechaInicial] = useState([]);
  const [listaFilaSatisfechaInicial, setListaFilaSatisfechaInicial] = useState([]);
  const [listaFilaSatisfecha, setListaFilaSatisfecha] = useState([]);
  const [listaColumnaSatisfecha, setListaColumnaSatisfecha] = useState([]);
  const [gameOver, setGameOver] = useState(false);
  const [gridSolucion, setGridSolucion] = useState(null);
  const [gridBackUp, setGridBackUp] = useState(null);
  const [ultimaJugada, setUltimaJugada] = useState([]);
  const [reset, setReset] = useState(false);
  const [gridInicial, setGridInicial] = useState(null);

  useEffect(() => {
     // Creation of the pengine server instance.    
    // This is executed just once, after the first render.    
    PengineClient.init(handleServerReady);
  }, []);

  function handleServerReady(instance) {
    pengine = instance;
    const queryS = 'init(RowClues, ColumClues, Grid)';
    setWaiting(true);
    pengine.query(queryS, (success, response) => {
      if (success) {
        const squaresS = JSON.stringify(response['Grid']).replaceAll('"_"', "_");
        const rowCluesProlog = JSON.stringify(response['RowClues']);
        const colCluesProlog = JSON.stringify(response['ColumClues']);
          const querySS = `solucionGrilla(${squaresS}, ${rowCluesProlog}, ${colCluesProlog}, GrillaNueva)`;
          pengine.query(querySS, (successS, responsee) => {
            if(successS){
              setGrid(response['Grid']);
              setRowsClues(response['RowClues']);
              setColsClues(response['ColumClues']);
              setListaFilaSatisfecha([...response['RowClues']].fill(false));
              setListaColumnaSatisfecha([...response['ColumClues']].fill(false));
              setGridSolucion(responsee['GrillaNueva']);
              setGridInicial(response['Grid']);
      
            }
             
          });
          verificarGrilla(instance, response['Grid'], response['RowClues'], response['ColumClues'] );
          setWaiting(false);
      }
      
    });
    
  }
 
  function verificarGrilla(instance, grilla, pistasFila, pistasCol) {
    // Build Prolog query to get the new satisfacion status of the relevant clues.
    const squaresS = JSON.stringify(grilla).replaceAll('"_"', '_'); // Remove quotes for variables.
    const rowsCluesS = JSON.stringify(pistasFila);
    const colsCluesS = JSON.stringify(pistasCol);
    
    // Initialize the satisfaction status arrays with false
    setListaFilaSatisfecha(new Array(grilla.length).fill(false));
    setListaColumnaSatisfecha(new Array(grilla[0].length).fill(false));

    pengine = instance;
    setWaiting(true);

    const queryS = `verificarPistasInciales(${squaresS}, ${rowsCluesS}, ${colsCluesS}, RowsSat, ColsSat)`;
    pengine.query(queryS, (success, response) => {
        if (success) {
            // Extract satisfaction status from response
            const filaS = new Array(grilla.length);
            const columnaS= new Array(grilla[0].length);
          
            for (let i = 0; i < response['RowsSat'].length; i++) {
              const [index, sat] = response['RowsSat'][i];
              if(filaS[index] == null){
                filaS[index] = sat;
              }
          }

          for (let i = 0; i < response['ColsSat'].length; i++) {
              const [index, sat] = response['ColsSat'][i];
              if(columnaS[index] == null){
                columnaS[index] = sat;
              }
          }
            setListaFilaSatisfecha(filaS);
            setListaColumnaSatisfecha(columnaS);
            setListaColumnaSatisfechaInicial(columnaS);  
            setListaFilaSatisfechaInicial(filaS);
            terminoJuego(filaS, columnaS);
        }

        setWaiting(false);
    });
}


  function handleClick(i, j) {
  // No action on click if we are waiting.
    if (waiting) {
      return;
    }
    // Build Prolog query to make a move and get the new satisfacion status of the relevant clues.    
    const squaresS = JSON.stringify(grid).replaceAll('"_"', '_'); // Remove quotes for variables. squares = [["X",_,_,_,_],["X",_,"X",_,_],["X",_,_,_,_],["#","#","#",_,_],[_,_,"#","#","#"]]
    const rowsCluesS = JSON.stringify(rowsClues);
    const colsCluesS = JSON.stringify(colsClues);
    let Elem = clickActual;
    if (clickActual === 'Pista'){
      Elem = gridSolucion[i][j];
    }    
    const queryS = `put("${Elem}", [${i},${j}], ${rowsCluesS}, ${colsCluesS}, ${squaresS}, ResGrid, RowSat, ColSat)`; // queryS = put("#",[0,1],[], [],[["X",_,_,_,_],["X",_,"X",_,_],["X",_,_,_,_],["#","#","#",_,_],[_,_,"#","#","#"]], GrillaRes, FilaSat, ColSat)
    setWaiting(true);
    pengine.query(queryS, (success, response) => {
      if (success) {
        setGrid(response['ResGrid']);
        let satisfaceF = listaFilaSatisfecha;
        let satisfaceC = listaColumnaSatisfecha;
        satisfaceF[i] = response['RowSat'];
        satisfaceC[j]  = response['ColSat'];
        setListaColumnaSatisfecha(satisfaceC);
        setListaFilaSatisfecha(satisfaceF);
        setUltimaJugada([i,j]);
        if(clickActual === "Pista"){
          setClickActual("#");
        }
        terminoJuego();
      }
      setWaiting(false);
    });
  }
  
  function terminoJuego(rowsSat, colsSat) {
    if(rowsSat != null && colsSat != null){
      for(let i = 0; i < rowsSat.length ; i++){
          if(rowsSat[i]===0){
          return;
          }
      }
      for(let j = 0; j < colsSat.length ; j++){ 
        if(colsSat[j]===0){
          return;
        }
      }
    setGameOver(true);
  }
    return;
  }

 
  if (!grid) {
    return null; // Or a loading indicator
  }


  function toggleSolution(){
    if (gridBackUp== null){
      setGridBackUp(grid);
      setGrid(gridSolucion);
      setWaiting(true);
    }
    else{
      setGrid(gridBackUp);
      setGridBackUp(null);
      setWaiting(false);
    }
 }

 function deshacer(){
  if(ultimaJugada.length !== 0){
    const squaresS = JSON.stringify(grid).replaceAll('"_"', '_'); // Remove quotes for variables. squares = [["X",_,_,_,_],["X",_,"X",_,_],["X",_,_,_,_],["#","#","#",_,_],[_,_,"#","#","#"]]
    const rowsCluesS = JSON.stringify(rowsClues);
    const colsCluesS = JSON.stringify(colsClues);
    let i = ultimaJugada[0];
    let j = ultimaJugada[1];
    const queryS = `put("_", [${i},${j}], ${rowsCluesS}, ${colsCluesS}, ${squaresS}, ResGrid, RowSat, ColSat)`; // queryS = put("#",[0,1],[], [],[["X",_,_,_,_],["X",_,"X",_,_],["X",_,_,_,_],["#","#","#",_,_],[_,_,"#","#","#"]], GrillaRes, FilaSat, ColSat)
    setWaiting(true);
    pengine.query(queryS, (success, response) => {
      if (success) {
        setGrid(response['ResGrid']);
        let satisfaceF = listaFilaSatisfecha;
        let satisfaceC = listaColumnaSatisfecha;
        satisfaceF[i] = response['RowSat'];
        satisfaceC[j]  = response['ColSat'];
        setListaColumnaSatisfecha(satisfaceC);
        setListaFilaSatisfecha(satisfaceF);
        setUltimaJugada([i,j]);
        terminoJuego();
      }
      setWaiting(false);
    });
  }
 }
 function reiniciar(){
  if(gridBackUp ==null){
    setGrid(gridInicial);
    verificarGrilla(pengine, gridInicial, rowsClues, colsClues);
    setReset(!reset); 
  }
 }
  function selectPista(){
    setClickActual("Pista");
  }

  function selectX() {
    setClickActual("X");
  }

  function selectPaint() {
    setClickActual("#");
  }

  function getRandomColor() {
    const colors = ['#f39c12', '#e74c3c', '#3498db', '#2ecc71', '#9b59b6', '#f1c40f', '#1abc9c', '#e67e22'];
    return colors[Math.floor(Math.random() * colors.length)];
  }

  let statusText = "En juego";
  const estadoDeJuego= gridBackUp == null ? "Mostrar Solución": "Ocultar Solucion";
  if (grid === null) {
    return null;
  }

  return (
    <div className="game">
      <Board
       grid={grid}
       rowsClues={rowsClues}
       colsClues={colsClues}
       rowSatisfactions={listaFilaSatisfecha} // Pass listaFilaSatisfecha as props
       colSatisfactions={listaColumnaSatisfecha} // Pass listaColumnaSatisfecha as props
       onClick={(i, j) => handleClick(i, j)}
      />
      <div className="botones">
        <HandleClick
          selectX={() => selectX()}
          selectPaint={() => selectPaint()}
        />
          <button className="botonpista" onClick = {() => selectPista()} style={{ backgroundColor:clickActual ==="Pista"? '#ffffff' : 'transparent' }}>
            {"Pista"}
            </button>    
          <button className="switch" onClick = {() => toggleSolution()}  style={{ backgroundColor: 'transparent' }}>
            {estadoDeJuego}
          </button>
      <div>
          <button className="deshacer" onClick ={()=>deshacer()} style={{ backgroundColor: 'transparent' }}>
            {"Deshacer"}
        </button>
        <button className="reiniciar" onClick ={()=>reiniciar()} style={{ backgroundColor: 'transparent' }}>
            {"Reiniciar"}
        </button>
      </div>
      </div>
  
      {gameOver && (
        <div className="confetti-container">
          {[...Array(2000)].map((_, index) => (
            <div
              className="confetti"
              key={index}
              style={{
                '--color': getRandomColor(),
                '--offset': Math.random() * 100,
                left: `${Math.random() * window.innerWidth}px`,
                top: `${Math.random() * window.innerHeight}px`
              }}
            ></div>
          ),
          statusText = "¡Ganaste!")}
        </div>
      )}
      <div className="status">{statusText}</div>
    </div>
  );
}

export default Game;