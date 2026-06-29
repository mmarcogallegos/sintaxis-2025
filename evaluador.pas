unit evaluador;

{$mode ObjFPC}{$H+}

interface

const

     MaxVar = 200;  //define la cantidad maxima de variables que podra tener el programa

     MaxReal = 200;

     MaxCadena = 1000;

type

    tipo = (tReal , tCadena);

    tipoElementoEstado = record

      lexemaId: string; //nombre de la variable

      valorReal: real;  // si es de tipo real, contiene el valor

      tipoVariable: tipo;

      valorCadena: string[MaxCadena]; //si es de tipo cadena, contine la cadena de hasta 1000 caracteres


    end;

    tipoEstado = record

      elementos: array[1..MaxVar] of tipoElementoEstado;

      cant:word;

    end;



uses
  Classes, SysUtils;

implementation

end.
