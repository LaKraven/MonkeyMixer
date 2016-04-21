unit MonkeyMixer.Wizard;

interface

uses
  Classes, VCL.Dialogs, ToolsAPI, SysUtils, StrUtils, UITypes;

type
  TMonkeyMixerMenu = class(TNotifierObject, IOTANotifier, IOTAProjectMenuItemCreatorNotifier)
  protected
    procedure AddMenu(const Project: IOTAProject; const IdentList: TStrings; const ProjectManagerMenuList: IInterfaceList; IsMultiSelect: Boolean);
  end;

  TMonkeyMixerTogglerMenuItem = class(TInterfacedObject, IOTANotifier, IOTALocalMenu, IOTAProjectManagerMenu)
  private
    FCaption: String;
    FChecked: Boolean;
    FEnabled: Boolean;
    FFrameworkType: String;
    FProject: IOTAProject150;
    FHelpContext: Integer;
    FName: String;
    FParent: String;
    FPosition: Integer;
    FVerb: String;
  protected
    // IOTANotifier Methods
    procedure AfterSave;  // Not used!
    procedure BeforeSave; // Not used!
    procedure Destroyed;
    procedure Modified; // Not used!
    // IOTALocalMenu Methods
    function GetCaption: string;
    function GetChecked: Boolean;
    function GetEnabled: Boolean;
    function GetHelpContext: Integer;
    function GetName: string;
    function GetParent: string;
    function GetPosition: Integer;
    function GetVerb: string;
    procedure SetCaption(const Value: string);
    procedure SetChecked(Value: Boolean);
    procedure SetEnabled(Value: Boolean);
    procedure SetHelpContext(Value: Integer);
    procedure SetName(const Value: string);
    procedure SetParent(const Value: string);
    procedure SetPosition(Value: Integer);
    procedure SetVerb(const Value: string);
    // IOTAProjectManagerMenu Methods
    function GetIsMultiSelectable: Boolean;
    procedure SetIsMultiSelectable(Value: Boolean);
    procedure Execute(const MenuContextList: IInterfaceList); overload;
    function PreExecute(const MenuContextList: IInterfaceList): Boolean;
    function PostExecute(const MenuContextList: IInterfaceList): Boolean;
  public
    constructor Create;
  end;

{$IFNDEF DLLEXPERT}
procedure Register;
{$ELSE}
function InitWizard(Const BorlandIDEServices: IBorlandIDEServices; RegisterProc: TWizardRegisterProc; var Terminate: TWizardTerminateProc): Boolean; stdcall;

exports
  InitWizard name WizardEntryPoint;
{$ENDIF}
implementation

uses UsesFixerParser;

var
  FWizardIndex: Integer = -1;

function InitializeWizard(BorlandIDEServices: IBorlandIDEServices): TMonkeyMixerMenu;
begin
  Result := TMonkeyMixerMenu.Create;
  {$IFNDEF VER310}
    bla
  {$ENDIF VER310}
end;

{$IFNDEF DLLEXPERT}
procedure Register;
begin
  if BorlandIDEServices <> nil then
    FWizardIndex := (BorlandIDEServices as IOTAProjectManager).AddMenuItemCreatorNotifier(InitializeWizard(BorlandIDEServices));
end;
{$ELSE}
function InitWizard(Const BorlandIDEServices: IBorlandIDEServices; RegisterProc: TWizardRegisterProc; var Terminate: TWizardTerminateProc): Boolean; stdcall;
begin
  if BorlandIDEServices <> nil then
    FWizardIndex := (BorlandIDEServices as IOTAProjectManager).AddMenuItemCreatorNotifier(InitializeWizard(BorlandIDEServices));
  Result := (BorlandIDEServices <> nil)
end;
{$ENDIF}

{ TMonkeyMixerTogglerMenuItem }

procedure TMonkeyMixerTogglerMenuItem.AfterSave;
begin
  // Not used!
end;

procedure TMonkeyMixerTogglerMenuItem.BeforeSave;
begin
  // Not used!
end;

constructor TMonkeyMixerTogglerMenuItem.Create;
begin
  inherited;
end;

procedure TMonkeyMixerTogglerMenuItem.Destroyed;
begin
  // Do Nothing!
end;

procedure TMonkeyMixerTogglerMenuItem.Execute(const MenuContextList: IInterfaceList);
const
  CN_FORMS = 'FORMS';
  CN_VCLFORMS = 'VCL.FORMS';
  CN_FMXFORMS = 'FMX.FORMS';
var
  LMenuContext: IOTAProjectMenuContext;
  LProject: IOTAProject;
  LDproj: TStringList;
  LUsesFixer: TUsesFixer;
begin
  LMenuContext := MenuContextList.Items[0] as IOTAProjectMenuContext;
  LProject := (LMenuContext.Project as IOTAProject);
  if FileExists(LProject.FileName) then
  begin
    LDproj := TStringList.Create;
    try
      LDproj.LoadFromFile(LProject.FileName);
      LDproj.Text := ReplaceText(LDproj.Text, Format('<FrameworkType>%s</FrameworkType>', [LProject.FrameworkType]), Format('<FrameworkType>%s</FrameworkType>', [FFrameworkType]));
      LDproj.SaveToFile(LProject.FileName);

      // XE3 FIX
        if LProject.FrameworkType = sFrameworkTypeVCL then
        begin
        LUsesFixer := TUsesFixer.Create;
        try
          LDproj.LoadFromFile(ChangeFileExt(LProject.FileName, '.dpr'));
          LUsesFixer.ProcessSource(LDproj.Text);
          LUsesFixer.DeleteUnit('Forms');
          LUsesFixer.AddUnitToUses('Vcl.Forms');
          LUsesFixer.AddUnitToUses('FMX.Forms');
          LDproj.Text := LUsesFixer.Source;
          LDproj.SaveToFile(ChangeFileExt(LProject.FileName, '.dpr'));
        finally
          LUsesFixer.Free;
        end;
      end;
      // XE3 FIX ENDS

      LProject.Refresh(True);
    finally
      LDproj.Free;
    end;
  end else
    if MessageDlg(Format('Project "%s" must be saved first, do you wish to save it now, then have MonkeyMixer work its magic?', [ExtractFileName(LProject.FileName)]), mtConfirmation, [mbYes, mbNo], 0) = mrYes then
      if LProject.Save(True, True) then
        Execute(MenuContextList);
end;

function TMonkeyMixerTogglerMenuItem.GetCaption: string;
begin
  Result := FCaption;
end;

function TMonkeyMixerTogglerMenuItem.GetChecked: Boolean;
begin
  Result := FChecked;
end;

function TMonkeyMixerTogglerMenuItem.GetEnabled: Boolean;
begin
  Result := FEnabled;
end;

function TMonkeyMixerTogglerMenuItem.GetHelpContext: Integer;
begin
  Result := FHelpContext;
end;

function TMonkeyMixerTogglerMenuItem.GetIsMultiSelectable: Boolean;
begin
  Result := False;
end;

function TMonkeyMixerTogglerMenuItem.GetName: string;
begin
  Result := FName;
end;

function TMonkeyMixerTogglerMenuItem.GetParent: string;
begin
  Result := FParent;
end;

function TMonkeyMixerTogglerMenuItem.GetPosition: Integer;
begin
  Result := FPosition;
end;

function TMonkeyMixerTogglerMenuItem.GetVerb: string;
begin
  Result := FVerb;
end;

procedure TMonkeyMixerTogglerMenuItem.Modified;
begin
  // Not used for IOTAWizard!
end;

function TMonkeyMixerTogglerMenuItem.PostExecute(const MenuContextList: IInterfaceList): Boolean;
begin
  Result := True;
end;

function TMonkeyMixerTogglerMenuItem.PreExecute(const MenuContextList: IInterfaceList): Boolean;
begin
  Result := True;
end;

procedure TMonkeyMixerTogglerMenuItem.SetCaption(const Value: string);
begin
  FCaption := Value;
end;

procedure TMonkeyMixerTogglerMenuItem.SetChecked(Value: Boolean);
begin
  FChecked := Value;
end;

procedure TMonkeyMixerTogglerMenuItem.SetEnabled(Value: Boolean);
begin
  FEnabled := Value;
end;

procedure TMonkeyMixerTogglerMenuItem.SetHelpContext(Value: Integer);
begin
  FHelpContext := Value;
end;

procedure TMonkeyMixerTogglerMenuItem.SetIsMultiSelectable(Value: Boolean);
begin
  // Not used!
end;

procedure TMonkeyMixerTogglerMenuItem.SetName(const Value: string);
begin
  FName := Value;
end;

procedure TMonkeyMixerTogglerMenuItem.SetParent(const Value: string);
begin
  FParent := Value;
end;

procedure TMonkeyMixerTogglerMenuItem.SetPosition(Value: Integer);
begin
  FPosition := Value;
end;

procedure TMonkeyMixerTogglerMenuItem.SetVerb(const Value: string);
begin
  FVerb := Value;
end;

{ TMonkeyMixerMenu }

procedure TMonkeyMixerMenu.AddMenu(const Project: IOTAProject; const IdentList: TStrings; const ProjectManagerMenuList: IInterfaceList; IsMultiSelect: Boolean);
var
  LMenuItem: TMonkeyMixerTogglerMenuItem;
begin
  if (not IsMultiSelect) and
     (IdentList.IndexOf(sProjectContainer) <> -1) and
     Assigned(ProjectManagerMenuList) and
     ((Project.FrameworkType = sFrameworkTypeVCL) or (Project.FrameworkType = sFrameworkTypeFMX)) and
     (Project.Personality = sDelphiPersonality) then {TODO: Fix MonkeyMixer to work with C++ Builder projects! }
  begin
    LMenuItem := TMonkeyMixerTogglerMenuItem.Create;
    // Toggeler
    if Project.FrameworkType = sFrameworkTypeVCL then
    begin
      LMenuItem.FCaption := 'Switch Project to FireMonkey';
      LMenuItem.FFrameworkType := sFrameworkTypeFMX;
    end else if Project.FrameworkType = sFrameworkTypeFMX then
    begin
      LMenuItem.FCaption := 'Switch Project to VCL';
      LMenuItem.FFrameworkType := sFrameworkTypeVCL;
    end;
    LMenuItem.FProject := (Project as IOTAProject150);
    LMenuItem.FEnabled := True;
    LMenuItem.FPosition := pmmpAdd;
    ProjectManagerMenuList.Add(LMenuItem);
  end;
end;

initialization
  // Bleh
finalization
  if FWizardIndex > -1 then
  begin
    (BorlandIDEServices as IOTAProjectManager).RemoveMenuItemCreatorNotifier(FWizardIndex);
    FWizardIndex := -1;
  end;
end.
