program ProjectVCL1;

uses

  FMX.Forms,
  Vcl.Forms,
  UnitVCL1 in 'UnitVCL1.pas' {Form93};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm93, Form93);
  Application.Run;
end.
