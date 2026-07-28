unit analizadorsintactico;

{$mode ObjFPC}{$H+}

interface

uses tablasimbolos , pila, arbol, TAS, analizadorlexico;

procedure ApilarPesos(var pila:tipoPila; var elementoPila:tipoElementoPila);
procedure ApilarSimboloInicial(var pila:tipoPila; var elementoPila:tipoElementoPila; var raiz:tipoArbolDerivacion);
procedure AnalizadorSintactico(var fuente:fileOfChar; var raiz:tipoArbolDerivacion; archivoTAS: string; var aux:byte);

implementation

procedure ApilarPesos(var pila:tipoPila; var elementoPila:tipoElementoPila);
begin
      elementoPila.simbolo := pesos;
      elementoPila.nodo := nil;
      Apilar(pila,elementoPila);
end;

procedure ApilarSimboloInicial(var pila:tipoPila; var elementoPila:tipoElementoPila; var raiz:tipoArbolDerivacion);
begin
      CrearNodo(raiz,vPrograma);          //Raiz^.simbolo := vPrograma 
      elementoPila.simbolo := vPrograma;
      elementoPila.nodo := raiz;
      Apilar(pila,elementoPila);
end;

procedure AnalizadorSintactico(var fuente:fileOfChar; var raiz:tipoArbolDerivacion; archivoTAS: string; var aux:byte);
var
      band:boolean;
      tablaSimbolos:TablaDeSimbolos;
      TAS:tablaTAS;
      pila:tipoPila;
      elementoPila:tipoElementoPila;
      control:longint;
      hijo:tipoArbolDerivacion;
      compLexico:TipoSimboloGramatical;
      lexem:string;
      j:integer;
      celdaAuxiliar:TipoSimboloGramatical;
begin
      aux:=1;
      GenerarTablaDeSimbolos(tablaSimbolos); //Carga palabras reservadas 

      InicializarTAS(TAS);                        
      CargarTAS(TAS,archivoTAS);             //Carga la TAS a partir del archivo ./csv

      CrearPila(pila);                       //Creamos la pila, apilamos pesos y luego el simbolo inicial (vPrograma)
      ApilarPesos(pila,elementoPila);
      ApilarSimboloInicial(pila,elementoPila,raiz);

      band := true;                          //Flag para cortar el ciclo si hace falta
      control := 0;

      ObtenerSiguienteComponenteLexico(fuente,control,compLexico,lexem,tablaSimbolos);    //Analizador lexico

      while (compLexico <> error) AND band do
            begin

                  Desapilar(pila,elementoPila);

                  if elementoPila.simbolo = pesos then   //Si llegamos al final de la pila (desapila pesos), el analizador lexico tambien nos debe devolver pesos
                        begin
                              if compLexico = pesos then 
                                    begin
                                          band := false; //Si el analizador lexico tambien devuelve pesos, la sintaxis es correcta y actualizamos la flag para salir del ciclo
                                    end
                              else 
                                    begin
                                          compLexico := error;
                                          writeln('ERROR SINTACTCIO: se esperaba pesos pero se ha encontrado: ', lexem);
                                          aux:=0; //Actualizamos el parametro para que no se ejecute el evaluador
                                    end;
                        end
                  else if elementoPila.simbolo in [tProgram..pesos] then //Vemos si es un terminal
                        begin
                              if elementoPila.simbolo = compLexico then //Si el tope de la pila es un terminal, debe ser igual que el componente lexico leido por el analizador lexico      
                                    begin
                                          elementoPila.nodo^.lexema := lexem;  //Asigna el lexema encontrado por el analizador lexico al arbol de derivacion
                                                                               //Solo actualizamos el lexema, ya que teoricamente debemos reemplazar el identificador por su lexema correspondiente
                                          ObtenerSiguienteComponenteLexico(fuente,control,compLexico,lexem,tablaSimbolos);
                                    end
                              else
                                    begin
                                          writeln('ERROR SINTACTICO: se esperaba el terminal ',elementoPila.simbolo, '  pero se ha encontrado: ', lexem);
                                          compLexico := error; //Si los terminales son distintos, le asignamos error al componente lexico para salir del ciclo
                                          aux:=0; //Actualizamos el parametro para que no se ejecute el evaluador
                                    end;
                        end
                              else if elementoPila.simbolo in [vPrograma..vTipoEscrituraII] then //Si el tope de la pila es una variable debemos ver la produccion de la TAS
                                    begin
                                          if TAS[elementoPila.simbolo,compLexico] <> nil then //Si tiene una produccion en la TAS en esa celda(no es NIL)
                                                begin
                                                      for j:=1 to TAS[elementoPila.simbolo,compLexico]^.cant do //Recorremos todas las producciones de esa celda
                                                            begin
                                                                  celdaAuxiliar:=TAS[elementoPila.simbolo,compLexico]^.elem[j]; //Utilizamos una variable auxiliar para almacenar el j-esimo simbolo gramatical de la celda
                                                                  CrearNodo(hijo,celdaAuxiliar);                                    //Creamos el nodo con el simbolo gramatical
                                                                  AgregarNodo(elementoPila.nodo,hijo);                              //Le agregamos el hijo al nodo de la pila
                                                            end;
                                                      ApilarCelda(TAS[elementoPila.simbolo,compLexico]^,elementoPila.nodo,pila); //Apilamos la celda al reves
                                                end
                                          else
                                                begin
                                                      writeln('ERROR SINTACTICO: No hay produccion en la TAS para la variable ', elementoPila.simbolo, ' con el terminal "', lexem, '" (', compLexico, ')');
                                                      compLexico := error;  //Si la celda posee NIL hay un error sintactico
                                                      aux:=0;
                                                end;
                                    end;
            end;
end;
end.
