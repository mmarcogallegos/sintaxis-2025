unit TAS;

{$mode ObjFPC}{$H+}

interface

uses crt, arbol, sysutils, CsvDocument, csvreadwrite, tablaSimbolos, pila;

const
      Max = 8;
//limite arbitrario que determina la cantidad máxima de símbolos que puede tener el lado derecho de la regla más larga de la gramatica.

type
  tipoProduccion = record //registro que guarda las producciones de la TAS
    elem: array [1..Max] of TipoSimboloGramatical;
    cant:0..Max;
  end;

tipoTerminales = tProgram..pesos; 
tipoVariables = vPrograma..vTipoEscrituraII; 

tablaTAS = array [tipoVariables , tipoTerminales] of ^tipoProduccion;

procedure InicializarTAS(var TAS:tablaTAS);
function ReadCSVCell(AFileName: String; ARow, ACol: Integer): String;
procedure CargarTAS(var TAS:tablaTAS ; archivoTAS:string);
Procedure ApilarCelda(var celda:tipoProduccion;var raiz:tipoArbolDerivacion;var pila:tipoPila);


implementation

procedure InicializarTAS(var TAS:tablaTAS);
var
  i,j: tipoSimboloGramatical; // los elementos son del tipoSimboloGramtical
begin
     for i:= vPrograma to vTipoEscrituraII do // las filas son las variables y las columnas los terminales
        begin
              for j:= tProgram to pesos do
                  begin
                        TAS[i,j] := nil;  // inicializa las celdas de la tabla
                  end;
        end;
end ;

function ReadCSVCell(AFileName: String; ARow, ACol: Integer): String;
var 
  CSVDoc:TCSVDocument;
begin
  CSVDoc := TCSVDocument.Create;
  try
    CSVDoc.Delimiter := ',';        //Las comas separan las celdas del archivo .csv
    CSVDoc.LoadFromFile(AFileName);         
    result := CSVDoc.Cells[ACol, ARow];
  finally
    CSVDoc.Free;
  end;
end;

procedure CargarTAS(var TAS:tablaTAS ; archivoTAS:string);
var
  fila,col,k:integer;
  arregloSimbolosAux:TStringArray; //Arreglo dinamico de cadenas
  i,j:TipoSimboloGramatical;
  celda:string;
begin
      for i:=vPrograma to vTipoEscrituraII do
        begin
              for j:=tProgram to pesos do
                begin

                      fila := ord(i) - ord(vPrograma) + 1 ;     //Ord devuelve la posicion del simbolo, como estan los terminales y las variables juntos hay que balancear los indices
                      col := ord(j) - ord(tProgram) + 1;
                      celda:=ReadCSVCell(archivoTAS,fila,col);  //Guarda la celda leida del archivo csv

                      if celda <> '' then                 //Ninguna celda que contenga informacion comienza con espacio en blanco
                        begin                          
                              NEW(TAS[i,j]);              //Esto no hace falta ya que se inicializa la tas previamente(?
                              if celda = 'EPS' then       //Si la celda del archivo .csv posee epsilon, solo se actualiza la cantidad en la TAS
                                begin
                                      TAS[i,j]^.cant:=0;
                                end
                                    else                  //Sino, se divide cada celda en un arreglo, donde cada posicion del arreglo es un simbolo gramatical pero representado como cadena
                                        begin
                                              arregloSimbolosAux := celda.Split([' ']);  //Toma las palabras separadas por espacios en blanco y crea un arreglo 
                                                                                         //Las producciones de las celdas tienen separados los simbolos por espacios en blanco
                                              for k:=0 to length(arregloSimbolosAux)-1 do   //Los arreglos del tipo TStringArray comienzan en cero
                                                  begin
                                                        TAS[i,j]^.elem[k+1] := StringToSimbolo(arregloSimbolosAux[k]);  
                                                        //StringToSimbolo lee cada simbolos de la celda e identifica si es un terminal o variable. Esto es necesario ya que la TAS guarda simbolos gramaticales, no cadenas. Es el "filtro" que convierte la cadena del archivo .csv a simbolo gramatical
                                                  end;
                                              TAS[i,j]^.cant:=k+1;        //Incrementa la cantidad de simbolos que contiene la celda de la TAS en memoria
                                              arregloSimbolosAux := nil;  //Limpia la variable auxiliar
                                        end;                            
                        end;
                end;
        end;
end;

Procedure ApilarCelda(var celda:tipoProduccion;var raiz:tipoArbolDerivacion;var pila:tipoPila);  //Apila las producciones de la celda en orden inverso
var
    i:integer;
    elementoPila:tipoElementoPila;
begin
      for i:=celda.cant downto 1 do //Recorre desde el ultimo simbolo hasta el primero
          begin
                elementoPila.simbolo := celda.elem[i];
                elementoPila.nodo := raiz^.hijos[i];
                Apilar(pila,elementoPila);
          end;
end;

end.
