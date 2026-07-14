unit tablasimbolos;

{$mode ObjFPC}{$H+}

interface

const
     MaxSim=200;
     FinArchivo=#0;

type //los componentes lexicos son los terminales

TipoSimboloGramatical=( tProgram , tIdentificador , tPuntoYComa , tBegin , tEnd , tPunto , tVar , tDosPuntos , tReal , tCadena , tOperadorAsignacion , tMas , tMenos , tConcatenacion , tProducto , tDivision , tPotencia , tConstanteReal , tConstanteCadena , tParentesisAbre , tParentesisCierra , tRaiz , tExtraerSubcadena , tComa , tBuscarSubcadena , tLongitudCadena , tWhile , tDo , tOperadorLogicoBinario , tOperadorLogicoUnario , tOperadorRelacional , tIf , tThen , tElse , tRead , tComilla , tWrite , error , pesos ,

vPrograma , vDeclaracionVariables , vCuerpoVar , vCuerpoVarII , vTipoVar , vCuerpo , vSentencia , vAsignacion , vExpresion , vExpresionII , vTermino , vTerminoII , vFactor , vFactorII , vMayorPrecedencia , vCiclica , vCondicion , vCondicionII , vTerminoLogico , vComparacion , vCondicional , vCondicionalFin , vLectura , vLecturaII , vEscritura , vTipoEscritura);


FileOfChar = file of char;

TipoElementoTablaDeSimbolos = record
 componenteLexico:TipoSimboloGramatical;  //Indica el tipo de terminal
 lexema:string;                           //Indica la cadena que representa
end;

TablaDeSimbolos = record
  elem:array[1..MaxSim]of TipoElementoTablaDeSimbolos;
  cant:0..MaxSim;
end;


procedure GenerarTablaDeSimbolos(var tablaSimbolos:TablaDeSimbolos);
procedure InstalarEnTablaDeSimbolos(var tablaSimbolos:TablaDeSimbolos ; var componenteLexicoLeido:tipoSimboloGramatical ; var lexemaLeido:string);

implementation

uses
    crt, sysutils, analizadorlexico;

procedure GenerarTablaDeSimbolos(var tablaSimbolos:TablaDeSimbolos);  // carga en la tabla de simbolos las palabras reservadas indicadas en el trabajo practico
begin
     tablaSimbolos.cant := 16;
     tablaSimbolos.elem[1].componenteLexico := tProgram;
     tablaSimbolos.elem[1].lexema := 'PROGRAM';
     tablaSimbolos.elem[2].componenteLexico := tBegin;
     tablaSimbolos.elem[2].lexema := 'BEGIN';
     tablaSimbolos.elem[3].componenteLexico := tEnd;
     tablaSimbolos.elem[3].lexema := 'END';
     tablaSimbolos.elem[4].componenteLexico := tIf;
     tablaSimbolos.elem[4].lexema := 'IF';
     tablaSimbolos.elem[5].componenteLexico := tThen;
     tablaSimbolos.elem[5].lexema := 'THEN';
     tablaSimbolos.elem[6].componenteLexico := tElse;
     tablaSimbolos.elem[6].lexema := 'ELSE';
     tablaSimbolos.elem[7].componenteLexico := tWhile;
     tablaSimbolos.elem[7].lexema := 'WHILE';
     tablaSimbolos.elem[8].componenteLexico := tDo;
     tablaSimbolos.elem[8].lexema := 'DO';
     tablaSimbolos.elem[9].componenteLexico := tRead;
     tablaSimbolos.elem[9].lexema := 'READ';
     tablaSimbolos.elem[10].componenteLexico := tWrite;
     tablaSimbolos.elem[10].lexema := 'WRITE';
     tablaSimbolos.elem[11].componenteLexico := tOperadorLogicoBinario;
     tablaSimbolos.elem[11].lexema := 'AND';
     tablaSimbolos.elem[12].componenteLexico := tOperadorLogicoBinario;
     tablaSimbolos.elem[12].lexema := 'OR';
     tablaSimbolos.elem[13].componenteLexico := tOperadorLogicoUnario;
     tablaSimbolos.elem[13].lexema := 'NOT';
     tablaSimbolos.elem[14].componenteLexico := tRaiz;
     tablaSimbolos.elem[14].lexema := 'SQRT';
     tablaSimbolos.elem[15].componenteLexico := tReal;
     tablaSimbolos.elem[15].lexema := 'REAL';
     tablaSimbolos.elem[16].componenteLexico := tCadena;
     tablaSimbolos.elem[16].lexema := 'STRING';
end;
          //buscarEnTS
procedure InstalarEnTablaDeSimbolos(var tablaSimbolos:TablaDeSimbolos ; var componenteLexicoLeido:tipoSimboloGramatical ; var lexemaLeido:string);
var
   enc:boolean;
   i:longint;
begin
     i := 1;
     componenteLexicoLeido := tIdentificador;
     enc := false;
     while (i <= tablaSimbolos.cant) and (enc = false) do //este ciclo recorre las palabras reservadas ya cargadas en la tabla de simbolos
           begin
                if tablaSimbolos.elem[i].lexema = uppercase(lexemaLeido) then
                   begin
                        componenteLexicoLeido := tablaSimbolos.elem[i].componenteLexico;
                        enc := true;                      //si el lexema leido ya se encuentra en la tabla, "cambia" el componente lexico y sale del ciclo
                   end
                else
                    inc(i);
           end;

     if enc = false then    // si no se ha encontrado el lexema en la tabla con las palabras ya cargadas, agrega el par componenteLexico - lexema a la tabla
        begin
             if tablaSimbolos.cant <= MaxSim then
                begin
                     tablaSimbolos.cant := tablaSimbolos.cant+1;
                     tablaSimbolos.elem[tablaSimbolos.cant].lexema := uppercase(lexemaLeido); //El identificador de una variable es unico sin importar si esta escrito con mayusculas o minusculas, solo contiene letras o digitos
                     tablaSimbolos.elem[tablaSimbolos.cant].componenteLexico := tIdentificador;
                end;
        end;

end;

end.
