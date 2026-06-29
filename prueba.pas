unit prueba;

{$mode ObjFPC}{$H+}

interface

const
ruta = '/home/marco/Desktop/UTN-FRCU---ProyectoSintaxis-2025/programaPrueba.txt';

procedure analizarFuente();

implementation
uses
  analizadorlexico,tablasimbolos,crt,sysutils;

procedure analizarFuente();
var
   fuente:fileOfChar;
   ComponenteLexico:TipoSimboloGramatical;
   Lexema:string;
   control:integer;
   TablaSimbolos:TablaDeSimbolos;
begin
     GenerarTablaDeSimbolos(TablaSimbolos);
     InstalarEnTablaDeSimbolos(TablaSimbolos , ComponenteLexico , Lexema);
     assign(fuente,ruta);
     reset(fuente);
     control:=0;

     while (ComponenteLexico <> pesos) and (ComponenteLexico <> error) do
           begin
                obtenerSiguienteComponenteLexico(fuente , control , ComponenteLexico , Lexema , TablaSimbolos);
                writeln('COMPONENTE LEXICO: ',ComponenteLexico, '  LEXEMA: ',Lexema);
                readkey;
           end;


     readkey;

     close(fuente);

end;

end.
