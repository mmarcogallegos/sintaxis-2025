unit TAS;

{$mode ObjFPC}{$H+}

interface

const
     Max = 15;
//limite arbitrario que determina la cantidad máxima de símbolos que puede tener el lado derecho de la regla más larga de la gramatica.
uses
  UnitTablaDeSimbolos;

type
  tipoProduccion = record //registro que guarda las producciones de la TAS
    elem: array [1..Max] of TipoSimboloGramatical;
    cant:0..Max;
  end;

//tipoVariables = desde la variable programa hasta la ultima VPROGRAM...
tipoTerminales = tProgram..error //contiene todos los terminales de la tabla de simbolos

tablaTAS = array [tipoVariables , tipoTerminales] of ^tipoProduccion;

implementation

{procedure InicializarTAS(var TAS:tablaTAS);
var
  i,j: tipoSimboloGramatical; // los elementos son del tipoSimboloGramtical
begin
     for i:= vProgam to .. do // las filas son las variables y las columnas los terminales
         begin
              for j:= tProgram to pesos do
                  begin
                       TAS[i,j] := nil;  // inicializa las celdas de la tabla
                  end;
         end;
end ;
 }
end.
