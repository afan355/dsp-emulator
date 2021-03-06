unit sega_gg;

interface
uses nz80,{$IFDEF WINDOWS}windows,{$ENDIF}
     main_engine,controls_engine,sega_vdp,sn_76496,sysutils,dialogs,
     misc_functions,sound_engine,file_engine,sms;

procedure cargar_gg;

implementation
uses principal;

var
  bios_enabled:boolean;
  io_gg:array[0..6] of byte;

procedure eventos_gg;
begin
if event.keyboard then begin
  if (keyboard[KEYBOARD_F1]) then z80_0.change_nmi(PULSE_LINE);
end;
if event.arcade then begin
  //P1
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or 2);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or 4);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or 8);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.start[0] then marcade.in1:=(marcade.in1 and $7f) else marcade.in1:=(marcade.in1 or $80);
end;
end;

procedure gg_principal;
var
  frame:single;
  f:word;
begin
init_controls(false,false,true,true);
frame:=z80_0.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to (vdp_0.VIDEO_Y_TOTAL-1) do begin
      z80_0.run(frame);
      frame:=frame+z80_0.tframes-z80_0.contador;
      vdp_0.refresh(f);
  end;
  actualiza_trozo(61,51,160,144,1,0,0,160,144,PANT_TEMP);
  eventos_gg;
  video_sync;
end;
end;

function gg_getbyte(direccion:word):byte;
begin
case direccion of
  0..$3fff:gg_getbyte:=mapper_sms.rom[mapper_sms.slot0,direccion];
  $4000..$7fff:gg_getbyte:=mapper_sms.rom[mapper_sms.slot1,direccion and $3fff];
  $8000..$bfff:if mapper_sms.slot2_ram then gg_getbyte:=mapper_sms.ram_slot2[mapper_sms.slot2_bank,direccion and $3fff]
                  else gg_getbyte:=mapper_sms.rom[mapper_sms.slot2,direccion and $3fff];
  $c000..$ffff:gg_getbyte:=mapper_sms.ram[direccion and $1fff];
end;
end;

procedure gg_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$7fff:;
  $8000..$bfff:if mapper_sms.slot2_ram then mapper_sms.ram_slot2[mapper_sms.slot2_bank,direccion and $3fff]:=valor;
  $c000..$fffb:mapper_sms.ram[direccion and $1fff]:=valor;
  $fffc..$ffff:begin
                  mapper_sms.ram[direccion and $1fff]:=valor;
                  case (direccion and $3) of
                    0:begin
                        mapper_sms.slot2_ram:=(valor and 8)<>0;
                        mapper_sms.slot2_bank:=(valor and 4) shr 2;
                        //if (valor and $3<>0) then MessageDlg('Escribe $fffc '+inttohex(valor,2), mtInformation,[mbOk], 0);
                      end;
                    1:mapper_sms.slot0:=valor mod mapper_sms.max;
                    2:mapper_sms.slot1:=valor mod mapper_sms.max;
                    3:mapper_sms.slot2:=valor mod mapper_sms.max;
                  end;
               end;
end;
end;

function gg_inbyte(puerto:word):byte;
begin
  puerto:=puerto and $ff;
  case puerto of
    0:gg_inbyte:=marcade.in1 or $40;
    1..6:gg_inbyte:=io_gg[puerto];
    7..$3f,$c2..$db,$de..$ff:gg_inbyte:=$ff;
    $40..$7f:if (puerto and 1)<>0 then gg_inbyte:=vdp_0.hpos
                else gg_inbyte:=vdp_0.linea_back;
    $80..$bf:if (puerto and $01)<>0 then gg_inbyte:=vdp_0.register_r
          else gg_inbyte:=vdp_0.vram_r;
    $c0,$dc:gg_inbyte:=marcade.in0;
    $c1,$dd:gg_inbyte:=$ff;
  end;
end;

procedure gg_putbyte_codemasters(direccion:word;valor:byte);
begin
case direccion of
  0:mapper_sms.slot0:=valor mod mapper_sms.max; //mapper slot 0
  $4000:mapper_sms.slot1:=valor mod mapper_sms.max; //mapper slot 1
  $8000:mapper_sms.slot2:=valor mod mapper_sms.max; //mapper slot 2
  $c000..$ffff:mapper_sms.ram[direccion and $1fff]:=valor;
end;
end;

procedure memory_control(valor:byte);
begin
  //bios_enabled:=(valor and 8)=0;
end;

procedure gg_outbyte(puerto:word;valor:byte);
begin
  case (puerto and $ff) of
    0..6:io_gg[puerto and $ff]:=valor;
    7..$3f:if (puerto and $1)=0 then memory_control(valor);
    $40..$7f:sn_76496_0.Write(valor);
    $80..$bf:if (puerto and $1)<>0 then vdp_0.register_w(valor)
                else vdp_0.vram_w(valor);
    $c0..$ff:;
  end;
end;

procedure gg_interrupt(int:boolean);
begin
  if int then z80_0.change_irq(ASSERT_LINE)
     else z80_0.change_irq(CLEAR_LINE);
end;

procedure gg_sound_update;
begin
  sn_76496_0.update;
end;

procedure gg_set_hpos(estados:word);
begin
  vdp_0.set_hpos(z80_0.contador);
end;

function abrir_cartucho_gg(data:pbyte;long:dword):boolean;
var
  ptemp:pbyte;
  long_temp:dword;
begin
//cargar roms
ptemp:=data;
mapper_sms.max:=0;
if (long mod $4000)=512 then begin
  inc(ptemp,512);
  long_temp:=long-512;
end else long_temp:=long;
while long_temp>0 do begin
  if long_temp<$4000 then begin
    copymemory(@mapper_sms.rom[mapper_sms.max,0],ptemp,long_temp);
    long_temp:=0;
  end else begin
    copymemory(@mapper_sms.rom[mapper_sms.max,0],ptemp,$4000);
    inc(ptemp,$4000);
    long_temp:=long_temp-$4000;
  end;
  mapper_sms.max:=mapper_sms.max+1;
end;
abrir_cartucho_gg:=true;
end;

procedure reset_gg;
var
    z80_r:npreg_z80;
begin
 z80_0.reset;
 z80_r:=z80_0.get_internal_r;
 z80_r.sp:=$dfeb;
 z80_r.bc.w:=$ff3c;
 z80_r.bc2.w:=$300;
 z80_r.de2.w:=$c73c;
 z80_r.hl.w:=$2;
 z80_r.hl2.w:=$c739;
 z80_r.a:=$14;
 sn_76496_0.reset;
 vdp_0.reset;
 reset_audio;
 mapper_sms.slot2_ram:=false;
 bios_enabled:=true;
 marcade.in0:=$ff;
 marcade.in1:=$80;
 mapper_sms.slot0:=0;
 mapper_sms.slot1:=1 mod mapper_sms.max;
 mapper_sms.slot2:=2 mod mapper_sms.max;
 mapper_sms.slot3:=0;
 mapper_sms.slot2_bank:=0;
 io_gg[0]:=$c0;
 io_gg[1]:=$7f;
 io_gg[2]:=$ff;
 io_gg[3]:=0;
 io_gg[4]:=$ff;
 io_gg[5]:=0;
 io_gg[6]:=$ff;
end;

function abrir_gg:boolean;
var
  extension,nombre_file,RomFile:string;
  datos:pbyte;
  longitud,crc:integer;
  resultado:boolean;
  crc_val:dword;
begin
  if not(OpenRom(StGG,RomFile)) then begin
    abrir_gg:=true;
    EmuStatusTemp:=EsRuning;
    principal1.timer1.Enabled:=true;
    exit;
  end;
  abrir_gg:=false;
  extension:=extension_fichero(RomFile);
  if extension='ZIP' then begin
    if not(search_file_from_zip(RomFile,'*.gg',nombre_file,longitud,crc,true)) then
    getmem(datos,longitud);
    if not(load_file_from_zip(RomFile,nombre_file,datos,longitud,crc,true)) then begin
      freemem(datos);
      exit;
    end;
  end else begin
    if (extension<>'GG') then exit;
    if not(read_file_size(RomFile,longitud)) then exit;
    getmem(datos,longitud);
    if not(read_file(RomFile,datos,longitud)) then begin
      freemem(datos);
      exit;
    end;
    nombre_file:=extractfilename(RomFile);
  end;
  //Abrirlo
  extension:=extension_fichero(nombre_file);
  z80_0.change_ram_calls(gg_getbyte,gg_putbyte);
  resultado:=abrir_cartucho_gg(datos,longitud);
  vdp_0.set_gg(true);
  if resultado then begin
    llamadas_maquina.open_file:=nombre_file;
    abrir_gg:=true;
    crc_val:=calc_crc(datos,longitud);
    case crc_val of
      $9fa727a0,$fb481971,$d9a7f170,$6caa625b,$152f0dcc,$72981057:begin //Codemasters
          z80_0.change_ram_calls(gg_getbyte,gg_putbyte_codemasters);
      end;
    end;
    reset_gg;
    EmuStatusTemp:=EsRuning;
    principal1.timer1.Enabled:=true;
  end else begin
    MessageDlg('Error cargando snapshot/ROM.'+chr(10)+chr(13)+'Error loading the snapshot/ROM.', mtInformation,[mbOk], 0);
    llamadas_maquina.open_file:='';
  end;
  change_caption;
  Directory.gg:=ExtractFilePath(romfile);
  freemem(datos);
end;

function read_memory(direccion:word):byte;
begin
  read_memory:=vdp_0.tms.mem[direccion];
end;

procedure write_memory(direccion:word;valor:byte);
begin
  vdp_0.tms.mem[direccion]:=valor;
end;

procedure gg_grabar_snapshot;
begin
end;

function iniciar_gg:boolean;
begin
iniciar_gg:=false;
//Mapper
getmem(mapper_sms,sizeof(tmapper_sms));
iniciar_audio(false);
screen_init(1,284,243);
iniciar_video(160,144);
z80_0:=cpu_z80.create(CLOCK_NTSC,LINES_NTSC);
//VDP
vdp_0:=vdp_chip.create(1,gg_interrupt,z80_0.numero_cpu,read_memory,write_memory);
vdp_0.video_ntsc(0);
sn_76496_0:=sn76496_chip.Create(CLOCK_NTSC);
//Main CPU
z80_0.change_ram_calls(gg_getbyte,gg_putbyte);
z80_0.change_io_calls(gg_inbyte,gg_outbyte);
z80_0.init_sound(gg_sound_update);
z80_0.change_misc_calls(gg_set_hpos,nil);
//final
mapper_sms.max:=1;
abrir_gg;
iniciar_gg:=true;
end;

procedure cerrar_gg;
begin
if mapper_sms<>nil then freemem(mapper_sms);
mapper_sms:=nil;
end;

procedure cargar_gg;
begin
principal1.BitBtn10.Glyph:=nil;
principal1.imagelist2.GetBitmap(4,principal1.BitBtn10.Glyph);
principal1.BitBtn10.OnClick:=principal1.fLoadCartucho;
llamadas_maquina.iniciar:=iniciar_gg;
llamadas_maquina.bucle_general:=gg_principal;
llamadas_maquina.close:=cerrar_gg;
llamadas_maquina.reset:=reset_gg;
llamadas_maquina.cartuchos:=abrir_gg;
llamadas_maquina.grabar_snapshot:=gg_grabar_snapshot;
llamadas_maquina.fps_max:=FPS_NTSC;
end;

end.
