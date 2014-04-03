unit HssSMS;

interface

uses
  System.SysUtils, System.Classes,System.Generics.Collections
{$IF Defined(ANDROID)}
  ,FMX.Helpers.Android,
  AndroidAPI.JNI.GraphicsContentViewText,
  AndroidAPI.JNI.JavaTypes,
  AndroidAPI.JNI.OS,Androidapi.JNI.Net,Androidapi.JNI.Provider
  {$ENDIF}
  ;

type
  TSMS=class
    _id:int64;
    Thread_id:int64;
    Address:string;
    Person:string;
    Date:int64;
    Date_sent:int64;
    Protocol:int64;
    isRead:Boolean;
    Status:int64;
    sms_type:int64;
    Reply_path_present:Boolean;
    Subject:string;
    Body:string;
    Service_center:string;
    Locked:Boolean;
    Sub_id:int64;
    Error_code:int64;
    Seen:Boolean;
    Semc_message_priority:string;
    Parent_id:String;
    Delivery_status:String;
    Star_status:string;
    Sequence_time:int64;
    Somc_scts:int64;
    Server_time:int64;
  end;

  THssSMS = class(TComponent)
  private
    { Private declarations }
  protected
    { Protected declarations }
  public
    SMSArray:TList<TSMS>;
    constructor Create(AOwner: TComponent); override;
    function ReadAllMessages(MsgPath:string):integer;
    function ReadInBoxLastMessage:TSMS;
    function ReadLastMessageIn(MsgPath:string):TSMS;
    function GetMessageById(MsgId:Integer):TSMS;
    function SaveAllMessages(fname:string):Boolean;
    function LoadAllMessages(fname:string):Boolean;

    { Public declarations }
  published
    { Published declarations }
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('HSSMobileTools', [THssSMS]);
end;

{ THssSMS }

constructor THssSMS.Create(AOwner: TComponent);
begin
  inherited;
  if csDesigning in ComponentState then Exit;
  SMSArray:=TList<TSMS>.Create;

end;
{$IF Defined(ANDROID)}
var
  Nv:TDictionary<string,integer>;

  function GetIndexIfAlreadySaved(st:string):integer;
  var
    v:Integer;
  begin
    Result:=-1;
    v:=-1;
    if not Assigned(Nv) then nv:=TDictionary<string,integer>.Create();
    if Nv.TryGetValue(st,v) then Result:=v;
  end;

  function GetStringValue(cursor:JCursor ;st:string):string;
  var
    i:Integer;
  begin
    i:=GetIndexIfAlreadySaved(st);
    if i<0 then
    begin
      i:=cursor.getColumnIndexOrThrow(StringToJString(st));
      if Assigned(Nv) then Nv.Add(st,i);
    end;
    if i>=0 then Result:=JStringToString(cursor.getString(i));
  end;

  function GetLongIntValue(cursor:JCursor ;st:string):Int64;
  var
    i:Integer;
  begin
    i:=GetIndexIfAlreadySaved(st);
    if i<0 then
    begin
      i:=cursor.getColumnIndexOrThrow(StringToJString(st));
      if Assigned(Nv) then Nv.Add(st,i);
    end;
    if i>=0 then Result:=cursor.getLong(i);
  end;

  function GetBooleanValue(cursor:JCursor ;st:string):Boolean;
  var
    i:Integer;
  begin
    i:=GetIndexIfAlreadySaved(st);
    if i<0 then
    begin
      i:=cursor.getColumnIndexOrThrow(StringToJString(st));
      if Assigned(Nv) then Nv.Add(st,i);
    end;
    if i>=0 then Result:=cursor.getInt(i)=1;
  end;
{$ENDIF}


function THssSMS.GetMessageById(MsgId: Integer): TSMS;
begin

end;

function THssSMS.LoadAllMessages(fname: string): Boolean;
begin

end;

function THssSMS.ReadAllMessages(MsgPath:string): integer;
{$IF Defined(ANDROID)}
var
    cursor: JCursor;
    u:TJUri_Builder;
    uri: Jnet_Uri;
    uric:Jnet_UriClass;
    i,j:Integer;
    s,body,senderaddress:string;
    sentdate:Int64;
    sms:TSMS;
    ClearState:Boolean;
    function CreateSMSAndAdd:Boolean;
    begin
      sms:=nil;
      sms:=TSMS.Create;
        with sms do
        begin
          Body:=GetStringValue(cursor, 'body');
          Address:=GetStringValue(cursor, 'address');
          Person:=GetStringValue(cursor, 'person');
          Subject:=GetStringValue(cursor, 'subject');
          Service_center:=GetStringValue(cursor, 'service_center');
          Semc_message_priority:=GetStringValue(cursor,'semc_message_priority');
          Parent_id:=GetStringValue(cursor, 'parent_id');
          Delivery_status:=GetStringValue(cursor, 'delivery_status');
          Star_status:=GetStringValue(cursor, 'star_status');

          _id:=GetLongIntValue(cursor,'_id');
          Thread_id:=GetLongIntValue(cursor,'thread_id');
          Date:=GetLongIntValue(cursor,'date');
          Date_sent:=GetLongIntValue(cursor,'date_sent');
          Protocol:=GetLongIntValue(cursor,'protocol');
          Status:=GetLongIntValue(cursor,'status');
          sms_type:=GetLongIntValue(cursor,'type');
          Sub_id:=GetLongIntValue(cursor,'sub_id');
          Error_code:=GetLongIntValue(cursor,'error_code');
          Sequence_time:=GetLongIntValue(cursor,'sequence_time');
          Somc_scts:=GetLongIntValue(cursor,'somc_scts');
          Server_time:=GetLongIntValue(cursor,'server_time');

          isRead:=GetBooleanValue(cursor,'read');
          Reply_path_present:=GetBooleanValue(cursor,'reply_path_present');
          Locked:=GetBooleanValue(cursor,'locked');
          Seen:=GetBooleanValue(cursor,'seen');
        end;
      SMSArray.Add(sms);
      FreeAndNil(sms);
    end;
begin
  result:=0;
//  SMSArray.Clear;

  uri:=TJnet_Uri.JavaClass.parse(StringToJString(MsgPath));

  cursor := SharedActivity.getContentResolver.query(uri, nil, nil,nil,nil);
  try
  Result:=cursor.getCount;
  cursor.moveToFirst;
  i:=-1;
  ClearState:=false;
  repeat
    inc(i);
    if i<SMSArray.Count then
      begin
      if SMSArray[i]._id=GetLongIntValue(cursor,'_id') then
        begin
        Continue;
        end else
        begin
           ClearState:=True;
           Break;
        end;
      end;

    CreateSMSAndAdd;
   until not cursor.moveToNext;

  if ClearState then
    begin
    cursor.moveToFirst;
    SMSArray.Clear;
    repeat
      CreateSMSAndAdd;
    until not cursor.moveToNext;

    end;
  finally
  cursor.close;
  end;
end;
{$ELSE}
begin
  Result:=0;
end;

{$ENDIF}


function THssSMS.ReadLastMessageIn(MsgPath: string): TSMS;
{$IF Defined(ANDROID)}
var
    cursor: JCursor;
    u:TJUri_Builder;
    uri: Jnet_Uri;
    uric:Jnet_UriClass;
    i,j:Integer;
    s,body,senderaddress:string;
    sentdate:Int64;
begin
  result:=TSMS.Create;

  uri:=TJnet_Uri.JavaClass.parse(StringToJString(MsgPath));

  cursor := SharedActivity.getContentResolver.query(uri, nil, nil,nil,nil);
  cursor.moveToNext;

  Result.Body:=GetStringValue(cursor, 'body');
  Result.Address:=GetStringValue(cursor, 'address');
  Result.Person:=GetStringValue(cursor, 'person');
  Result.Subject:=GetStringValue(cursor, 'subject');
  Result.Service_center:=GetStringValue(cursor, 'service_center');
  Result.Semc_message_priority:=GetStringValue(cursor,'semc_message_priority');
  Result.Parent_id:=GetStringValue(cursor, 'parent_id');
  Result.Delivery_status:=GetStringValue(cursor, 'delivery_status');
  Result.Star_status:=GetStringValue(cursor, 'star_status');

  Result._id:=GetLongIntValue(cursor,'_id');
  Result.Thread_id:=GetLongIntValue(cursor,'thread_id');
  Result.Date:=GetLongIntValue(cursor,'date');
  Result.Date_sent:=GetLongIntValue(cursor,'date_sent');
  Result.Protocol:=GetLongIntValue(cursor,'protocol');
  Result.Status:=GetLongIntValue(cursor,'status');
  Result.sms_type:=GetLongIntValue(cursor,'type');
  Result.Sub_id:=GetLongIntValue(cursor,'sub_id');
  Result.Error_code:=GetLongIntValue(cursor,'error_code');
  Result.Sequence_time:=GetLongIntValue(cursor,'sequence_time');
  Result.Somc_scts:=GetLongIntValue(cursor,'somc_scts');
  Result.Server_time:=GetLongIntValue(cursor,'server_time');

  Result.isRead:=GetBooleanValue(cursor,'read');
  Result.Reply_path_present:=GetBooleanValue(cursor,'reply_path_present');
  Result.Locked:=GetBooleanValue(cursor,'locked');
  Result.Seen:=GetBooleanValue(cursor,'seen');



  cursor.close;

end;
{$ELSE}
begin
  Result:=nil;
end;
{$ENDIF}

function THssSMS.SaveAllMessages(fname: string): Boolean;
begin

end;

function THssSMS.ReadInBoxLastMessage: TSMS;
begin
  Result:=ReadLastMessageIn('content://sms/inbox');
end;

end.
