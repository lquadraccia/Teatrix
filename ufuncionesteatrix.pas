unit ufuncionesTeatrix;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

function normalizoDir(aDir: string): string;
procedure grabarEnArchivoLog(info: string);

var
   myPath:String;

implementation

uses IniFiles;


function normalizoDir(aDir: string): string;
begin
   Result := aDir;
   if aDir[length(aDir)] <> '/' then
   Result := aDir + '/';
end;

procedure grabarEnArchivoLog(info: string);
var
  myFile: TextFile;
  nombreArch: string;
begin
  try
    nombreArch := myPath+'LPinfo_'+FormatDateTime('YYYYMMDD',now)+'.log';
    AssignFile(myFile, nombreArch);
    if not FileExists(nombreArch) then
      ReWrite(myFile)
    else
      append(myFile);

    WriteLn(myFile, FormatDateTime('YYYY-MM-DD hh:mm:ss>', Now) + '-' + info);

    CloseFile(myFile);
  except
  end;
end;

end.

