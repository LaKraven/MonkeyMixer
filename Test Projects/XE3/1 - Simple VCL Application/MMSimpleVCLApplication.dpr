program MMSimpleVCLApplication;

uses
  FMX.Forms,
  Vcl.Forms,
  uMainForm in 'uMainForm.pas' {Form1},
  uFMXForm in 'uFMXForm.pas' {Form2};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  ReportMemoryLeaksOnShutdown := True;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
