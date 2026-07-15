unit prueba;

{$mode ObjFPC}{$H+}

interface

const
ruta = '/home/marco/Desktop/SINTAXIS/ProyectoSintaxis2025/programaPrueba.txt';

procedure analizarFuente();

// Este procedimiento es solamente para probar el analizador lexico, luego el analizador sintactico va a llamar al analizador lexico y no se va a utilizar este procedimiento.

implementation
uses
  analizadorlexico,tablasimbolos,crt,sysutils,TAS;

procedure analizarFuente();
var
   i:integer;
   fuente:fileOfChar;
   ComponenteLexico:TipoSimboloGramatical;
   Lexema:string;
   control:integer;
   TablaSimbolos:TablaDeSimbolos;
   TAS:tablaTas;
begin
     GenerarTablaDeSimbolos(TablaSimbolos);
     assign(fuente,ruta);
     reset(fuente);
     control:=0;

     while (ComponenteLexico <> pesos) and (ComponenteLexico <> error) do
           begin
                obtenerSiguienteComponenteLexico(fuente , control , ComponenteLexico , Lexema , TablaSimbolos);
                writeln('COMPONENTE LEXICO: ',ComponenteLexico, '  LEXEMA: ',Lexema);
                //eadkey;
           end;


     readkey;




     for i:=1 to TablaSimbolos.cant do
          begin
               writeln(tablaSimbolos.elem[i].componenteLexico,'  ',tablaSimbolos.elem[i].lexema, '  ',i);
          end;

                    writeln(i);

     readkey;


     //InicializarTAS(TAS);
     readkey;

     close(fuente);

end;

end.
