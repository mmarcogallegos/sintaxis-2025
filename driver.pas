unit driver;

{$mode ObjFPC}{$H+}

interface

uses
  analizadorlexico,analizadorsintactico,tablasimbolos,crt,sysutils,TAS,CsvDocument,pila,arbol,evaluador;

const
rutaCSV = '/home/marco/Desktop/sintaxis-2025/Gramatica/TAS.csv';
rutaArbol = '/home/marco/Desktop/sintaxis-2025/Programas fuente/arbol.txt';


procedure CompilerDriver(nombreFuente:string);

implementation

procedure CompilerDriver(nombreFuente:string);
var
    fuente:fileOfChar;
    raiz:tipoArbolDerivacion;
    estado:tipoEstado;
    aux:byte;
begin
      assign(fuente,nombreFuente);
      reset(fuente);

      analizadorsintactico.AnalizadorSintactico(fuente,raiz,rutaCSV,aux);
      EscribirArbol(rutaArbol,raiz);

      if aux = 1 then
      begin
            EvalPrograma(raiz,estado);
      end;

      close(fuente);
end;

end.
