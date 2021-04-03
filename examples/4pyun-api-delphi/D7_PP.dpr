program D7_PP;

uses
  Forms,
  PPDemo_Unt in 'PPDemo_Unt.pas' {PPDemo_Frm},
  PPSDK in 'PPSDK.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TPPDemo_Frm, PPDemo_Frm);
  Application.Run;
end.
