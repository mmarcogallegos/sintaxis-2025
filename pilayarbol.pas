unit pilayarbol; //el analizador sintactico utiliza pilas y arboles

{$mode ObjFPC}{$H+}

interface

uses tablasimbolos;

const 
      MaximaProd = 8;
      MaxPila = 200;
type

tipoArbolDerivacion = ^tipoNodoArbol;
tipoNodoArbol = record
            simbolo:TipoSimboloGramatical;
            lexema:string;
            hijos: array[1..MaximaProd] of tipoArbolDerivacion;
            cant:byte;   //cantidad de hijos.
end;

tipoElementoPila = record
            simbolo: TipoSimboloGramatical;
            nodo: tipoArbolDerivacion;
end;

tipoPila = record   //Cada elemento de la pila guarda un simbolo de la gramatica y un puntero a un nodo del arbol
            elem: array [1..MaxPila] of tipoElementoPila;
            tope: word;
end;


Procedure CrearPila(var pila:tipoPila);
Procedure Apilar(var pila:tipoPila ; elemento:tipoElementoPila);
Procedure Desapilar(var pila:tipopila ; var elemento:tipoElementoPila);


Procedure CrearArbol(var raiz:tipoArbolDerivacion);
Procedure CrearNodo(var nodo:tipoArbolDerivacion; componenteLexico:TipoSimboloGramatical);
Procedure AgregarNodo(var raiz:tipoArbolDerivacion; var hijo:tipoArbolDerivacion);
Procedure MostrarArbol(var arbol:tipoArbolDerivacion);
procedure GuardarArbol(var archivo:text; var raiz: tipoArbolDerivacion; desplazamiento:integer);
Procedure EscribirArbol(ruta:string;var arbol:tipoArbolDerivacion);


implementation

Procedure CrearPila(var pila:tipoPila);
begin
      pila.tope := 0;
end;

Procedure Apilar(var pila:tipoPila ; elemento:tipoElementoPila);
begin
      inc(pila.tope);
      pila.elem[pila.tope].simbolo := elemento.simbolo; 
      pila.elem[pila.tope].nodo := elemento.nodo;
end;

Procedure Desapilar(var pila:tipopila ; var elemento:tipoElementoPila);
begin
      elemento.simbolo := pila.elem[pila.tope].simbolo;
      elemento.nodo := pila.elem[pila.tope].nodo;
      dec(pila.tope);
end;

Procedure CrearArbol(var raiz:tipoArbolDerivacion);
begin
      raiz := nil;
end;

Procedure CrearNodo(var nodo:tipoArbolDerivacion; componenteLexico:TipoSimboloGramatical);
var
      i:integer;
begin
      NEW(nodo);
      nodo^.simbolo:=componenteLexico;
      nodo^.lexema:='';
      nodo^.cant:=0;
      for i:=1 to MaximaProd do
            begin
                  nodo^.hijos[i] := nil;
            end;
end;

Procedure AgregarNodo(var raiz:tipoArbolDerivacion; var hijo:tipoArbolDerivacion);
begin
      if raiz^.cant < MaximaProd then
            begin
                  inc(raiz^.cant);
                  raiz^.hijos[raiz^.cant]:=hijo
            end;
end;

Procedure MostrarArbol(var arbol:tipoArbolDerivacion);
var 
      i:integer;
begin
      writeln(arbol^.simbolo) ;
      for i:=1 to arbol^.cant do
            begin
                  MostrarArbol(arbol^.hijos[i]);
            end;
end;

Procedure GuardarArbol(var archivo:text; var raiz: tipoArbolDerivacion; desplazamiento:integer);
var 
      i : integer;
begin
      Writeln(archivo, '':desplazamiento,raiz^.simbolo,': ',raiz^.lexema);
            for i:=1 to raiz^.cant do  
                  begin
                        GuardarArbol(archivo,raiz^.hijos[i],desplazamiento+2); //desplazamiento es apilamiento
                  end;
end;

Procedure EscribirArbol(ruta:string;var arbol:tipoArbolDerivacion);
var   
      archivo:text;
      j:integer;
begin
      j:=0;
      assign(archivo,ruta);
      rewrite(archivo);
      GuardarArbol(archivo,arbol,j);
      close(archivo);
end;


end.
