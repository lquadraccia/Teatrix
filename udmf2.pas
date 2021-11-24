unit uDMF2;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ZConnection, ZDataset;

type

  { Tarch }

  Tarch = class
  public
    nombreArc:string;
    fila:Integer;

    procedure procesarRegistro(lsR:TStringList);virtual;
    procedure usuarioPais(fecha:TdateTime;EUID:String;var pais,CusID:string);
    function completoTAgent(nombre,tipo:string):Integer;
    function RecuperoTAgent(nombre,tipo:string):Integer;
    function completoDuracion(AssetID:string):Integer;
    procedure completoTConsumoObraPais(idVerizon,Pais:String;Milisegundos:Integer;fecha:TDate);
    procedure completotConsumoHoraPais(fecha:TDate;Hora:Integer;Pais:String;blocks,Milisegundos:Integer);
  end;





  { TDMF2 }

  TDMF2 = class(TDataModule)
    ZConnection: TZConnection;
    procedure DataModuleCreate(Sender: TObject);
  private

  public
    PD2:TStringList;
    function sqlRun(sql:string):TZQuery;
    procedure procesarArch(arch:String;tipoArch:Tarch);
  end;


  { TarchPlay }

  TarchPlay = class(Tarch)
  public
    Plays_Feha,
    Plays_Hora,
    Plays_AssetID,
    Plays_Evento,
    Plays_IP,
    Plays_UserAgent,
    Plays_EUID,
    Plays_SessionID:String;
    idPais:String;
    idAgente,AssetsDuracion:Integer;
    procedure procesarRegistro(lsR:TStringList); override;
    procedure initTplays;
  end;


  { TarchSlice }

  TarchSlice= class(Tarch)
  public
    slice_Fecha,
    slice_Hora,
    slice_AssetID,
    slice_Nro,
    slice_EUID,
    slice_SessionID,
    slice_duracion,
    slice_pefil:String;

    procedure procesarRegistro(lsR:TStringList); override;
    procedure actualizartPlays;
  end;

var
  DMF2: TDMF2;

implementation

{$R *.lfm}

uses inifiles,ufuncionesTeatrix,math;

{ TarchSlice }

procedure TarchSlice.procesarRegistro(lsR: TStringList);
begin

  Slice_Fecha := lsR.Strings[0];
  Slice_Hora := lsR.Strings[1];
  Slice_AssetID := lsR.Strings[3];
  slice_Nro := lsR.Strings[4];
  slice_EUID:= lsR.Strings[9];
  slice_SessionID := lsR.Strings[10];
  slice_duracion := lsR.Strings[14];
  slice_pefil := lsR.Strings[15];

  actualizartPlays;
end;


function HexStrToStr(const HexStr: ansiString): ansiString;
var
  ResultLen: Integer;
begin
  ResultLen := Length(HexStr) div 2;
  SetLength(Result, ResultLen);
  if ResultLen > 0 then
    SetLength(Result, HexToBin(Pointer(HexStr), Pointer(Result), ResultLen));
end;

function StrToHexStr(const S: ansiString): ansiString;
var
  ResultLen: Integer;
begin
  ResultLen := Length(S) * 2;
  SetLength(Result, ResultLen);
  if ResultLen > 0 then
    BinToHex(Pointer(S), Pointer(Result), Length(S));
end;


procedure TarchSlice.actualizartPlays;
var
 q1,q2:TZQuery;
 fecha,Hora:TDateTime;
 tdistribucion:AnsiString;
 d,pos,h:Integer;
 c:ansiChar;
 b:byte;
 tid,U,code:Integer;

 tidUsuario: Integer;
 tidPais:String;
 tidVerizon:String;
 tretransmits,tamDistribucion:Integer;
 tblocks,tA,tB,tC,tD,tE,tF:Integer;
 pais:String;

begin
  q1 := DMF2.sqlRun('SELECT t.* FROM tPlays t where idSession ='+QuotedStr(slice_SessionID)+
  ' and idVerizon='+QuotedStr(slice_AssetID)+' order by Inicio desc ');
  try
  try

      if q1.IsEmpty then
         Raise Exception.Create('error de interpretación');;

      fecha:= EncodeDate(StrToInt(copy(slice_Fecha,1,4)),
                             StrToInt(copy(slice_Fecha,6,2)),
                             StrToInt(copy(slice_Fecha,9,2)));

      Hora:= EncodeTime(StrToInt(copy(slice_Hora,1,2)),
                            StrToInt(copy(slice_Hora,4,2)),
                            StrToInt(copy(slice_Hora,7,2)),0);

      h := StrToInt(copy(slice_Hora,1,2));

      tid := q1.FieldByName('id').AsInteger;
      tidPais := q1.FieldByName('idPais').AsString;
      tretransmits := q1.FieldByName('retransmits').AsInteger;
      tblocks := q1.FieldByName('blocks').AsInteger;
      tidVerizon := q1.FieldByName('idVerizon').AsString;
      tidUsuario := q1.FieldByName('idUsuario').AsInteger;
      tA := q1.FieldByName('A').AsInteger;
      tB := q1.FieldByName('B').AsInteger;
      tC := q1.FieldByName('C').AsInteger;
      tD := q1.FieldByName('D').AsInteger;
      tE := q1.FieldByName('E').AsInteger;
      tF := q1.FieldByName('F').AsInteger;
      tamDistribucion := q1.FieldByName('tamDistribucion').AsInteger;

      if slice_pefil='A' then
         Inc(tA);

      if slice_pefil='B' then
         Inc(tB);

      if slice_pefil='C' then
         Inc(tC);

      if slice_pefil='D' then
         Inc(tD);

      if slice_pefil='E' then
         Inc(tE);

      if slice_pefil='F' then
         Inc(tF);


      pos := StrToInt(slice_Nro) div 8 +1;

      if pos>tamDistribucion then
         Raise Exception.Create('error de cálculo de duración');


      usuarioPais(fecha,slice_EUID,pais,slice_EUID);


      if tidUsuario<>StrToInt(slice_EUID) then
         Raise Exception.Create('error de usuario');

      q2 := DMF2.sqlRun('SELECT * FROM tPlaysDistribucion where id ='+IntToStr(tId));
      tdistribucion := q2.FieldByName('distribucion').AsString;
      q2.Free;

      tdistribucion := HexStrToStr(tdistribucion);
      c := tdistribucion[pos];

      b := StrToInt(slice_Nro) mod 8;
      b := 1 shl b;

      if (ord(c) and b)=0 then
      begin
         tblocks := tblocks + 1;
         c :=AnsiChar(Ord(c) or ord(b));

         tdistribucion[pos] := c;


         completotConsumoHoraPais(fecha,h,tidPais,1,Trunc(StrToFloat(slice_duracion)*1000));
         completoTConsumoObraPais(tidVerizon,tidPais,Trunc(StrToFloat(slice_duracion)*1000),fecha);
      end else begin
         tretransmits := tretransmits + 1;

      end;

      tdistribucion := StrToHexStr(tdistribucion);
      DMF2.sqlRun('UPDATE tPlaysDistribucion set distribucion='+QuotedStr(tdistribucion)+
      ' where id ='+IntToStr(tid)).free;

      DMF2.sqlRun('UPDATE tPlays set retransmits='+IntToStr(tretransmits)+
      ',blocks='+IntToStr(tblocks)+',A='+IntToStr(tA)+',B='+IntToStr(tB)+',C='+IntToStr(tC)+',D='+IntToStr(tD)+',E='+IntToStr(tE)+',F='+IntToStr(tF)+
      ' where id ='+IntToStr(tid)).free;

  except
    on e:Exception do
    begin
      grabarEnArchivoLog(nombreArc+' Fila:'+IntToStr(fila)+' - Error:'+e.Message);
    end;
  end;

  finally
    q1.free;
  end;

end;

{ Tarch }

procedure Tarch.procesarRegistro(lsR: TStringList);
begin

end;


procedure Tarch.usuarioPais(fecha:TdateTime;EUID:String;var pais, CusID: string);
var
 c,v:Integer;
begin
  if EUID='-' then begin
     CusID:='0';
     Pais:='UND';
     Exit;
  end;

  if UpperCase(EUID)='GUEST' then begin
     CusID:='0';
     Pais:='UND';
     Exit;
  end;



  If EUID[1] in ['0'..'9'] then begin
    CusID:=EUID;
    Pais:='UND';
  end else if EUID[1] in ['A'..'Z']then begin
    Pais:= LeftStr(EUID ,3);
    CusID:=RightStr(EUID, Length(EUID)-4);
  end;


  Val(CusID,v,c);
  if c>0 then
     CusID:='0';

  if fecha>0 then
    if fecha<EncodeDate(2021,4,27) then
       if PAIS='UND' then
          PAIS := 'ARG';

end;

{ TarchPlay }

function Tarch.completoTAgent(nombre, tipo: string): Integer;
var
 q1,q2:TZQuery;
begin
  Result := RecuperoTAgent(nombre,tipo);
  if Result = -1 then begin
     q2 := DMF2.sqlRun('INSERT INTO tAgent(nombre,tipo) VALUES ('+QuotedStr(nombre)+','+QuotedStr(tipo)+')');
     q2.Free;
     q1 := DMF2.sqlRun('SELECT LAST_INSERT_ID() as ID');
     Result := q1.FieldByName('ID').AsInteger;
     q1.free;
  end;
end;

function Tarch.RecuperoTAgent(nombre, tipo: string): Integer;
var
 q1:TZQuery;
begin
  Result := -1;
  q1 := DMF2.sqlRun('SELECT ID,nombre,tipo FROM tAgent where nombre ='+QuotedStr(nombre));
  if not q1.IsEmpty then begin
     Result := q1.FieldByName('ID').AsInteger;
  end;
  q1.free;
end;

function Tarch.completoDuracion(AssetID: string): Integer;
var
 q1:TZQuery;
begin
  Result := 0;
  q1 := DMF2.sqlRun('SELECT duracion,tipo FROM tAssets where idVerizon ='+QuotedStr(AssetID));
  Result := q1.FieldByName('duracion').AsInteger;
  q1.free;
end;

procedure Tarch.completoTConsumoObraPais(idVerizon, Pais: String;
  Milisegundos: Integer; fecha: TDate);
begin

  DMF2.sqlRun(' INSERT INTO tConsumoObraPais(fecha,idVerizon,Pais,Milisegundos) '+
     'VALUES('+QuotedStr(FormatDateTime('YYYY-MM-DD',fecha))+','+QuotedStr(idVerizon)+','+QuotedStr(Pais)+','+IntToStr(Milisegundos)+') ON DUPLICATE KEY UPDATE '+
     ' Milisegundos = Milisegundos + VALUES(Milisegundos) ').free;
end;

procedure Tarch.completotConsumoHoraPais(fecha: TDate; Hora: Integer;
  Pais: String; blocks, Milisegundos: Integer);
begin
  DMF2.sqlRun(' INSERT INTO tConsumoHoraPais(fecha,HORA,Pais,bloques,Milisegundos) '+
     'VALUES('+QuotedStr(FormatDateTime('YYYY-MM-DD',fecha))+','+IntToStr(Hora)+','+QuotedStr(Pais)+','+IntToStr(blocks)+','+IntToStr(Milisegundos)+') ON DUPLICATE KEY UPDATE '+
     ' bloques = bloques + VALUES(bloques), Milisegundos = Milisegundos + VALUES(Milisegundos) ').free;
end;

procedure TarchPlay.procesarRegistro(lsR: TStringList);
begin

  Plays_Feha := lsR.Strings[0];
  Plays_Hora := lsR.Strings[1];
  Plays_Evento:=lsR.Strings[2];
  Plays_AssetID := lsR.Strings[3];
  Plays_IP := lsR.Strings[4];
  Plays_UserAgent := lsR.Strings[5];
  Plays_EUID := lsR.Strings[9];
  Plays_SessionID := lsR.Strings[10];
  AssetsDuracion:=completoDuracion(Plays_AssetID);
  idAgente := completoTAgent(Plays_UserAgent,'');
  initTplays;
end;

procedure TarchPlay.initTplays;
var
 q1,q3:TZQuery;
 distribucion:AnsiString;
 d,tamDistribucion,id:Integer;
 fechaHora:TDateTime;
begin
  q1 := DMF2.sqlRun('SELECT * FROM tPlays where idSession ='+QuotedStr(Plays_SessionID)+
  ' and idVerizon='+QuotedStr(Plays_AssetID));
  try
  if not q1.IsEmpty then Exit;

  fechaHora:= EncodeDate(StrToInt(copy(Plays_Feha,1,4)),
                         StrToInt(copy(Plays_Feha,6,2)),
                         StrToInt(copy(Plays_Feha,9,2)));


  usuarioPais(fechaHora,Plays_EUID,idPais,Plays_EUID);


  fechaHora:=fechaHora +
             EncodeTime(StrToInt(copy(Plays_Hora,1,2)),
                        StrToInt(copy(Plays_Hora,4,2)),
                        StrToInt(copy(Plays_Hora,7,2)),0);

  distribucion := '';
  for d:=1 to (ceil(AssetsDuracion/4.096/8)+1) do
    distribucion := distribucion + AnsiChar(0);


  tamDistribucion := Length(distribucion);
  distribucion := StrToHexStr(distribucion);


    DMF2.sqlRun('INSERT INTO tPlays(idSession,Inicio,idUsuario,idPais,idVerizon,ip,IdAgente,retransmits,'+
                                        'blocks,A,B,C,D,E,F,G,tamDistribucion) VALUES ('+
    QuotedStr(Plays_SessionID)+','+
    QuotedStr(FormatDateTime('YYYY-MM-DD HH:mm:SS',fechaHora))+','+
    Plays_EUID+','+
    QuotedStr(idPais)+','+
    QuotedStr(Plays_AssetID)+','+
    QuotedStr(Plays_IP)+','+
    IntToStr(idAgente)+','+
    '0,0,0,0,0,0,0,0,0'+','+
    IntToStr(tamDistribucion)+')').free;

    q3 := DMF2.sqlRun('SELECT LAST_INSERT_ID() as ID');
    id := q3.FieldByName('ID').AsInteger;
    q3.free;

    DMF2.sqlRun('INSERT INTO tPlaysDistribucion(id,Distribucion) VALUES ('+
      IntToStr(id)+','+
      QuotedStr(distribucion)+')').free;

  finally
      q1.free;
  end;

end;

{ TDMF2 }

procedure TDMF2.DataModuleCreate(Sender: TObject);
var
  inifile:TIniFile;
begin
 inifile:= TIniFile.Create(myPath+'config.ini');
 try
   ZConnection.Disconnect;
   ZConnection.HostName := inifile.ReadString('db','HostName','');
   ZConnection.User := inifile.ReadString('db','User','');
   ZConnection.Password := inifile.ReadString('db','Password','');
   ZConnection.Database:= inifile.ReadString('db','Database','');
   ZConnection.Connect;
 finally
   inifile.free;
 end;
end;


function TDMF2.sqlRun(sql: string): TZQuery;
var
   ZQuery1:TZQuery;
begin
  try
    ZQuery1:=TZQuery.Create(nil);
    Result := ZQuery1;
    ZQuery1.Connection := ZConnection;
    ZQuery1.close;
    ZQuery1.SQL.Text:= sql;
    if UpperCase(trim(sql[1]))='S' then
       ZQuery1.Open
    else
       ZQuery1.ExecSQL;

  except
    on e:Exception do
    begin
      grabarEnArchivoLog('Error:'+e.Message+' '+sql);
    end;
  end;
end;


procedure TDMF2.procesarArch(arch: String; tipoArch: Tarch);
var
  lsFilas:TStringList;
  lsColumnas:TStringList;
  f:Integer;
begin
  tipoArch.nombreArc := arch;
  lsFilas:= TStringList.Create;
  try
    lsFilas.LoadFromFile(arch);

    for f:=0 to lsFilas.Count-1 do
    begin
      tipoArch.fila:= f+1;
      lsColumnas:=TStringList.Create;
      try

         lsColumnas.Text:=StringReplace(lsFilas.Strings[f],#9,#13#10,[rfReplaceAll]);
         tipoArch.procesarRegistro(lsColumnas);
        // Sleep(2);
      finally
        lsColumnas.free;
      end;
    end;
  finally
    lsFilas.Free;
  end;

end;


end.

