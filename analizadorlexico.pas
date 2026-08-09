unit analizadorlexico;

{$mode ObjFPC}{$H+}

interface

uses tablasimbolos;

procedure LeerCaracter(var Fuente:FileOfChar;var control:Longint; var caracter:char);
Function EsIdentificador(Var Fuente:FileOfChar; Var Control:LongInt; Var Lexema:String):Boolean;
Function EsConstanteReal(Var Fuente:FileOfChar; Var Control:LongInt; Var Lexema:String):Boolean;
Function EsConstanteCadena(Var Fuente:FileOfChar; Var Control:LongInt; Var Lexema:String):Boolean;
Function EsSimboloEspecial(Var Fuente:FileOfChar; Var Control:LongInt; Var Lexema:String ; Var ComponenteLexico:TipoSimboloGramatical):Boolean;
procedure ObtenerSiguienteComponenteLexico(var fuente:FileOfChar ; var control:longint ; var componenteLexico:TipoSimboloGramatical ; var lexema:string ; var TablaSimbolos:TablaDeSimbolos);

implementation

procedure LeerCaracter(var Fuente:FileOfChar;var control:Longint; var caracter:char);
begin
if control < filesize(Fuente) then
     begin
          seek(Fuente,control);
          read(Fuente,caracter);
     end
else
     begin
          caracter:=FinArchivo;
     end;
end;

Function EsIdentificador(Var Fuente:FileOfChar; Var Control:LongInt; Var Lexema:String):Boolean;
Const
     q0=0;
     F=[3];
Type
     Q=0..3;
     Sigma=(Letra, Digito, Otro);
     TipoDelta=Array[Q,Sigma] of Q; //Las filas son los estados y las columnas son los simbolos del alfabeto de entrada
Var
     ControlAux:LongInt;
     EstadoActual:Q;
     Delta:TipoDelta;
     Car:Char;

function caracterASimbolo(caracter:char):sigma;
begin
     if (caracter in ['a'..'z','A'..'Z']) then
          caracterASimbolo := Letra
     else if (caracter in ['0'..'9']) then
          caracterASimbolo := Digito
     else
          caracterASimbolo := Otro;
end;

Begin
     {Cargar la tabla de transiciones}
     Delta[0,Letra]:=2;
     Delta[0,Digito]:=1;
     Delta[0,Otro]:=1;
     Delta[2,Letra]:=2;
     Delta[2,Digito]:=2;
     Delta[2,Otro]:=3;

     {Recorrer la cadena de entrada y cambiar estados}
     ControlAux:=Control;
     EstadoActual:=q0;
     Lexema:='';

     While (EstadoActual <> 1) and (EstadoActual <> 3) do //no sea el estado muerto ni final
          begin
               LeerCaracter(Fuente, ControlAux, Car);
               EstadoActual:=Delta[EstadoActual,caracterASimbolo(Car)];
               ControlAux:=ControlAux+1;

               If EstadoActual<>3 then
                    Lexema:=Lexema+Car; //si el estado no es el final, va concatenando para formar la cadena final
          end;

     If EstadoActual in F then
          begin
               EsIdentificador:=True;
               Control:=ControlAux-1; //CONSULTAR agregado, si no se hace esto, el control queda en el caracter siguiente al lexema
          end
               Else
                    EsIdentificador:=False;
end;

Function EsConstanteReal(Var Fuente:FileOfChar; Var Control:LongInt; Var Lexema:String):Boolean;
Const
     q0=0;
     F=[4];
Type
     Q=0..5;
     Sigma=(Digito, Punto , Otro);
     TipoDelta=Array[Q,Sigma] of Q;
Var
     ControlAux:LongInt;
     EstadoActual:Q;
     Delta:TipoDelta;
     Car:Char;

function caracterASimbolo(caracter:char):sigma;
begin
     if (caracter in ['0'..'9']) then
          caracterASimbolo := Digito
     else if (caracter = '.') then
          caracterASimbolo := Punto
     else
          caracterASimbolo := Otro;
end;

Begin
     {Cargar la tabla de transiciones}
     Delta[0,Digito]:=1;
     Delta[0,Punto]:=5;
     Delta[0,Otro]:=5;
     Delta[1,Digito]:=1;
     Delta[1,Punto]:=2;
     Delta[1,Otro]:=4;
     Delta[2,Digito]:=3;
     Delta[3,Digito]:=3;
     Delta[3,Otro]:=4;
     {Recorrer la cadena de entrada y cambiar estados}
     ControlAux:=Control;
     EstadoActual:=q0;
     Lexema:='';

     While (EstadoActual <> 5) and (EstadoActual <> 4) do //no sea el estado muerto ni final
          begin
               LeerCaracter(Fuente, ControlAux, Car);
               EstadoActual:=Delta[EstadoActual,caracterASimbolo(Car)];
               ControlAux:=ControlAux+1;

               If EstadoActual<>4 then
                    Lexema:=Lexema+Car; //si el estado no es el final, va concatenando para formar la cadena final
          end;

     If EstadoActual in F then
          begin
               EsConstanteReal:=True;
               Control:=ControlAux-1; //CONSULTAR agregado
          end
               Else
                    EsConstanteReal:=False;
end;

Function EsConstanteCadena(Var Fuente:FileOfChar; Var Control:LongInt; Var Lexema:String):Boolean;
Const
     q0=0;
     F=[4];
Type
     Q=0..4;
     Sigma=(Otro, Comilla);
     TipoDelta=Array[Q,Sigma] of Q;
Var
     ControlAux:LongInt;
     EstadoActual:Q;
     Delta:TipoDelta;
     Car:Char;

function caracterASimbolo(caracter:char):sigma;
begin
     if (caracter = '"') then  
          caracterASimbolo := Comilla
     else
          caracterASimbolo := Otro;
end;

Begin
     {Cargar la tabla de transiciones}
     Delta[0,Otro]:=2;
     Delta[0,Comilla]:=1;
     Delta[1,Otro]:=1;
     Delta[1,Comilla]:=3;
     Delta[3,Otro]:=4;

     {Recorrer la cadena de entrada y cambiar estados}
     ControlAux:=Control;
     EstadoActual:=q0;
     Lexema:='';

     While (EstadoActual <> 2) and (EstadoActual <> 4) do //no sea el estado muerto ni final
               begin
                    LeerCaracter(Fuente, ControlAux, Car);
                    EstadoActual:=Delta[EstadoActual,caracterASimbolo(Car)];
                    ControlAux:=ControlAux+1;

                    If EstadoActual<>4 then
                         Lexema:=Lexema+Car; //si el estado no es el final, va concatenando para formar la cadena final
               end;

     If EstadoActual in F then
          begin
               EsConstanteCadena:=True;
               Control:=ControlAux-1;
          end
               Else
                    EsConstanteCadena:=False;
end;

Function EsSimboloEspecial(Var Fuente:FileOfChar; Var Control:LongInt; Var Lexema:String ; Var ComponenteLexico:TipoSimboloGramatical):Boolean;
var
     caracter:char;
begin
     EsSimboloEspecial := false;
     caracter := #0;

     LeerCaracter(fuente,control,caracter);

     case caracter of
     '(': begin ComponenteLexico := tParentesisAbre; Lexema := Caracter; inc(Control); EsSimboloEspecial := true; end;
     ')': begin ComponenteLexico := tParentesisCierra; Lexema := Caracter; inc(Control); EsSimboloEspecial := true; end;
     '+': begin ComponenteLexico := tMas; Lexema := Caracter; inc(Control); EsSimboloEspecial := true; end;
     '-': begin ComponenteLexico := tMenos; Lexema := Caracter; inc(Control); EsSimboloEspecial := true; end;
     '*': begin ComponenteLexico := tProducto; Lexema := Caracter; inc(Control); EsSimboloEspecial := true; end;
     '/': begin ComponenteLexico := tDivision; Lexema := Caracter; inc(Control); EsSimboloEspecial := true; end;
     '^': begin ComponenteLexico := tPotencia; Lexema := Caracter; inc(Control); EsSimboloEspecial := true; end;
     ';': begin ComponenteLexico := tPuntoYComa; Lexema := Caracter; inc(Control); EsSimboloEspecial := true; end;
     ',': begin ComponenteLexico := tComa; Lexema := Caracter; inc(Control); EsSimboloEspecial := true; end;
     '.': begin ComponenteLexico := tPunto; Lexema := Caracter; inc(Control); EsSimboloEspecial := true; end;
     '=': begin ComponenteLexico := tOperadorRelacional; Lexema := Caracter; inc(Control); EsSimboloEspecial := true; end;
     ':':
     begin
          inc(control); //Vuelve a incrementar el control para leer el siguiente caracter 
          LeerCaracter(fuente,control,caracter);
          if caracter = '=' then
               begin
                    ComponenteLexico := tOperadorAsignacion;
                    Lexema := ':' + caracter;
                    EsSimboloEspecial := true;
                    inc(control);
               end
          else
               begin
                    ComponenteLexico := tDosPuntos;
                    Lexema := ':';
                    EsSimboloEspecial := true; //si lo devuelve, lo marca como error lexico
                    //inc(control); si se incrementa de nuevo, se saltea un caracter
               end;
     end;
     '<':
     begin
          inc(control);
          LeerCaracter(fuente,control,caracter);
          if Caracter = '=' then
               begin
                    ComponenteLexico := tOperadorRelacional;
                    Lexema := '<' + caracter;
                    EsSimboloEspecial := true;
                    inc(control);
               end
          else if Caracter = '>' then
               begin
                    ComponenteLexico := tOperadorRelacional;
                    Lexema := '<>';
                    EsSimboloEspecial := true;
                    inc(control); 
               end
          else
               begin
                    ComponenteLexico := tOperadorRelacional;
                    Lexema := '<';
                    EsSimboloEspecial := true;
                     //inc(control); no se incrementa el control pues solo es el simbolo de menor
               end;
     end;
     '>':
     begin
          inc(control);
          LeerCaracter(fuente,control,caracter);
          if Caracter = '=' then
               begin
                    ComponenteLexico := tOperadorRelacional;
                    Lexema := '>' + caracter;
                    EsSimboloEspecial := true;
                    inc(control);
               end
          else
               begin
                    ComponenteLexico := tOperadorRelacional;
                    Lexema := '>';
                    EsSimboloEspecial := true;
                    //inc(control);
               end;
     end;
     end;
end;

procedure ObtenerSiguienteComponenteLexico(var fuente:FileOfChar ; var control:longint ; var componenteLexico:TipoSimboloGramatical ; var lexema:string ; var TablaSimbolos:TablaDeSimbolos);
var
     caracter:char;
begin

     LeerCaracter(fuente,control,caracter);

     while caracter in [#1..#32] do //esta parte saltea los caracteres de control, espacios en blanco etc
          begin
               inc(control);
               LeerCaracter(fuente,control,caracter);
          end;

     if caracter = FinArchivo then //FinArchivo es #0, esta definido en la unit tablasimbolos
          begin
               ComponenteLexico := pesos;
               Lexema := ''; //agregado
          end
     else
          begin
               if EsIdentificador(fuente,control,lexema) then                      //la tabla de simbolos ya tiene cargadas las palabras reservadas y se le va cargando los identificadores que se van leyendo
                    InstalarEnTablaDeSimbolos(TablaSimbolos,componenteLexico,lexema)
               else if EsConstanteReal(fuente,control,lexema) then
                    componenteLexico := tConstanteReal
               else if EsConstanteCadena(fuente,control,lexema) then
                    componenteLexico := tConstanteCadena
               else if EsSimboloEspecial(fuente,control,lexema,componenteLexico) then
                    componenteLexico := componenteLexico
               else
                    componenteLexico := error;
          end;
end;

end.