unit evaluador;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, math, tablaSimbolos, pilayarbol;

const

      MaxVar = 200;  //define la cantidad maxima de variables que podra tener el programa

      MaxReal = 200;

      MaxCadena = 255;

type

    tipo = (tipoReal , tipoCadena);

    tipoElementoEstado = record

      lexemaId: string; //nombre de la variable

      tipoVariable: tipo;

      valorReal: real;  // si es de tipo real, contiene el valor

      valorCadena: string[MaxCadena]; //si es de tipo cadena, contine la cadena de hasta 1000 caracteres


    end;

    tipoEstado = record

      elemento: array[1..MaxVar] of tipoElementoEstado;

      cant:word;

    end;

    tipoValorDinamico = record
      tipoDato:tipo;
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

procedure AsignarReal(var estado:tipoEstado; var lexema:string; resultadoReal:real);            //Primero se busca la variable en el estado, cuando se encuentra se le asigna su valor correspondiente
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

procedure AsignarCadena(var estado:tipoEstado; var lexema:string; resultadoCadena:string);
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
      if (length(cadena) >= 2) and (cadena[1]='"') and (cadena[length(cadena)] = '"') then
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
      resultadoSubArbol:tipoValorDinamico;
begin
      if arbol^.hijos[1]^.simbolo = tIdentificador then
      begin

            nombreVariable := arbol^.hijos[1]^.lexema;                        //"identificador" es el nombre de la variable
            EvalExpresion(arbol^.hijos[3],estado,resultadoSubArbol);         //Le pasamos el id a evaluar expresion ya que no podemos distinguir asignaciones de cadenas y reales 
            
            case resultadoSubArbol.tipoDato of
                  tipoReal:
                        begin 
                              AsignarReal(estado,nombreVariable,resultadoSubArbol.valReal); 
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
      EvalExpresionII(arbol^.hijos[2],estado,resultadoSubArbol,resultado);  //resultado es la variable de salida, resultadoSubArbol es el parametro de entrada para calcular el resultado final
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
                              EvalTermino(arbol^.hijos[2],estado,resultadoSubArbolDos);            //Primero evalua el subarbol para saber que sigue luego de "+"
                              resultadoSubArbol.valReal:=resultadoSubArbol.valReal + resultadoSubArbolDos.valReal; //Actualizamos el resultado del parametro, con el valor que nos ha devuelto EvalTermino
                              EvalExpresionII(arbol^.hijos[3],estado,resultadoSubArbol,resultado);                //Ahora volvemos a llamar al procedimiento pero con el valor actualizaco
                        end;                                                                    //Lo mismo sucede para las demas situaciones del case
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
            resultado.valReal:=resultadoSubArbol.valReal;         //Si <ExpresionII> se hace epsilon, le asignamos al parametro los valores correspondientes    
            resultado.valCadena:=resultadoSubArbol.valCadena;
            resultado.tipoDato:=resultadoSubArbol.tipoDato;
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
                                    writeln('ERROR. DIVISION POR CERO');
                        end;
            end;
      end
      else
            resultado.valReal := resultadoSubArbol.valReal;         
            resultado.valCadena := resultadoSubArbol.valCadena;
            resultado.tipoDato := resultadoSubArbol.tipoDato;    
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
      if arbol^.cant <> 0 then
      begin
            if arbol^.hijos[1]^.simbolo = tPotencia then
                  begin

                        EvalMayorPrecedencia(arbol^.hijos[2],estado,resultadoSubArbolDos);

                        if (resultadoSubArbolDos.valReal <> 0) and (resultadoSubArbol.valReal <> 0) then
                        begin

                              resultadoSubArbol.valReal:= power(resultadoSubArbol.valReal,resultadoSubArbolDos.valReal);
                              EvalFactorII(arbol^.hijos[3],estado,resultadoSubArbol,resultado);

                        end
                        else
                              writeln('ERROR. CERO A LA CERO');
                  end;
      end
      else
            resultado.valReal := resultadoSubArbol.valReal;         
            resultado.valCadena := resultadoSubArbol.valCadena;
            resultado.tipoDato := resultadoSubArbol.tipoDato;
end;

//<MayorPrecedencia> ::= “constanteReal” | “constanteCadena” | “identificador” | “(” <Expresion> “)” | “raiz” “(” <Expresion> “)” | “extraerSubcadena” “(” <Expresion> “,” <Expresion> “,” <Expresion> “)” | ”buscarSubcadena” “(” <Expresion> “,” <Expresion> “)” | “longitudCadena” “(” <Expresion> “)” | “-” <MayorPrecedencia>

procedure EvalMayorPrecedencia(var arbol:tipoArbolDerivacion; var estado:tipoEstado; var resultado:tipoValorDinamico);
var   
      aux,i:integer;
      nombreVar:string;
      resultadoSubArbol:tipoValorDinamico;
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
      tIdentificador:
            begin

                  nombreVar:=arbol^.hijos[1]^.lexema;

                  for i:=1 to estado.cant do
                  begin
                        if estado.elemento[i].lexemaId = nombreVar then       //Recorremos el estado buscando la variable para obtener su valor
                        begin
                              resultado.tipoDato:=estado.elemento[i].tipoVariable;
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

            end;
      tParentesisAbre:
            begin

                  EvalExpresion(arbol^.hijos[2],estado,resultado);

                  {case resultadoSubArbolDos.tipoDato of
                        tipoCadena: begin resultadoSubArbol.valCadena := resultadoSubArbolDos.valCadena end;
                        tipoReal: begin resultadoSubArbol.valCadena := resultadoSubArbolDos.valCadena end;
                  end;}
            end;
      tRaiz:
            begin

                  EvalExpresion(arbol^.hijos[3],estado,resultadoSubArbol);

                  if resultadoSubArbol.valReal >= 0 then
                  begin
                        resultado.valReal:=power(resultadoSubArbol.valReal,(1/2));
                        resultado.tipoDato:=tipoReal;
                  end
                  else
                        writeln('ERROR. ARGUMENTO NEGATIVO');
            end;
      {tExtraerSubcadena:
            begin
                  EvalExpresion(arbol^.hijos[3],estado,resultadoSubArbolDos,resultadoUno);      //arreglar despues
                  EvalExpresion(arbol^.hijos[5],estado,resultadoSubArbolTres,resultadoDos);       
                  EvalExpresion(arbol^.hijos[7],estado,resultadoSubArbolCuatro,resultadoTres);

            end;
      tBuscarSubcadena:
            begin

            end;
      tLongitudCadena:
            begin

            end;}
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
            EvalCondicion(arbol^.hijos[2],estado,cond);
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
            resultado:=cond;
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
            resultado:=cond;
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
      else
      begin
            case arbol^.hijos[2]^.lexema of
            '=':begin resultado:= resultadoSubArbolUno.valCadena = resultadoSubArbolDos.valCadena end;
            '<>':begin resultado:= resultadoSubArbolUno.valCadena <> resultadoSubArbolDos.valCadena end;
            '>=':begin resultado:= resultadoSubArbolUno.valCadena >= resultadoSubArbolDos.valCadena end;
            '<=':begin resultado:= resultadoSubArbolUno.valCadena <= resultadoSubArbolDos.valCadena end;
            '<':begin resultado:= resultadoSubArbolUno.valCadena < resultadoSubArbolDos.valCadena end;
            '>':begin resultado:= resultadoSubArbolUno.valCadena > resultadoSubArbolDos.valCadena end;
            end;      
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
            EvalCuerpo(arbol^.hijos[4],estado);
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
      cadenaEntrada:string;
      aux:integer;
      res:real;
begin
      if arbol^.hijos[1]^.simbolo = tIdentificador then
      begin
            readln(cadenaEntrada);
            val(cadenaEntrada,res,aux);

            if aux <> 0 then
            begin
                  AsignarCadena(estado,arbol^.hijos[1]^.lexema,cadenaEntrada);
            end
            else
            begin
                  AsignarReal(estado,arbol^.hijos[1]^.lexema,res);
            end;
      end
      else
      begin
            write(EliminarComillas(arbol^.hijos[1]^.lexema));
            readln(cadenaEntrada);
            val(cadenaEntrada,res,aux);

            if aux <> 0 then
            begin
                  AsignarCadena(estado,arbol^.hijos[3]^.lexema,cadenaEntrada);
            end
            else
            begin
                  AsignarReal(estado,arbol^.hijos[3]^.lexema,res);
            end;
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
      EvalExpresion(arbol^.hijos[1],estado,resultadoSubArbol);

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
      if arbol^.cant <> 0 then
      begin
            EvalExpresion(arbol^.hijos[2],estado,resultadoSubArbol);

            if resultadoSubArbol.tipoDato = tipoCadena then
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
