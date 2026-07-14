unit TAS;

{$mode ObjFPC}{$H+}

interface

uses tablasimbolos;

const
     Max = 15;
//limite arbitrario que determina la cantidad máxima de símbolos que puede tener el lado derecho de la regla más larga de la gramatica.

type
  tipoProduccion = record //registro que guarda las producciones de la TAS
    elem: array [1..Max] of TipoSimboloGramatical;
    cant:0..Max;
  end;

tipoTerminales = tProgram..pesos; //contiene todos los terminales de la tabla de simbolos
tipoVariables = vPrograma..vTipoEscritura; 

tablaTAS = array [tipoVariables , tipoTerminales] of ^tipoProduccion;

procedure InicializarTAS(var TAS:tablaTAS);

implementation

procedure InicializarTAS(var TAS:tablaTAS);
var
  i,j: tipoSimboloGramatical; // los elementos son del tipoSimboloGramtical
begin
     for i:= vPrograma to vTipoEscritura do // las filas son las variables y las columnas los terminales
         begin
              for j:= tProgram to pesos do
                  begin
                       TAS[i,j] := nil;  // inicializa las celdas de la tabla
                       if TAS[i,j] = nil then writeln (i,'  ',j);
                  end;
         end;
end ;
 
end.
