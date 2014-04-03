unit HSSBattery;

interface

uses
  System.SysUtils, System.Classes
{$IF Defined(ANDROID)}

  ,FMX.Helpers.Android,
  AndroidAPI.JNI.GraphicsContentViewText,
  AndroidAPI.JNI.JavaTypes,
  AndroidAPI.JNI.OS,Androidapi.JNI.Net,Androidapi.JNI.Provider
{$ENDIF}
  ;

type
  THSSBattery = class(TComponent)
  private
    FBatteryLevel: integer;
    function GetBatteryLevel: integer;
    { Private declarations }
  protected
    { Protected declarations }
  public
    constructor Create(AOwner: TComponent); override;

    { Public declarations }
  published
  property BatteryLevel:integer read GetBatteryLevel;
    { Published declarations }
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('HSSMobileTools', [THSSBattery]);
end;

{ THSSBattery }

constructor THSSBattery.Create(AOwner: TComponent);
begin
  inherited;
  if csDesigning in ComponentState then Exit;


end;


function THSSBattery.GetBatteryLevel: integer;
{$IF Defined(ANDROID)}
var
  filter: JIntentFilter;
  battery: JIntent;
  level, scale: Integer;
begin
  result:=0;
  if csDesigning in ComponentState then Exit;

  filter := TJIntentFilter.JavaClass.init(TJIntent.JavaClass.ACTION_BATTERY_CHANGED);
  battery := SharedActivityContext.registerReceiver(NIL, filter);
  level := battery.getIntExtra(StringToJString('level'), -1);
  scale := battery.getIntExtra(StringToJString('scale'), -1);

  result := (100 * level) div scale;

end;
{$ELSE}
begin
  Result:=0;
end;
{$ENDIF}

end.
