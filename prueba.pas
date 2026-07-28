unit prueba;

{$mode ObjFPC}{$H+}

interface

uses
  analizadorlexico,analizadorsintactico,tablasimbolos,crt,sysutils,TAS,CsvDocument,pila,arbol,evaluador;

const
ruta = '/home/marco/Desktop/SINTAXIS/ProyectoSintaxis2025/Programas fuente/esPalindromo.txt';
rutaCSV = '/home/marco/Desktop/SINTAXIS/ProyectoSintaxis2025/Gramatica/TAS.csv';
rutaArbol = '/home/marco/Desktop/SINTAXIS/ProyectoSintaxis2025/arbol.txt';

procedure programaPrueba();

implementation


procedure programaPrueba();
var
    i:integer;
    fuente:fileOfChar;
    ComponenteLexico:TipoSimboloGramatical;
    Lexema:string;
    control:integer;
    TablaSimbolos:TablaDeSimbolos;
    TAS:tablaTas;
    raiz:tipoArbolDerivacion;
    estado:tipoEstado;
    aux:byte;
begin
      assign(fuente,ruta);
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
