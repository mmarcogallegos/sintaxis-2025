unit analizadorsintactico;

{$mode ObjFPC}{$H+}

interface

uses tablasimbolos , pilayarbol , TAS , analizadorlexico ;

procedure AnalizadorSintactico(var fuente:fileOfChar; var raiz:tipoArbolDerivacion; archivoTAS: string);

implementation

procedure AnalizadorSintactico(var fuente:fileOfChar; var raiz:tipoArbolDerivacion; archivoTAS: string);
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
      GenerarTablaDeSimbolos(tablaSimbolos); //Carga palabras reservadas
      InicializarTAS(TAS);                   
      CargarTAS(TAS,archivoTAS);  

      CrearPila(pila);
      elementoPila.simbolo := pesos;
      elementoPila.nodo := nil;
      Apilar(pila,elementoPila); //Apila pesos

      CrearNodo(raiz,vPrograma); 
      elementoPila.simbolo := vPrograma;
      elementoPila.nodo := raiz;
      Apilar(pila,elementoPila); //Luego apila el simbolo inicial

      band := true;
      control := 0;
      ObtenerSiguienteComponenteLexico(fuente,control,compLexico,lexem,tablaSimbolos);

      while (compLexico <> error) AND band do
            begin

                  Desapilar(pila,elementoPila);

                  if elementoPila.simbolo = pesos then   //Si llegamos al final de la pila, el analizador lexico tambien nos debe devolver pesos
                        begin
                              if compLexico = pesos then
                                    begin
                                          band := false;
                                    end
                              else 
                                    begin
                                          compLexico := error;
                                          writeln('ERROR SINTACTCIO: se esperaba pesos pero se ha encontrado: ', lexem);
                                    end;
                        end
                  else if elementoPila.simbolo in [tProgram..pesos] then //Vemos si es un terminal
                        begin
                              if elementoPila.simbolo = compLexico then //Si el tope de la pila es un terminal, debe ser igual que el componente lexico leido por el analizador lexico
                                    begin
                                          elementoPila.nodo^.lexema := lexem;  //Asigna el lexema al arbol de derivacion
                                          ObtenerSiguienteComponenteLexico(fuente,control,compLexico,lexem,tablaSimbolos);
                                    end
                              else
                                    begin
                                          writeln('ERROR SINTACTICO: se esperaba el terminal ',elementoPila.simbolo, '  pero se ha encontrado: ', lexem);
                                          compLexico := error; //Si los terminales son distintos, le asignamos error al componente lexico para salir del ciclo
                                    end;
                        end
                              else if elementoPila.simbolo in [vPrograma..vTipoEscrituraII] then //Si el tope de la pila es una variable debemos ver la produccion de la TAS
                                    begin
                                          if TAS[elementoPila.simbolo,compLexico] <> nil then //Si tiene una produccion en la TAS (no es NIL)
                                                begin
                                                      for j:=1 to TAS[elementoPila.simbolo,compLexico]^.cant do  
                                                            begin
                                                                  celdaAuxiliar:=TAS[elementoPila.simbolo,compLexico]^.elem[j]; //Utilizamos una variable auxiliar para almacenar el simbolo gramatical de la celda
                                                                  CrearNodo(hijo,celdaAuxiliar);  //Creamos el nodo con el simbolo gramatical
                                                                  AgregarNodo(elementoPila.nodo,hijo);
                                                            end;
                                                      ApilarCelda(TAS[elementoPila.simbolo,compLexico]^,elementoPila.nodo,pila);
                                                end
                                          else
                                                begin
                                                      writeln('ERROR SINTACTICO: No hay produccion en la TAS para la variable ', elementoPila.simbolo, ' con el token "', lexem, '" (', compLexico, ')');
                                                      compLexico := error;  //Si la celda posee NIL hay un error sintactico
                                                end;
                                    end;
            end;

            if compLexico <> error then
                  begin
                       // writeln('SINTAXIS VALIDA');
                  end
            else
                  begin
                        writeln('ERROR DE SINTAXIS');
                  end;
end;


end.
