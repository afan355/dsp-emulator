unit lenguaje;

interface
uses {$ifndef windows}LCLType,{$endif}
     sysutils,forms,dialogs,main_engine;

const
      max_idiomas=6;
      idiomas:array [0..max_idiomas] of string=
        ('espanol.lng','english.lng','catala.lng','francais.lng','german.lng','brazil.lng','italian.lng');
type
        tlenguaje=record
          archivo:array[0..4] of string;
          opciones:array[0..4] of string;
          maquina:array[0..4] of string;
          accion:array[0..4] of string;
          cinta:array[0..18] of string;
          errores:array[0..2] of string;
          avisos:array[0..5] of string;
          mensajes:array[0..9] of string;
          varios:array[0..2] of string;
          hints:array[0..17] of string;
        end;

var
  leng:array[0..max_idiomas] of tlenguaje;

function leer_idioma:boolean;
procedure cambiar_idioma(idioma:byte);

implementation
uses principal;

procedure cambiar_idioma(idioma:byte);
begin
if not(main_vars.lenguaje_ok) then exit;
form1.Castellano1.Checked:=false;
form1.Ingles1.Checked:=false;
form1.Catalan1.Checked:=false;
form1.French1.Checked:=false;
form1.German1.Checked:=false;
form1.Brazil1.Checked:=false;
form1.italiano1.checked:=false;
case idioma of
  0:form1.Castellano1.Checked:=true;
  1:form1.Ingles1.Checked:=true;
  2:form1.Catalan1.Checked:=true;
  3:form1.French1.Checked:=true;
  4:form1.German1.Checked:=true;
  5:form1.Brazil1.Checked:=true;
  6:form1.italiano1.Checked:=true;
end;
//Archivo
form1.archivo1.caption:=leng[idioma].archivo[0];
form1.idioma1.caption:=leng[idioma].archivo[1];
form1.LstRoms.Caption:=leng[idioma].archivo[4];
form1.salir1.caption:=leng[idioma].archivo[2];
form1.acercade1.caption:=leng[idioma].archivo[3];
//Opciones
form1.opciones1.caption:=leng[idioma].opciones[0];
form1.audio1.caption:=leng[idioma].opciones[1];
form1.video1.caption:=leng[idioma].opciones[2];
form1.sinsonido1.caption:=leng[idioma].opciones[3];
//Maquina
form1.emulacion1.caption:=leng[idioma].maquina[0];
form1.ordenadores8bits1.caption:=leng[idioma].maquina[1];
form1.arcade1.caption:=leng[idioma].maquina[2];
form1.consolas1.caption:=leng[idioma].maquina[3];
//Accion
form1.uprocesador1.caption:=leng[idioma].accion[0];
form1.ejecutar1.caption:=leng[idioma].accion[1];
form1.reset1.caption:=leng[idioma].accion[2];
form1.pausa1.caption:=leng[idioma].accion[3];
//Hints
form1.BitBtn2.Hint:=leng[idioma].hints[0];
form1.BitBtn3.Hint:=leng[idioma].hints[1];
form1.BitBtn4.Hint:=leng[idioma].hints[2];
form1.BitBtn5.Hint:=leng[idioma].hints[3];
form1.BitBtn6.Hint:=leng[idioma].hints[4];
form1.btncfg.Hint:=leng[idioma].hints[5];
form1.BitBtn8.Hint:=leng[idioma].hints[6];
form1.BitBtn9.Hint:=leng[idioma].hints[7];
form1.BitBtn10.Hint:=leng[idioma].hints[8];
form1.BitBtn11.Hint:=leng[idioma].hints[9];
form1.BitBtn12.Hint:=leng[idioma].hints[10];
form1.BitBtn19.Hint:=leng[idioma].hints[11];
form1.BitBtn14.Hint:=leng[idioma].hints[12];
end;

function leer_fichero_idioma(nombre:string;posicion:byte):boolean;
var
          fichero: textfile;
          cadena: string;
begin
leer_fichero_idioma:=false;
if not(fileexists(nombre)) then exit;
assignfile(fichero,nombre);
reset(fichero);
readln(fichero,cadena); //leer el 1er codigo
//archivo
readln(fichero,cadena);leng[posicion].archivo[0]:=cadena;
readln(fichero,cadena);leng[posicion].archivo[1]:=cadena;
readln(fichero,cadena);leng[posicion].archivo[4]:=cadena;
readln(fichero,cadena);leng[posicion].archivo[2]:=cadena;
readln(fichero,cadena);leng[posicion].archivo[3]:=cadena;
//opciones
readln(fichero,cadena);leng[posicion].opciones[0]:=cadena;
readln(fichero,cadena);leng[posicion].opciones[1]:=cadena;
readln(fichero,cadena);leng[posicion].opciones[2]:=cadena;
readln(fichero,cadena);leng[posicion].opciones[3]:=cadena;
//maquina
readln(fichero,cadena);leng[posicion].maquina[0]:=cadena;
readln(fichero,cadena);leng[posicion].maquina[1]:=cadena;
readln(fichero,cadena);leng[posicion].maquina[2]:=cadena;
readln(fichero,cadena);leng[posicion].maquina[3]:=cadena;
//accion
readln(fichero,cadena);leng[posicion].accion[0]:=cadena;
readln(fichero,cadena);leng[posicion].accion[1]:=cadena;
readln(fichero,cadena);leng[posicion].accion[2]:=cadena;
readln(fichero,cadena);leng[posicion].accion[3]:=cadena;
//varios
readln(fichero,cadena);leng[posicion].varios[0]:=cadena;
readln(fichero,cadena);leng[posicion].varios[1]:=cadena;
//cinta
readln(fichero,cadena);leng[posicion].cinta[0]:=cadena;
readln(fichero,cadena);leng[posicion].cinta[1]:=cadena;
readln(fichero,cadena);leng[posicion].cinta[2]:=cadena;
readln(fichero,cadena);leng[posicion].cinta[3]:=cadena;
readln(fichero,cadena);leng[posicion].cinta[4]:=cadena;
readln(fichero,cadena);leng[posicion].cinta[5]:=cadena;
readln(fichero,cadena);leng[posicion].cinta[6]:=cadena;
readln(fichero,cadena);leng[posicion].cinta[7]:=cadena;
readln(fichero,cadena);leng[posicion].cinta[8]:=cadena;
readln(fichero,cadena);leng[posicion].cinta[9]:=cadena;
readln(fichero,cadena);leng[posicion].cinta[10]:=cadena;
readln(fichero,cadena);leng[posicion].cinta[11]:=cadena;
readln(fichero,cadena);leng[posicion].cinta[12]:=cadena;
readln(fichero,cadena);leng[posicion].cinta[13]:=cadena;
readln(fichero,cadena);leng[posicion].cinta[14]:=cadena;
readln(fichero,cadena);leng[posicion].cinta[15]:=cadena;
readln(fichero,cadena);leng[posicion].cinta[16]:=cadena;
readln(fichero,cadena);leng[posicion].cinta[17]:=cadena;
readln(fichero,cadena);leng[posicion].cinta[18]:=cadena;
//mensajes
readln(fichero,cadena);leng[posicion].mensajes[0]:=cadena;
readln(fichero,cadena);leng[posicion].mensajes[1]:=cadena;
readln(fichero,cadena);leng[posicion].mensajes[2]:=cadena;
readln(fichero,cadena);leng[posicion].mensajes[9]:=cadena; //nombre cinta virtual
readln(fichero,cadena);leng[posicion].mensajes[3]:=cadena; //sobreescribir
readln(fichero,cadena);leng[posicion].mensajes[4]:=cadena; //si
readln(fichero,cadena);leng[posicion].mensajes[5]:=cadena; //no
readln(fichero,cadena);leng[posicion].mensajes[6]:=cadena; //atencion
readln(fichero,cadena);leng[posicion].mensajes[7]:=cadena; //cargar
readln(fichero,cadena);leng[posicion].mensajes[8]:=cadena; //cancelar
//errores
readln(fichero,cadena);leng[posicion].errores[0]:=cadena;
readln(fichero,cadena);leng[posicion].errores[1]:=cadena;
//hints
readln(fichero,cadena);leng[posicion].hints[0]:=cadena;
readln(fichero,cadena);leng[posicion].hints[1]:=cadena;
readln(fichero,cadena);leng[posicion].hints[2]:=cadena;
readln(fichero,cadena);leng[posicion].hints[3]:=cadena;
readln(fichero,cadena);leng[posicion].hints[4]:=cadena;
readln(fichero,cadena);leng[posicion].hints[5]:=cadena;
readln(fichero,cadena);leng[posicion].hints[6]:=cadena;
readln(fichero,cadena);leng[posicion].hints[7]:=cadena;
readln(fichero,cadena);leng[posicion].hints[8]:=cadena;
readln(fichero,cadena);leng[posicion].hints[9]:=cadena;
readln(fichero,cadena);leng[posicion].hints[10]:=cadena;
readln(fichero,cadena);leng[posicion].hints[11]:=cadena;
readln(fichero,cadena);leng[posicion].hints[12]:=cadena;
readln(fichero,cadena);leng[posicion].hints[13]:=cadena;
readln(fichero,cadena);leng[posicion].hints[14]:=cadena;
readln(fichero,cadena);leng[posicion].hints[15]:=cadena;
readln(fichero,cadena);leng[posicion].hints[16]:=cadena;
readln(fichero,cadena);leng[posicion].hints[17]:=cadena;
//Avisos
readln(fichero,cadena);leng[posicion].avisos [3]:=cadena; //'No Internet connection!';
readln(fichero,cadena);leng[posicion].avisos [4]:=cadena; //'No need to update DSP';
readln(fichero,cadena);leng[posicion].avisos [5]:=cadena; //'New version of DSP!!';
close(fichero);
leer_fichero_idioma:=true;
end;

function leer_idioma:boolean;
var
  f:byte;
begin
leer_idioma:=false;
for f:=0 to max_idiomas do begin
  if not(leer_fichero_idioma(Directory.lenguaje+idiomas[f],f)) then begin
    MessageDlg('Aviso: Faltan el ficheros de idioma.'+chr(13)+chr(10)+'Warning: Missing lenguaje files.', mtWarning,[mbOk], 0);
    form1.idioma1.enabled:=false;
    exit;
  end;
end;
leer_idioma:=true;
end;

end.