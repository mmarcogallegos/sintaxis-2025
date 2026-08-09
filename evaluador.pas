unit evaluador;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, math, tablaSimbolos, pila, arbol;

const

      MaxVar = 200;  //define la cantidad maxima de variables que puede tener el programa

      MaxReal = 200;

      MaxCadena = 255;

type

    tipo = (tipoReal , tipoCadena);

    tipoElementoEstado = record

      lexemaId: string; //nombre de la variable

      tipoVariable: tipo;

      valorReal: real;  // si es de tipo real, contiene el valor

      valorCadena: string[MaxCadena]; 


    end;

    tipoEstado = record

      elemento: array[1..MaxVar] of tipoElementoEstado;

      cant:word;

    end;

    tipoValorDinamico = record      //Creamos este registro para no tener que pasar como parametros una variable real y una variable cadena
      tipoDato:tipo;                //Puede meterse este registro dentro de la definicion de estado(?
      valReal:real;
      valCadena:string[MaxCadena];
    end;



procedure InicializarEstado(var estado:tipoEstado);
procedure AgregarVar(var estado:tipoEstado; var lexema:string; var tipoVar:tipo);
procedure AsignarReal(var estado:tipoEstado; var lexema:string; resultadoReal:real);
procedure AsignarCadena(var estado:tipoEstado; var lexema:string; resultadoCadena:string);
function EliminarComillas(cadena:string):string;

procedure EvalPrograma(var arbol:tipoArbolDerivacion; var estado:tipoEstado);
procedure EvalDeclaracionVariables(var arbol:tipoArbolDerivacion; var estado:tipoEstado);
procedure EvalCuerpoVar(var arbol:tipoArbolDerivacion; var estado:tipoEstado);
procedure EvalCuerpoVarII(var arbol:tipoArbolDerivacion; var estado:tipoEstado);
function EvalTipoVar(var arbol:tipoArbolDerivacion):tipo;
procedure EvalCuerpo(var arbol:tipoArbolDerivacion; var estado:tipoEstado);
procedure EvalSentencia(var arbol:tipoArbolDerivacion; var estado:tipoEstado);
procedure EvalAsignacion(var arbol:tipoArbolDerivacion; var estado:tipoEstado);
procedure EvalExpresion(var arbol:tipoArbolDerivacion; var estado:tipoEstado; var resultado:tipoValorDinamico);  
procedure EvalExpresionII(var arbol:tipoArbolDerivacion; var estado:tipoEstado; var resultadoSubArbol:tipoValorDinamico; var resultado:tipoValorDinamico);
procedure EvalTermino(var arbol:tipoArbolDerivacion; var estado:tipoEstado; var resultado:tipoValorDinamico);
procedure EvalTerminoII(var arbol:tipoArbolDerivacion; var estado:tipoEstado; var resultadoSubArbol:tipoValorDinamico;var resultado:tipoValorDinamico);
procedure EvalFactor(var arbol:tipoArbolDerivacion; var estado:tipoEstado; var resultado:tipoValorDinamico);
procedure EvalFactorII(var arbol:tipoArbolDerivacion; var estado:tipoEstado; var resultadoSubArbol:tipoValorDinamico; var resultado:tipoValorDinamico);
procedure EvalMayorPrecedencia(var arbol:tipoArbolDerivacion; var estado:tipoEstado; var resultado:tipoValorDinamico);
procedure EvalCiclica(var arbol:tipoArbolDerivacion; var estado:tipoEstado);
procedure EvalCondicion(var arbol:tipoArbolDerivacion; var estado:tipoEstado; var resultado:boolean);
procedure EvalTerminoAnd(var arbol:tipoArbolDerivacion; var estado:tipoEstado; var resultado:boolean);
procedure EvalTerminoAndII(var arbol:tipoArbolDerivacion; var estado:tipoEstado; var cond:boolean; var resultado:boolean);
procedure EvalTerminoLogico(var arbol:tipoArbolDerivacion; var estado:tipoEstado; var resultado:boolean);
procedure EvalComparacion(var arbol:tipoArbolDerivacion; var estado:tipoEstado; var resultado:boolean);
procedure EvalCondicional(var arbol:tipoArbolDerivacion; var estado:tipoEstado);
procedure EvalCondicionalFin(var arbol:tipoArbolDerivacion; var estado:tipoEstado;var cond:boolean);
procedure EvalCondicionII(var arbol:tipoArbolDerivacion; var estado:tipoEstado; var cond:boolean; var resultado:boolean);
procedure EvalLectura(var arbol:tipoArbolDerivacion; var estado:tipoEstado);
procedure EvalLecturaII(var arbol:tipoArbolDerivacion; var estado:tipoEstado);
procedure EvalEscritura(var arbol:tipoArbolDerivacion; var estado:tipoEstado);
procedure EvalTipoEscritura(var arbol:tipoArbolDerivacion; var estado:tipoEstado);
procedure EvalTipoEscrituraII(var arbol:tipoArbolDerivacion; var estado:tipoEstado);


implementation


procedure InicializarEstado(var estado:tipoEstado);
begin
      estado.cant:= 0;
end;

procedure AgregarVar(var estado:tipoEstado; var lexema:string; var tipoVar:tipo);
begin
      inc(estado.cant);
      estado.elemento[estado.cant].lexemaId := lexema;
      case tipoVar of
            tipoCadena:begin estado.elemento[estado.cant].tipoVariable := tipoCadena; end;
            tipoReal:begin estado.elemento[estado.cant].tipoVariable := tipoReal; end;
      end;
end;

procedure AsignarReal(var estado:tipoEstado; var lexema:string; resultadoReal:real);            //Busca la variable en el estado, una vez enconotrada le asigna el valor
var
      i:integer;
begin
      for i:=1 to estado.cant do
      begin
            if (estado.elemento[i].lexemaId = lexema) and (estado.elemento[i].tipoVariable = tipoReal) then
                  begin
                        estado.elemento[i].valorReal:=resultadoReal;
                  end;
      end
end;

procedure AsignarCadena(var estado:tipoEstado; var lexema:string; resultadoCadena:string);       //Busca la variable en el estado, una vez enconotrada le asigna el valor
var
      i:integer;
begin
      for i:=1 to estado.cant do
      begin
            if (estado.elemento[i].lexemaId = lexema) and (estado.elemento[i].tipoVariable = tipoCadena) then
                  begin
                        estado.elemento[i].valorCadena:=resultadoCadena;
                  end;
      end
end;

function EliminarComillas(cadena:string):string;
begin
      if (length(cadena) >= 2) and (cadena[1]='"') and (cadena[length(cadena)] = '"') then //length(cadena) >= 2 ya que la cadena vacia seria: ""
      begin
            EliminarComillas:=copy(cadena,2,length(cadena)-2);
      end
      else
      begin
            EliminarComillas:=cadena;
      end;
end;

//<Programa> ::= “program” “identificador” “;” <DeclaracionVariables> “begin” <Cuerpo> “end” “.”

procedure EvalPrograma(var arbol:tipoArbolDerivacion; var estado:tipoEstado);
begin
      InicializarEstado(estado);
      EvalDeclaracionVariables(arbol^.hijos[4],estado);
      EvalCuerpo(arbol^.hijos[6],estado);
end;

//<DeclaracionVariables> ::= “var” <CuerpoVar> “end” “;” | “ε”

procedure EvalDeclaracionVariables(var arbol:tipoArbolDerivacion; var estado:tipoEstado);
begin
      if arbol^. cant <> 0 then
      begin
            EvalCuerpoVar(arbol^.hijos[2],estado);
      end;
end;

//<CuerpoVar> ::=  “identificador” “:” <TipoVar> ”;” <CuerpoVarII>

procedure EvalCuerpoVar(var arbol:tipoArbolDerivacion; var estado:tipoEstado);
var
      resultadoTipo:tipo;
begin
      resultadoTipo:=EvalTipoVar(arbol^.hijos[3]);                //Evalua si la variable es una cadena o real, para luego agregarla al estado
      AgregarVar(estado,arbol^.hijos[1]^.lexema,resultadoTipo);   //Como el lexema correspondiente a identificador es el nombre de la variable, lo agregamos en estado
      EvalCuerpoVarII(arbol^.hijos[5],estado);                    //Evalua el subarbol correspondiente a CuerpoVarII
end;

//<CuerpoVarII> ::= <CuerpoVar> | “ε”

procedure EvalCuerpoVarII(var arbol:tipoArbolDerivacion; var estado:tipoEstado);
begin
      if arbol^.cant <> 0 then
      begin
            EvalCuerpoVar(arbol^.hijos[1],estado);
      end;
end;

//<TipoVar> ::= “real” | “cadena”

function EvalTipoVar(var arbol:tipoArbolDerivacion):tipo;
begin
      case arbol^.hijos[1]^.simbolo of
            tReal:
                  begin 
                        EvalTipoVar:=tipoReal; 
                  end;
            tCadena:
                  begin 
                        EvalTipoVar:=tipoCadena; 
                  end;   
      end;
end;

//<Cuerpo> ::= <Sentencia> ”;” <Cuerpo>  | “ε”

procedure EvalCuerpo(var arbol:tipoArbolDerivacion; var estado:tipoEstado);
begin
      if arbol^.cant <> 0 then
      begin
            EvalSentencia(arbol^.hijos[1],estado);
            EvalCuerpo(arbol^.hijos[3],estado);
      end;
end;

//<Sentencia> ::=  <Asignacion> | <Lectura> | <Escritura> | <Condicional> | <Ciclica>

procedure EvalSentencia(var arbol:tipoArbolDerivacion; var estado:tipoEstado);
begin
      case arbol^.hijos[1]^.simbolo of
      vAsignacion: begin EvalAsignacion(arbol^.hijos[1],estado); end;
      vLectura: begin EvalLectura(arbol^.hijos[1],estado); end;
      vEscritura: begin EvalEscritura(arbol^.hijos[1],estado); end;
      vCondicional: begin EvalCondicional(arbol^.hijos[1],estado); end;
      vCiclica: begin EvalCiclica(arbol^.hijos[1],estado); end;
      end;
end;

//<Asignacion> ::= “identificador” “operadorAsignacion” <Expresion>

procedure EvalAsignacion(var arbol:tipoArbolDerivacion; var estado:tipoEstado);
var
      nombreVariable:string;
      resultadoSubArbol,resultado:tipoValorDinamico;
      variableEncontrada:boolean;
      i:integer;
begin
      if arbol^.hijos[1]^.simbolo = tIdentificador then
      begin

            nombreVariable:= arbol^.hijos[1]^.lexema;  //"identificador" es el componente lexico correspondiente a la variable
            variableEncontrada:=false;

            for i:=1 to estado.cant do          //Buscamos la variable en el estado
            begin
                  if estado.elemento[i].lexemaID = nombreVariable then
                  begin

                        variableEncontrada:=true;
                        resultado.tipoDato:=estado.elemento[i].tipoVariable;  //Primero obtenemos el tipo de dato de la variable

                        if resultado.tipoDato = tipoReal then     
                        begin
                              resultado.valReal:=estado.elemento[i].valorReal;
                        end
                        else
                        begin
                              resultado.valCadena:=estado.elemento[i].valorCadena;
                        end;
                  end;
            end;

            if NOT variableEncontrada then
            begin
                  writeln();
                  writeln('VARIABLE NO DECLARADA: ',nombreVariable);
                  halt;
            end;

            EvalExpresion(arbol^.hijos[3],estado,resultadoSubArbol);         //Le pasamos el id a evaluar expresion ya que no podemos distinguir asignaciones de cadenas y reales 
            
            if resultado.tipoDato <> resultadoSubArbol.tipoDato then
            begin
                  writeln();
                  writeln('NO COINCIDEN LOS TIPOS DE ASIGNACION');
                  halt;
            end;

            case resultadoSubArbol.tipoDato of
                  tipoReal:
                        begin 
                              AsignarReal(estado,nombreVariable,resultadoSubArbol.valReal);     //Solo actualizamos los valores de las variables en la asignacion
                        end;
                  tipoCadena:    
                        begin
                              AsignarCadena(estado,nombreVariable,resultadoSubArbol.valCadena);
                        end;
            end;
      end;
end;

//<Expresion> ::= <Termino> <ExpresionII>

procedure EvalExpresion(var arbol:tipoArbolDerivacion; var estado:tipoEstado; var resultado:tipoValorDinamico);  
var
      resultadoSubArbol:tipoValorDinamico;
begin
      EvalTermino(arbol^.hijos[1],estado,resultadoSubArbol);          
      EvalExpresionII(arbol^.hijos[2],estado,resultadoSubArbol,resultado);
end;

//<ExpresionII> ::= “+” <Termino> <ExpresionII> | “-” <Termino> <ExpresionII> | “concatenacion” <Termino> <ExpresionII> | “ε” 

procedure EvalExpresionII(var arbol:tipoArbolDerivacion; var estado:tipoEstado; var resultadoSubArbol:tipoValorDinamico; var resultado:tipoValorDinamico);
var
      resultadoSubArbolDos:tipoValorDinamico;
begin
      if arbol^.cant <> 0 then
      begin
            case arbol^.hijos[1]^.simbolo of
                  tMas: 
                        begin
                              EvalTermino(arbol^.hijos[2],estado,resultadoSubArbolDos);                                 //Primero evalua el subarbol para saber que sigue luego de "+"
                              resultadoSubArbol.valReal:=resultadoSubArbol.valReal + resultadoSubArbolDos.valReal;      //Actualizamos el resultado del parametro, con el valor que nos ha devuelto EvalTermino
                              EvalExpresionII(arbol^.hijos[3],estado,resultadoSubArbol,resultado);                      //Ahora volvemos a llamar al procedimiento pero con el valor actualizaco
                        end;                                                                                            //Lo mismo sucede para las demas situaciones del case
                  tMenos:  
                        begin
                              EvalTermino(arbol^.hijos[2],estado,resultadoSubArbolDos);
                              resultadoSubArbol.valReal:=resultadoSubArbol.valReal - resultadoSubArbolDos.valReal;
                              EvalExpresionII(arbol^.hijos[3],estado,resultadoSubArbol,resultado);
                        end;
                  tConcatenacion:
                        begin
                              EvalTermino(arbol^.hijos[2],estado,resultadoSubArbolDos);
                              resultadoSubArbol.valCadena:=concat(resultadoSubArbol.valCadena,resultadoSubArbolDos.valCadena);
                              EvalExpresionII(arbol^.hijos[3],estado,resultadoSubArbol,resultado);
                        end;
            end;
      end
      else
      begin
            resultado.valReal:=resultadoSubArbol.valReal;         //Si <ExpresionII> se hace epsilon, le asignamos al parametro los valores correspondientes    
            resultado.valCadena:=resultadoSubArbol.valCadena;
            resultado.tipoDato:=resultadoSubArbol.tipoDato;
      end;
end;

//<Termino> ::= <Factor> <TerminoII>

procedure EvalTermino(var arbol:tipoArbolDerivacion; var estado:tipoEstado; var resultado:tipoValorDinamico);
var
      resultadoSubArbol:tipoValorDinamico;
begin
      EvalFactor(arbol^.hijos[1],estado,resultadoSubArbol);
      EvalTerminoII(arbol^.hijos[2],estado,resultadoSubArbol,resultado);
end;

//<TerminoII> ::= “*” <Factor> <TerminoII> | “/” <Factor> <TerminoII> | “ε” 

procedure EvalTerminoII(var arbol:tipoArbolDerivacion; var estado:tipoEstado; var resultadoSubArbol:tipoValorDinamico;var resultado:tipoValorDinamico);
var   
      resultadoSubArbolDos:tipoValorDinamico;
begin
      if arbol^.cant <> 0 then
      begin
            case arbol^.hijos[1]^.simbolo of
                  tProducto:
                        begin
                              EvalFactor(arbol^.hijos[2],estado,resultadoSubArbolDos);
                              resultadoSubArbol.valReal:=resultadoSubArbol.valReal * resultadoSubArbolDos.valReal;
                              EvalTerminoII(arbol^.hijos[3],estado,resultadoSubArbol,resultado);
                        end;
                  tDivision:
                        begin

                              EvalFactor(arbol^.hijos[2],estado,resultadoSubArbolDos);

                              if resultadoSubArbolDos.valReal <> 0 then
                              begin
                                    resultadoSubArbol.valReal:=resultadoSubArbol.valReal / resultadoSubArbolDos.valReal;
                                    EvalTerminoII(arbol^.hijos[3],estado,resultadoSubArbol,resultado);
                              end
                              else
                              begin
                                    writeln('ERROR. DIVISION POR CERO');
                                    halt;
                              end;
                        end;
            end;
      end
      else
      begin
            resultado.valReal := resultadoSubArbol.valReal;         
            resultado.valCadena := resultadoSubArbol.valCadena;
            resultado.tipoDato := resultadoSubArbol.tipoDato;    
      end;
end; 

//<Factor> ::= <MayorPrecedencia> <FactorII>

procedure EvalFactor(var arbol:tipoArbolDerivacion; var estado:tipoEstado; var resultado:tipoValorDinamico);
var
      resultadoSubArbol:tipoValorDinamico;
begin
      EvalMayorPrecedencia(arbol^.hijos[1],estado,resultadoSubArbol);
      EvalFactorII(arbol^.hijos[2],estado,resultadoSubArbol,resultado);
end;

//<FactorII> ::= “^” <MayorPrecedencia> <FactorII> | “ε” 

procedure EvalFactorII(var arbol:tipoArbolDerivacion; var estado:tipoEstado; var resultadoSubArbol:tipoValorDinamico; var resultado:tipoValorDinamico);
var
      resultadoSubArbolDos:tipoValorDinamico;
begin


      //<Factor> ::= <MayorPrecedencia> <FactorII>
      //<Factor> ::= <MayorPrecedencia> “^” <MayorPrecedencia> <FactorII>
      //<Factor> ::= <MayorPrecedencia> “^” <MayorPrecedencia> 

      if arbol^.cant <> 0 then
      begin
            if (arbol^.hijos[1]^.simbolo = tPotencia) AND (resultadoSubArbol.tipoDato = tipoReal) then
                  begin

                        EvalMayorPrecedencia(arbol^.hijos[2],estado,resultadoSubArbolDos);
                        
                        if resultadoSubArbolDos.tipoDato = tipoReal then
                        begin
                              if (resultadoSubArbolDos.valReal <> 0) AND (resultadoSubArbol.valReal <> 0) then
                              begin

                                    resultadoSubArbol.valReal:= power(resultadoSubArbol.valReal,resultadoSubArbolDos.valReal);
                                    EvalFactorII(arbol^.hijos[3],estado,resultadoSubArbol,resultado);

                              end
                              else if (resultadoSubArbolDos.valReal = 0) AND (resultadoSubArbol.valReal <> 0) then
                              begin
                                    resultado.valReal:=1;
                              end
                              else if (resultadoSubArbolDos.valReal <> 0) AND (resultadoSubArbol.valReal = 0) then
                              begin
                                    resultado.valReal:=0;
                              end
                              else
                              begin
                                    writeln('ERROR. INDETERMINACION');
                                    halt;
                              end;
                        end
                        else
                        begin
                              writeln('ERROR. INGRESE UN NUMERO');
                              halt;
                        end;
                  end
                  else if (resultadoSubArbol.tipoDato = tipoCadena) then
                  begin
                        writeln('ERROR. INGRESE UN NUMERO');
                        halt;
                  end;
      end
      else
      begin
            resultado.valReal := resultadoSubArbol.valReal;         
            resultado.valCadena := resultadoSubArbol.valCadena;
            resultado.tipoDato := resultadoSubArbol.tipoDato;    
      end;
end;

//<MayorPrecedencia> ::= “constanteReal” | “constanteCadena” | “identificador” | “(” <Expresion> “)” | “raiz” “(” <Expresion> “)” | “extraerSubcadena” “(” <Expresion> “,” <Expresion> “,” <Expresion> “)” | ”buscarSubcadena” “(” <Expresion> “,” <Expresion> “)” | “longitudCadena” “(” <Expresion> “)” | “-” <MayorPrecedencia>

procedure EvalMayorPrecedencia(var arbol:tipoArbolDerivacion; var estado:tipoEstado; var resultado:tipoValorDinamico);
var   
      aux,i,posicion,longitud:integer;
      nombreVar:string;
      resultadoSubArbol, resultadoSubArbolDos, resultadoSubArbolTres:tipoValorDinamico;
      variableEncontrada:boolean;
begin
      
      case arbol^.hijos[1]^.simbolo of
      tConstanteReal:
            begin
                  val(arbol^.hijos[1]^.lexema,resultado.valReal,aux);
                  resultado.tipoDato:=tipoReal;
            end;
      tConstanteCadena:
            begin
                  resultado.valCadena:=EliminarComillas(arbol^.hijos[1]^.lexema);
                  resultado.tipoDato:=tipoCadena;
            end;
      tIdentificador:                                                               //Si es una variable, debemos buscarla en el estado
            begin

                  nombreVar:=arbol^.hijos[1]^.lexema;
                  variableEncontrada:=false;

                  for i:=1 to estado.cant do
                  begin
                        if estado.elemento[i].lexemaId = nombreVar then       //Recorremos el estado buscando la variable para obtener su valor
                        begin

                              resultado.tipoDato:=estado.elemento[i].tipoVariable;
                              variableEncontrada:=true;
                              
                              if resultado.tipoDato = tipoReal then
                              begin
                                    resultado.valReal:=estado.elemento[i].valorReal;
                              end
                              else
                              begin
                                    resultado.valCadena:=estado.elemento[i].valorCadena;
                              end;
                        end;
                  end;

                  if NOT variableEncontrada then
                  begin
                        writeln('VARIABLE NO DECLARADA: ',nombreVar);
                        halt;
                  end;

            end;
      tParentesisAbre:
            begin

                  EvalExpresion(arbol^.hijos[2],estado,resultadoSubArbol);   

                  case resultadoSubArbol.tipoDato of
                        tipoCadena: 
                              begin 
                                    resultado.valCadena := resultadoSubArbol.valCadena;
                                    resultado.tipoDato := tipoCadena;
                              end;
                        tipoReal: 
                              begin 
                                    resultado.valReal := resultadoSubArbol.valReal; 
                                    resultado.tipoDato := tipoReal;
                              end;
                  end;
            end;
      tRaiz:
            begin

                  EvalExpresion(arbol^.hijos[3],estado,resultadoSubArbol);

                  if resultadoSubArbol.tipoDato = tipoReal then
                  begin

                        if resultadoSubArbol.valReal >= 0 then
                        begin
                              resultado.valReal:=sqrt(resultadoSubArbol.valReal);
                              resultado.tipoDato:=tipoReal;
                        end
                        else
                        begin;
                              writeln();
                              writeln('ERROR. ARGUMENTO NEGATIVO');
                              halt;
                        end;
                  end
                  else
                  begin 
                        writeln();
                        writeln('ERROR. DEBE INGRESAR UN REAL');
                        halt;    
                  end;
            end;
      tExtraerSubcadena:
            begin

                  EvalExpresion(arbol^.hijos[3],estado,resultadoSubArbol);     
                  EvalExpresion(arbol^.hijos[5],estado,resultadoSubArbolDos);       
                  EvalExpresion(arbol^.hijos[7],estado,resultadoSubArbolTres);

                  if (resultadoSubArbol.tipoDato = tipoCadena) AND (resultadoSubArbolDos.tipoDato = tipoReal) AND (resultadoSubArbolTres.tipoDato = tipoReal) then
                  begin
                        resultado.valCadena:=copy(resultadoSubArbol.valCadena,trunc(resultadoSubArbolDos.valReal),trunc(resultadoSubArbolTres.valReal));

                        resultado.tipoDato:=tipoCadena;
                  end
                  else
                  begin
                        writeln();
                        writeln('ERROR DE PARAMETROS');

                        if NOT (resultadoSubArbol.tipoDato = tipoCadena) then
                        begin
                              writeln('SE ESPERABA UNA CADENA COMO PRIMER PARAMETRO, PERO SE HA ENCONTRADO: ', resultadoSubArbol.tipoDato);
                        end;

                        if NOT (resultadoSubArbolDos.tipoDato = tipoReal) then
                        begin
                              writeln('SE ESPERABA UN REAL COMO SEGUNDO PARAMETRO, PERO SE HA ENCONTRADO: ', resultadoSubArbolDos.tipoDato);
                        end;

                        if NOT (resultadoSubArbolTres.tipoDato = tipoReal) then
                        begin
                              writeln('SE ESPERABA UN REAL COMO TERCER PARAMETRO, PERO SE HA ENCONTRADO: ', resultadoSubArbolTres.tipoDato);
                        end;

                        writeln('ERROR DE PARAMETROS');
                        halt;
                  end; 

            end;
      tBuscarSubcadena:
            begin

                  EvalExpresion(arbol^.hijos[3],estado,resultadoSubArbol);     
                  EvalExpresion(arbol^.hijos[5],estado,resultadoSubArbolDos); 

                  if (resultadoSubArbol.tipoDato = tipoCadena) AND (resultadoSubArbolDos.tipoDato = tipoCadena) then
                  begin
                        posicion:=pos(resultadoSubArbol.valCadena,resultadoSubArbolDos.valCadena);   //Busca la primera en la segunda
                        if posicion = 0 then
                        begin
                              resultado.valReal:=-1;
                        end
                        else
                        begin
                              resultado.valReal:=posicion;
                        end;

                        resultado.tipoDato:=tipoReal;

                  end
                  else
                  begin
                        writeln();
                        if NOT(resultadoSubArbol.tipoDato = tipoCadena) then
                        begin
                              writeln('SE ESPERABA UNA CADENA COMO PRIMER PARAMETRO PERO SE HA ENCONTRADO: ',resultadoSubArbol.tipoDato);
                        end;

                        if NOT(resultadoSubArbolDos.tipoDato = tipoCadena) then
                        begin
                              writeln('SE ESPERABA UNA CADENA COMO SEGUNDO PARAMETRO PERO SE HA ENCONTRADO: ',resultadoSubArbolDos.tipoDato);
                        end;
                        halt;
                  end;

            end;
      tLongitudCadena:
            begin

                  EvalExpresion(arbol^.hijos[3],estado,resultadoSubArbol);  

                  if resultadoSubArbol.tipoDato = tipoCadena then
                  begin
                        longitud:=length(resultadoSubArbol.valCadena);

                        resultado.tipoDato:=tipoReal;

                        resultado.valReal:=longitud;

                  end
                  else
                  begin
                        writeln();
                        writeln('SE ESPERABA UNA CADENA PERO SE HA ENCONTRADO: ',resultadoSubArbol.tipoDato);
                        halt;
                  end;

            end;
      tMenos:
            begin
                  EvalMayorPrecedencia(arbol^.hijos[2],estado,resultadoSubArbol);       
                  resultado.valReal:=-resultadoSubArbol.valReal;
                  resultado.tipoDato:=tipoReal;
            end;
      end;
end;

//<Ciclica> ::= “while” <Condicion> “do” <Cuerpo> “end”

procedure EvalCiclica(var arbol:tipoArbolDerivacion; var estado:tipoEstado);
var 
      cond:boolean;
begin

      EvalCondicion(arbol^.hijos[2],estado,cond);

      while cond do
      begin

            EvalCuerpo(arbol^.hijos[4],estado);
            
            EvalCondicion(arbol^.hijos[2],estado,cond);     //Vuelve a evaluar la condicion para saber cuando tiene que salir del ciclo(?)
      end;
end;

//<Condicion> ::= <TerminoAnd> <CondicionII>

procedure EvalCondicion(var arbol:tipoArbolDerivacion; var estado:tipoEstado; var resultado:boolean);
var
      cond:boolean;
begin
      EvalTerminoAnd(arbol^.hijos[1],estado,cond);
      EvalCondicionII(arbol^.hijos[2],estado,cond,resultado);
end;

//<CondicionII> ::= “operadorLogicoOr” <TerminoAnd> <CondicionII> | “ε”

procedure EvalCondicionII(var arbol:tipoArbolDerivacion; var estado:tipoEstado; var cond:boolean; var resultado:boolean);
var
      resultadoSubArbol:boolean;
begin
      if arbol^.cant <> 0 then
      begin
            EvalTerminoAnd(arbol^.hijos[2],estado,resultadoSubArbol);
            cond:= cond OR resultadoSubArbol;
            EvalCondicionII(arbol^.hijos[3],estado,cond,resultado);
      end
      else
      begin
            resultado:=cond;
      end;
end;

//<TerminoAnd> ::= <TerminoLogico> <TerminoAndII>

procedure EvalTerminoAnd(var arbol:tipoArbolDerivacion; var estado:tipoEstado; var resultado:boolean);
var
      resultadoSubArbol:boolean;
begin
      EvalTerminoLogico(arbol^.hijos[1],estado,resultadoSubArbol);
      EvalTerminoAndII(arbol^.hijos[2],estado,resultadoSubArbol,resultado);
end;

//<TerminoAndII> ::= “operadorLogicoAnd” <TerminoLogico> <TerminoAndII> | “ε”

procedure EvalTerminoAndII(var arbol:tipoArbolDerivacion; var estado:tipoEstado; var cond:boolean; var resultado:boolean);
var
      resultadoSubArbol:boolean;
begin
      if arbol^.cant <> 0 then
      begin
            EvalTerminoLogico(arbol^.hijos[2],estado,resultadoSubArbol);
            cond:= cond AND resultadoSubArbol;
            EvalTerminoAndII(arbol^.hijos[3],estado,cond,resultado);
      end
      else
      begin
            resultado:=cond;
      end;
end;

//<TerminoLogico> ::= “operadorLogicoNot” <Comparacion> | <Comparacion>

procedure EvalTerminoLogico(var arbol:tipoArbolDerivacion; var estado:tipoEstado; var resultado:boolean);
var
      resultadoSubArbol:boolean;
begin
      if arbol^.hijos[1]^.simbolo = tOperadorLogicoNOT then
      begin
            EvalComparacion(arbol^.hijos[2],estado,resultadoSubArbol);
            resultado:=NOT resultadoSubArbol;
      end
      else
            EvalComparacion(arbol^.hijos[1],estado,resultado);
end;

//<Comparacion> ::= <Expresion> “operadorRelacional” <Expresion>

procedure EvalComparacion(var arbol:tipoArbolDerivacion; var estado:tipoEstado; var resultado:boolean);
var
      resultadoSubArbolUno:tipoValorDinamico;
      resultadoSubArbolDos:tipoValorDinamico;
begin

      EvalExpresion(arbol^.hijos[1],estado,resultadoSubArbolUno);

      EvalExpresion(arbol^.hijos[3],estado,resultadoSubArbolDos);

      if (resultadoSubArbolUno.tipoDato = tipoReal) AND (resultadoSubArbolDos.tipoDato = tipoReal) then
      begin
            case arbol^.hijos[2]^.lexema of
            '=':begin resultado:= resultadoSubArbolUno.valReal = resultadoSubArbolDos.valReal end;
            '<>':begin resultado:= resultadoSubArbolUno.valReal <> resultadoSubArbolDos.valReal end;
            '>=':begin resultado:= resultadoSubArbolUno.valReal >= resultadoSubArbolDos.valReal end;
            '<=':begin resultado:= resultadoSubArbolUno.valReal <= resultadoSubArbolDos.valReal end;
            '<':begin resultado:= resultadoSubArbolUno.valReal < resultadoSubArbolDos.valReal end;
            '>':begin resultado:= resultadoSubArbolUno.valReal > resultadoSubArbolDos.valReal end;
            end;
      end
      else if (resultadoSubArbolUno.tipoDato = tipoCadena) AND (resultadoSubArbolDos.tipoDato = tipoCadena) then
      begin
            case arbol^.hijos[2]^.lexema of
            '=':begin resultado:= resultadoSubArbolUno.valCadena = resultadoSubArbolDos.valCadena end;
            '<>':begin resultado:= resultadoSubArbolUno.valCadena <> resultadoSubArbolDos.valCadena end;
            '>=':begin resultado:= resultadoSubArbolUno.valCadena >= resultadoSubArbolDos.valCadena end;
            '<=':begin resultado:= resultadoSubArbolUno.valCadena <= resultadoSubArbolDos.valCadena end;
            '<':begin resultado:= resultadoSubArbolUno.valCadena < resultadoSubArbolDos.valCadena end;
            '>':begin resultado:= resultadoSubArbolUno.valCadena > resultadoSubArbolDos.valCadena end;
            end;      
      end
      else
      begin 
            writeln();
            writeln('ERROR: TIPOS DE COMPARACION');
            halt;
      end;
end;

//<Condicional> ::= “if” <Condicion> “then” <Cuerpo> <CondicionalFin>

procedure EvalCondicional(var arbol:tipoArbolDerivacion; var estado:tipoEstado);
var
      cond:boolean;
begin
      EvalCondicion(arbol^.hijos[2],estado,cond);

      if cond then
      begin
            EvalCuerpo(arbol^.hijos[4],estado);       //No se evalua de nuevo la condicion por no ser un ciclo, a comparacion del ciclo while
      end;

      EvalCondicionalFin(arbol^.hijos[5],estado,cond);
end;

//<CondicionalFin>::= “end” | “else” <Cuerpo> “end”

procedure EvalCondicionalFin(var arbol:tipoArbolDerivacion; var estado:tipoEstado;var cond:boolean);
begin
      if arbol^.hijos[1]^.simbolo = tElse then
      begin
            if NOT cond then                         
            begin
                  EvalCuerpo(arbol^.hijos[2],estado);
            end;
      end;
end;

//<Lectura> ::= “read” “(” <LecturaII> 

procedure EvalLectura(var arbol:tipoArbolDerivacion; var estado:tipoEstado);
begin
      EvalLecturaII(arbol^.hijos[3],estado);
end;

//<LecturaII> ::= “constanteCadena” “,” ”identificador”)” | “identificador” “)”

procedure EvalLecturaII(var arbol:tipoArbolDerivacion; var estado:tipoEstado);
var
      cadenaEntrada, nombreVariable:string;
      tipoVariableEncontrada:tipoValorDinamico;
      aux,i:integer;
      band:boolean;
      res:real;
begin

      band:=false;

      // <Lectura> ::= “read” “(” “identificador” “)”
      // <Lectura> ::= “read” “(” “constanteCadena” “,” ”identificador”)”

      if arbol^.hijos[1]^.simbolo = tIdentificador then
      begin
            nombreVariable:= arbol^.hijos[1]^.lexema;       //Si solo hay que leer una variable, guardamos su identificador para luego buscarla en el estado
      end
      else
      begin
            write(EliminarComillas(arbol^.hijos[1]^.lexema));
            nombreVariable:=arbol^.hijos[3]^.lexema;        //Si hay un texto en pantalla, hacemos lo mismo pero buscando en otro hijo del arbol
      end;

      for i:=1 to estado.cant do                            //Buscamos en el estado la variable 
      begin
            if estado.elemento[i].lexemaId = nombreVariable then
            begin
                  tipoVariableEncontrada.tipoDato := estado.elemento[i].tipoVariable;     //Guardamos en una variable auxiliar el tipo de dato que es la variables encontrada
                  band:=true;
            end;
      end;

      if NOT band then              //Si el identificador no coincide con ninguna variable del estado, no ha sido declarada y devuelve error del programa
      begin
            writeln();
            writeln('VARIABLE NO DECLARADA: ',nombreVariable);
            halt;
      end;

      
      readln(cadenaEntrada);  //cadenaEntrada es el valor que se le asignara a la variable
                              //tipoVariableEncontrada podria ser definida como 'tipo'

      if tipoVariableEncontrada.tipoDato = tipoReal then         //Si la cadena de entrada es un numero, debe coincidir con el tipo de declaracion de la variable     
      begin

            val(cadenaEntrada,res,aux);   //Convierte cadenaEntrada a real, si es real. Guarda el resultado en res
            
            if aux = 0 then
            begin
                  AsignarReal(estado,nombreVariable,res);   //Si la funcion val() no da error, actualiza el valor real en el estado
            end
            else
            begin
                  writeln();
                  writeln('ERROR DE TIPOS: SE ESPERABA UN NUMERO PARA ',nombreVariable);
                  halt;
            end;

      end
      else    //Si la cadena de entrada es una cadena, debe coincidir con el tipo de declaracion de la variable
      begin
            AsignarCadena(estado,nombreVariable,cadenaEntrada);
      end;

end;

//<Escritura> ::= “write” “(” <TipoEscritura> “)”

procedure EvalEscritura(var arbol:tipoArbolDerivacion; var estado:tipoEstado);
begin
      EvalTipoEscritura(arbol^.hijos[3],estado);
      writeln;
end;

//<TipoEscritura> ::=  <Expresion> <TipoEscrituraII> 

procedure EvalTipoEscritura(var arbol:tipoArbolDerivacion; var estado:tipoEstado);
var
      resultadoSubArbol:tipoValorDinamico;
begin

      //<Escritura> ::= “write” “(” <TipoEscritura> “)”
      //<Escritura> ::= “write” “(” <Expresion> <TipoEscrituraII> “)”
      //<Escritura> ::= “write” “(” <Expresion> “,” <Expresion> <TipoEscrituraII> “)”
      //<Escritura> ::= “write” “(” <Expresion> “,” <Expresion> “)”

      EvalExpresion(arbol^.hijos[1],estado,resultadoSubArbol);    //Como la variable escritura siempre terminara escribiendo una expresiion (real o cadena), primero debemos evaluar la expresion

      if resultadoSubArbol.tipoDato = tipoCadena then
      begin
            write(resultadoSubArbol.valCadena);
      end
      else
      begin
            write(resultadoSubArbol.valReal:0:2);
      end;

      EvalTipoEscrituraII(arbol^.hijos[2],estado);

end;

//<TipoEscrituraII> ::= “,” <Expresion> <TipoEscrituraII> | “ε”

procedure EvalTipoEscrituraII(var arbol:tipoArbolDerivacion; var estado:tipoEstado);
var
      resultadoSubArbol:tipoValorDinamico;
begin

      //<Escritura> ::= “write” “(” <TipoEscritura> “)”
      //<Escritura> ::= “write” “(” <Expresion> <TipoEscrituraII> “)”
      //<Escritura> ::= “write” “(” <Expresion> “,” <Expresion> <TipoEscrituraII> “)”
      //<Escritura> ::= “write” “(” <Expresion> “,” <Expresion> “)”

      if arbol^.cant <> 0 then
      begin

            EvalExpresion(arbol^.hijos[2],estado,resultadoSubArbol);

            if resultadoSubArbol.tipoDato = tipoCadena then //Como la variable TipoEscrituraII tambien debe imprimir algo en pantalla y en la misma linea, simplemente imprimimos el resultado de la expresion
            begin
                  write(resultadoSubArbol.valCadena,' ');   
            end
            else
            begin
                  write(resultadoSubArbol.valReal:0:2,' ');
            end;

            EvalTipoEscrituraII(arbol^.hijos[3],estado);
      end;
end;

end.
