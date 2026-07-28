unit pila;

{$mode ObjFPC}{$H+}

interface

uses tablasimbolos, arbol;

const
    MaxPila = 200;

type

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

end.