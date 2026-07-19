unit prueba;

{$mode ObjFPC}{$H+}

interface

const
ruta = '/home/marco/Desktop/sintaxis-2025/programaPrueba.txt';
rutaCSV = '/home/marco/Desktop/sintaxis-2025/Gramatica/TAS.csv';
rutaArbol = '/home/marco/Desktop/sintaxis-2025/arbol.txt';

procedure analizarFuente();

// Este procedimiento es solamente para probar el analizador lexico, luego el analizador sintactico va a llamar al analizador lexico y no se va a utilizar este procedimiento.

implementation
uses
  analizadorlexico,analizadorsintactico,tablasimbolos,crt,sysutils,TAS,CsvDocument,pilayarbol;

procedure analizarFuente();
var
   i:integer;
   fuente:fileOfChar;
   ComponenteLexico:TipoSimboloGramatical;
   Lexema:string;
   control:integer;
   TablaSimbolos:TablaDeSimbolos;
   TAS:tablaTas;
   raiz:tipoArbolDerivacion;

begin
     assign(fuente,ruta);
     reset(fuente);


     analizadorsintactico.AnalizadorSintactico(fuente,raiz,rutaCSV);

     EscribirArbol(rutaArbol,raiz);
     close(fuente);
end;

end.
