unit evaluador;

{$mode ObjFPC}{$H+}

interface

const

      MaxVar = 200;  //define la cantidad maxima de variables que podra tener el programa

      MaxReal = 200;

      MaxCadena = 255;

type

    tipo = (tReal , tCadena);

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

uses
  Classes, SysUtils;



procedure InicializarEstado(var estado:tipoEstado);
procedure AgregarVar(var estado:tipoEstado; var lexema:string; var tipoVar:tipo);
procedure AsignarReal(var estado:tipoEstado; var lexema:string; resultadoReal:real);
procedure AsignarCadena(var estado:tipoEstado; var lexema:string; resultadoCadena:string);


procedure EvalPrograma(var arbol:tipoArbolDerivacion; var estado:tipoEstado);
procedure EvalDeclaracionVariables(var arbol:tipoArbolDerivacion; var estado:tipoEstado);
procedure EvalCuerpoVar(var arbol:tipoArbolDerivacion; var estado:tipoEstado);
procedure EvalCuerpoVarII(var arbol:tipoArbolDerivacion; var estado:tipoEstado);
function EvalTipoVar(var arbol:tipoArbolDerivacion; var estado:tipoEstado):tipo;
procedure EvalCuerpo(var arbol:tipoArbolDerivacion; var estado:tipoEstado);
procedure EvalSentencia(var arbol:tipoArbolDerivacion; var estado:tipoEstado);
procedure EvalAsignacion(var arbol:tipoArbolDerivacion; var estado:tipoEstado);
procedure EvalExpresion(var arbol:tipoArbolDerivacion; var estado:tipoEstado);

procedure EvalTermino(var arbol:tipoArbolDerivacion; var estado:tipoEstado);

procedure EvalFactor(var arbol:tipoArbolDerivacion; var estado:tipoEstado);

procedure EvalCiclica(var arbol:tipoArbolDerivacion; var estado:tipoEstado);
procedure EvalCondicion(var arbol:tipoArbolDerivacion; var estado:tipoEstado);

procedure EvalTerminoAnd(var arbol:tipoArbolDerivacion; var estado:tipoEstado);


procedure EvalComparacion(var arbol:tipoArbolDerivacion; var estado:tipoEstado);

procedure EvalLectura(var arbol:tipoArbolDerivacion; var estado:tipoEstado);
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
    estado.elemento[cant].lexemaId := lexema;
    if tipoVar = tCadena then
      begin
            estado.elemento[cant].tipoVariable := tCadena,
      end
    else
        estado.elemento[cant].tipoVariable := tReal;
end;

//<Programa> ::= “program” “identificador” “;” <DeclaracionVariables> “begin” <Cuerpo> “end” “.”

procedure EvalPrograma(var arbol:tipoArbolDerivacion; var estado:tipoEstado);
begin
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
      resultadoTipo:=EvalTipoVar(arbol^.hijos[3],estado);
      EvalCuerpoVarII(arbol^.hijos[5],estado);
      AgregarVar(estado,arbol^.hijos[1]^.lexema,resultadoTipo);  
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

function EvalTipoVar(var arbol:tipoArbolDerivacion; var estado:tipoEstado):tipo;
begin
      if arbol^.hijos[1]^.simbolo = tReal then
        begin
              EvalTipoVar:=tReal
        end
      else
          begin
                EvalTipoVar:=tCadena;
          end;
end;

//<Cuerpo> ::= <Sentencia> ”;” <Cuerpo>  | “ε”

procedure EvalCuerpo(var arbol:tipoArbolDerivacion; var estado:tipoEstado);
begin
      if arbo^.cant <> 0 then
        begin
              EvalSentencia(arbol^.hijos[1],estado);
              EvalCuerpo(arbol^.hijos[3],estado);
        end;
end;

//<Sentencia> ::=  <Asignacion> | <Lectura> | <Escritura> | <Condicional> | <Ciclica>

procedure EvalSentencia(var arbol:tipoArbolDerivacion; var estado:tipoEstado);
begin
      case arbol^.hijos[1].simbolo of
      vAsignacion: begin EvalAsignacion(arbol^.hijos[1],estado) end;
      vLectura: begin EvalLectura(arbol^.hijos[1],estado) end;
      vEscritura: begin EvalEscritura(arbol^.hijos[1],estado) end;
      vCondicional: begin EvalCondicional(arbol^.hijos[1],estado) end;
      vCiclica: begin EvalCiclica(arbol^.hijos[1],estado) end;
end;

//<Asignacion> ::= “identificador” “operadorAsignacion” <Expresion>

procedure EvalAsignacion(var arbol:tipoArbolDerivacion; var estado:tipoEstado);
begin
      EvalExpresion(arbol^.hijos[3],estado);
end;

//<Expresion> ::= <Termino> <ExpresionII>

procedure EvalExpresion(var arbol:tipoArbolDerivacion; var estado:tipoEstado);
begin
      EvalTermino(arbol^.hijos[1],estado);
      EvalExpresionII(arbol^.hijos[2],estado);
end;

//<ExpresionII> ::= “+” <Termino> <ExpresionII> | “-” <Termino> <ExpresionII> | “concatenacion” <Termino> <ExpresionII> | “ε” 

//<Termino> ::= <Factor> <TerminoII>

procedure EvalTermino(var arbol:tipoArbolDerivacion; var estado:tipoEstado);
begin
      EvalFactor(arbol^.hijos[1],estado);
      EvalTerminoII(arbol^.hijos[2],estado);
end;

//<TerminoII> ::= “*” <Factor> <TerminoII> | “/” <Factor> <TerminoII> | “ε” 

//<Factor> ::= <MayorPrecedencia> <FactorII>

procedure EvalFactor(var arbol:tipoArbolDerivacion; var estado:tipoEstado);
begin
      EvalMayorPrecedencia(arbol^.hijos[1],estado);
      EvalFactorII(arbol^.hijos[2],estado);
end;

//<FactorII> ::= “^” <MayorPrecedencia> <FactorII> | “ε” 

//<MayorPrecedencia> ::= “constanteReal” | “constanteCadena” | “identificador” | “(” <Expresion> “)” | “raiz” “(” <Expresion> “)” | “extraerSubcadena” “(” <Expresion> “,” <Expresion> “,” <Expresion> “)” | ”buscarSubcadena” “(” <Expresion> “,” <Expresion> “)” | “longitudCadena” “(” <Expresion> “)” | “-” <MayorPrecedencia>

//<Ciclica> ::= “while” <Condicion> “do” <Cuerpo> “end”

procedure EvalCiclica(var arbol:tipoArbolDerivacion; var estado:tipoEstado);
begin
      EvalCondicion(arbol^.hijos[2],estado);
      EvalCuerpo(arbol^.hijos[4],estado);
end;

//<Condicion> ::= <TerminoAnd> <CondicionII>

procedure EvalCondicion(var arbol:tipoArbolDerivacion; var estado:tipoEstado);
begin
      EvalTerminoAnd(arbol^.hijos[1],estado);
      EvalCondicionII(arbol^.hijos[2],estado);
end;

//<CondicionII> ::= “operadorLogicoOr” <TerminoAnd> <CondicionII> | “ε”

//<TerminoAnd> ::= <TerminoLogico> <TerminoAndII>

procedure EvalTerminoAnd(var arbol:tipoArbolDerivacion; var estado:tipoEstado);
begin
      EvalTerminoLogico(arbol^.hijos[1],estado);
      EvaloTerminoAndII(arbol^.hijos[2],estado);
end;

//<TerminoAndII> ::= “operadorLogicoAnd” <TerminoLogico> <TerminoAndII> | “ε”

//<TerminoLogico> ::= “operadorLogicoNot” <Comparacion> | <Comparacion>

//<Comparacion> ::= <Expresion> “operadorRelacional” <Expresion>

procedure EvalComparacion(var arbol:tipoArbolDerivacion; var estado:tipoEstado);
begin
      EvalExpresion(arbol^.hijos[1],estado);
      EvalExpresion(arbol^.hijos[3],estado);
end;

//<Condicional> ::= “if” <Condicion> “then” <Cuerpo> <CondicionalFin>

procedure EvalCondicional(var arbol:tipoArbolDerivacion; var estado:tipoEstado);
begin
      EvalCondcion(arbol^.hijos[2],estado);
      EvalCuerpo(arbol^.hijos[4],estado);
      EvalCondicionalFin(arbol^.hijos[5],estado);
end;

//<CondicionalFin>::= “end” | “else” <Cuerpo> “end”

//<Lectura> ::= “read” “(” <LecturaII> 

procedure EvalLectura(var arbol:tipoArbolDerivacion; var estado:tipoEstado);
begin
      EvalLecturaII(arbol^.hijos[3],estado);
end;

//<LecturaII> ::= “constanteCadena” “,” ”identificador”)” | “identificador” “)”

//<Escritura> ::= “write” “(” <TipoEscritura> “)”

procedure EvalEscritura(var arbol:tipoArbolDerivacion; var estado:tipoEstado);
begin
      EvalLecturaII(arbol^.hijos[3],estado);
end;

//<TipoEscritura> ::=  <Expresion> <TipoEscrituraII> 

procedure EvalTipoEscritura(var arbol:tipoArbolDerivacion; var estado:tipoEstado);
begin
      EvalExpresion(arbol^.hijos[1],estado);
      EvalLecturaII(arbol^.hijos[2],estado);
end;

//<TipoEscrituraII> ::= “,” <Expresion> <TipoEscrituraII> | “ε”

procedure EvalTipoEscrituraII(var arbol:tipoArbolDerivacion; var estado:tipoEstado);
begin
      if arbol^. cant <> 0 then
        begin
              EvalExpresion(arbol^.hijos[2],estado);
              EvalTipoEscrituraII(arbol^.hijos[3],estado);
        end;
end;

end.
