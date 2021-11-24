program consolaLPTeatrix;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, FileUtil, CustApp, IniFiles, ufuncionesTeatrix,uDMF2;

type



  { LPTeatrix }

  LPTeatrix = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
    SlicesdirIn,SlicesdirOut,SlicesdirError:String;
    PlaysdirIn,PlaysdirOut,PlaysdirError:String;
    SegDemora:Integer;
    moverAOut:Boolean;
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure WriteHelp; virtual;
    procedure leerINI;
    procedure recorroArchivos;
    procedure procesar(lsA:TStringList;tipoArch:Tarch;outDir:String);
  end;

{ LPTeatrix }

procedure LPTeatrix.DoRun;
var
  ErrorMsg: String;
begin
  myPath:= ExtractFilePath(ParamStr(0));

  // quick check parameters
  ErrorMsg:=CheckOptions('h', 'help');
  if ErrorMsg<>'' then begin
    ShowException(Exception.Create(ErrorMsg));
    Terminate;
    Exit;
  end;

  // parse parameters
  if HasOption('h', 'help') then begin
    WriteHelp;
    Terminate;
    Exit;
  end;

  leerINI;

  while true do
  begin
    recorroArchivos;

    if SegDemora=-1 then
       Break;
    sleep(SegDemora);
  end;


  { add your program here }
  // stop program loop
  Terminate;
end;

constructor LPTeatrix.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException:=True;
end;

destructor LPTeatrix.Destroy;
begin
  inherited Destroy;
end;

procedure LPTeatrix.WriteHelp;
begin
  { add your help code here }
  writeln('Usage: ', ExeName, ' -h');
end;

procedure LPTeatrix.leerINI;
  var
     inifile:TIniFile;
  begin
     inifile:= TIniFile.Create(myPath+'config.ini');
     try
       SlicesdirOut:= inifile.ReadString('SlicesDir','Out','');
       SlicesdirIn:= inifile.ReadString('SlicesDir','In','');
       SlicesdirError:= inifile.ReadString('SlicesDir','Err','');

       SegDemora := inifile.ReadInteger('demora','valor',60*1000);

       PlaysdirOut:= inifile.ReadString('PlaysDir','Out','');
       PlaysdirIn:= inifile.ReadString('PlaysDir','In','');
       PlaysdirError:= inifile.ReadString('PlaysDir','Err','');

       moverAOut := inifile.ReadBool('moverAOut','valor',true);

     finally
       inifile.free;
     end;

     if (SlicesdirIn='') or (SlicesdirOut='') or (PlaysdirIn='') or (PlaysdirOut='') then begin
       WriteLn('Error en el config.ini');
       Terminate;
     end;

end;


procedure LPTeatrix.recorroArchivos;
  var
    DataFilesSlice,DataFilesPlays: TStringList;
    archSlice: TarchSlice;
    archPlay: TarchPlay;
  begin
    DataFilesSlice := FindAllFiles(SlicesdirIn, '*.csv', true);
    DataFilesPlays := FindAllFiles(PlaysdirIn, '*.csv', true);
    WriteLn('Loop Procesando');
    try
      archPlay:= TarchPlay.Create;
      try
        procesar(DataFilesPlays,archPlay, PlaysdirOut)
      finally
        archPlay.free;
      end;

      archSlice:= TarchSlice.Create;
      try
        procesar(DataFilesSlice, archSlice,SlicesdirOut)
      finally
        archSlice.free;
      end;
    finally
      DataFilesSlice.free;
      DataFilesPlays.free;
    end;


    WriteLn('Loop Finalizo');
end;

procedure LPTeatrix.procesar(lsA: TStringList; tipoArch: Tarch; outDir: String);
var
  arch:String;

begin
  DMF2 := TDMF2.Create(self);
  try
    ForceDirectories(outDir);

    for arch in lsA do
    begin
      DMF2.procesarArch(arch,tipoArch);
      if moverAOut then
         CopyFile(arch,outDir+ExtractFileName(arch),true);
      DeleteFile(arch);
    end;
  finally
    DMF2.free;
  end;

end;



var
  Application: LPTeatrix;
begin
  Application:=LPTeatrix.Create(nil);
  Application.Title:='Parse Teatrix';
  Application.Run;
  Application.Free;
end.

