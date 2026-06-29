unit pilayarbol; //el analizador sintactico utiliza pilas y arboles

{$mode ObjFPC}{$H+}

interface

type

tipoElementoPila = record
             simbolo: TipoSimboloGramatical;
             nodo: tipoArbolDerivacion;
end;

tipoPila = record   //Cada elemento de la pila guarda un simbolo de la gramatica y un puntero a un nodo del arbol
          elem: array [1..maxPila] of tipoElementoPila;
          tope: word;
end;
                         //Guarda un arreglo de simbolos y cuantos simbolos tiene
tipoProduccion = record  //Representa las producciones de las variables (lado derecho en BNF)
          elem: array [1..maxProduccion] of TipoSimboloGramatical;
          cant: byte;
end;

tipoPunteroProduccion =  ^tipoProduccion;
tipoTAS = array [vprograma..vlista_w2,tIdentificador..pesos] of ^tipoProduccion; //Las filas son las variables y las columntas los terminales

tipoArbolDerivacion = ^tipoNodoArbol;
tipoNodoArbol = record
              simbolo:TipoSimboloGramatical;
              lexema:string;
              hijos: array[1..max] of tipoArbolDerivacion;
              cant:byte;   //cantidad de hijos.

  end;

Procedure MostrarArbol(var arbol:tipoArbolDerivacion);
procedure GuardarArbol(var archivo:text; var raiz: tipoArbolDerivacion; desplazamiento:integer);

implementation


Procedure MostrarArbol(var arbol:tipoArbolDerivacion);
var i:integer;
begin
   writeln(arbol^.simbolo) ;
 for i:=1 to arbol^.cant do
   begin
      MostrarArbol(arbol^.hijos[i]);
   end;
end;


procedure GuardarArbol(var archivo:text; var raiz: tipoArbolDerivacion; desplazamiento:integer);
var i : integer;
begin
     Writeln(archivo, '':desplazamiento,raiz^.simbolo,': ',raiz^.lexema);
        for i:=1 to raiz^.cant do  begin
            GuardarArbol(archivo,raiz^.hijos[i],desplazamiento+2); //desplazamiento es apilamiento
        end;

end;


end.
