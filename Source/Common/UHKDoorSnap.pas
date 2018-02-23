{*******************************************************************************
  ����: juner11212436@163.com 2017-12-1
  ����: �������Ÿ�ץ�������
*******************************************************************************}
unit UHKDoorSnap;

interface

uses
  Windows, Classes, SysUtils, SyncObjs, NativeXml, UWaitItem, USysLoger;

type
  PHKDoorSnapParam = ^THKDoorSnapParam;
  THKDoorSnapParam = record
    FID        : string;            //��ʶ
    FPanelID   : Integer;            //���ž����ʶ
    FName      : string;            //����
    FHost      : string;            //IP
    FPort      : Integer;           //�˿�
    
    FUser     : string;           //��½��
    FPassword : string;           //����
    FChannel  : string;           //ͨ����
    FLinkMode : Integer;          //���ӷ�ʽ
    FUserID   : Integer;          //ע��ɹ�����ID
    FRealHandle : LongInt;        //Ԥ�����ؾ��
    FFortifyHandle : Integer      //�������ؾ��
  end;

  THKDoorSnapManager = class;
  THKDoorSnapSender = class(TThread)
  private
    FOwner: THKDoorSnapManager;
    //ӵ����
    FWaiter: TWaitObject;
    //�ȴ�����
  protected
    procedure Execute; override;
  public
    constructor Create(AOwner: THKDoorSnapManager);
    destructor Destroy; override;
    //�����ͷ�
    procedure WakupMe;
    //�����߳�
    procedure StopMe;
    //ֹͣ�߳�
  end;

  THKDoorSnapManager = class(TObject)
  private
    FEnabled: Boolean;
    //�Ƿ�����
    FDoorSnaps: array of THKDoorSnapParam;
    //���б�
    FSender: THKDoorSnapSender;
    //�����߳�
    FSyncLock: TCriticalSection;
    //ͬ������
  protected
  public
    constructor Create;
    destructor Destroy; override;
    //�����ͷ�
    procedure LoadConfig(const nFile: string);
    //��ȡ����
    procedure StartSnap;
    procedure StopSnap;
    //��ͣ����
    procedure GetDoorSnapList(const nList: TStrings);
    //��ȡ�б�
    function GetDoorID(nIP: string): string;
    //��ȡ�б�
  end;

var
  gHKDoorSnapManager: THKDoorSnapManager = nil;
  //ȫ��ʹ��

implementation

uses HCNetSDK, plaympeg4, UFormMain, UDataModule, USysDB, ULibFun;

const
  sSPost_In   = 'Sin';

procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(THKDoorSnapManager, '��������ץ��', nEvent);
end;

procedure MessageCallback(lCommand: Longint; pAlarmer: LPNET_DVR_ALARMER;
               pAlarmInfo: PChar; dwBufLen: Longword; pUser: Pointer); stdcall
    var dwReturn:DWORD;
var struPlateResult:LPNET_DVR_PLATE_RESULT;
    nStr, nIP: string;
    nInt: Integer;
begin
  if (lCommand = COMM_UPLOAD_PLATE_RESULT) then
  begin
    struPlateResult := AllocMem(sizeof(NET_DVR_PLATE_RESULT));
    CopyMemory(struPlateResult,pAlarmInfo, sizeof(NET_DVR_PLATE_RESULT));

    nIp := '';
    for nInt := 0 to 127 do
      nIP := nIP + pAlarmer.sDeviceIP[nInt];
    nIP := Trim(nIP);

    nStr := Format('ץ�������[%s]ץ�ĵ����ƺ�: %s',
              [nIP, struPlateResult.struPlateInfo.sLicense]);
    WriteLog(nStr);
    fFormMain.SaveSnapTruck(nIP,struPlateResult.struPlateInfo.sLicense);
  end;
end;

//------------------------------------------------------------------------------
constructor THKDoorSnapManager.Create;
begin
  FEnabled := True;
  FSender := nil;

  FSyncLock := TCriticalSection.Create;
end;

destructor THKDoorSnapManager.Destroy;
begin
  StopSnap;
  FSyncLock.Free;
  inherited;
end;

procedure THKDoorSnapManager.StartSnap;
var nErrIdx,nIdx,nCount: Integer;
    nStruDeviceInfo: NET_DVR_DEVICEINFO_V30;
    nStruPlayInfo: NET_DVR_CLIENTINFO;
    nStr: string;
    nStruSnapCfg :NET_DVR_SNAPCFG ;
begin
  if not FEnabled then Exit;
  //xxxxx

  if Length(FDoorSnaps) < 1 then
    raise Exception.Create('DoorSnap List Is Null.');
  //xxxxx

  for nIdx:=Low(FDoorSnaps) to High(FDoorSnaps) do
  with FDoorSnaps[nIdx] do
  begin
    NET_DVR_Init();
    //1��ʼ��
    nErrIdx := NET_DVR_GetLastError();

    if nErrIdx <> 0 then
    begin

      nStr := Format('ץ�������[ %s ]��ʼ��ʧ��,����ֵ: %d', [FID, nErrIdx]);
      WriteLog(nStr);
      Exit;
    end
    else
    begin
      nStr := Format('ץ�������[ %s ]��ʼ���ɹ�', [FID]);
      WriteLog(nStr);
    end;

    FUserID:= NET_DVR_Login_V30(PAnsiChar(AnsiString(FHost)),FPort,
                                PAnsiChar(AnsiString(FUser)),
                                PAnsiChar(AnsiString(FPassword)),@nStruDeviceInfo);
    //2.ע���û�
    if FUserID < 0 then
    begin
      nErrIdx := NET_DVR_GetLastError();

      nStr := Format('ץ�������[ %s ]ע��ʧ��,����ֵ: %d', [FID, nErrIdx]);
      WriteLog(nStr);
      Exit;
    end
    else
    begin
      nStr := Format('ץ�������[ %s ]ע��ɹ�,����ֵ: %d', [FID, FUserID]);
      WriteLog(nStr);
    end;

    nStruPlayInfo.lChannel := StrtoInt(FChannel);
    nStruPlayInfo.lLinkMode := FLinkMode;       //TCP
    nStruPlayInfo.sMultiCastIP := NIL;
    case FPanelID of
      1:
        nStruPlayInfo.hPlayWnd := fFormMain.SnapView1.Handle;
      2:
        nStruPlayInfo.hPlayWnd := fFormMain.SnapView2.Handle;
      3:
        nStruPlayInfo.hPlayWnd := fFormMain.SnapView3.Handle;
      4:
        nStruPlayInfo.hPlayWnd := fFormMain.SnapView4.Handle;
      else
        nStruPlayInfo.hPlayWnd := fFormMain.SnapView1.Handle;
    end;

    FRealHandle := NET_DVR_RealPlay_V30(FUserID, @nStruPlayInfo, nil,  nil, TRUE);
    //3Ԥ��
    if FRealHandle < 0 then
    begin
      nErrIdx := NET_DVR_GetLastError();

      nStr := Format('ץ�������[ %s ]Ԥ��ʧ��,����ֵ: %d', [FID, nErrIdx]);
      WriteLog(nStr);
      Exit;
    end
    else
    begin
      nStr := Format('ץ�������[ %s ]Ԥ���ɹ�,����ֵ: %d', [FID, FRealHandle]);
      WriteLog(nStr);
    end;

    NET_DVR_SetDVRMessageCallBack_V30(@MessageCallback, nil);
    //��һ������Ϊ�ص�����ָ�룬�ڶ�������������ص��������ݲ���

    FFortifyHandle := NET_DVR_SetupAlarmChan_V30(FUserID);
    //4.����
    if FFortifyHandle < 0 then
    begin
      nErrIdx := NET_DVR_GetLastError();

      nStr := Format('ץ�������[ %s ]����ʧ��,����ֵ: %d', [FID, nErrIdx]);
      WriteLog(nStr);
      Exit;
    end
    else
    begin
      nStr := Format('ץ�������[ %s ]�����ɹ�,����ֵ: %d', [FID, FFortifyHandle]);
      WriteLog(nStr);
    end;

    for nCount :=0 to 23 do
      nStruSnapCfg.byRes2[nCount]:=0;

    nStruSnapCfg.dwSize := sizeof(NET_DVR_SNAPCFG);
    nStruSnapCfg.byRelatedDriveWay := 0;
    nStruSnapCfg.bySnapTimes := 2;
    nStruSnapCfg.wSnapWaitTime := 1000;
    nStruSnapCfg.wIntervalTime[0] := 100;
    nStruSnapCfg.wIntervalTime[1] := 0;
    nStruSnapCfg.wIntervalTime[2] := 0;
    nStruSnapCfg.wIntervalTime[3] := 0;

    NET_DVR_ContinuousShoot(FUserID,@nStruSnapCfg);
    //5.ץ��
    nErrIdx := NET_DVR_GetLastError();

    if nErrIdx <> 0 then
    begin

      nStr := Format('ץ�������[ %s ]����ץ��ʧ��,����ֵ: %d', [FID, nErrIdx]);
      WriteLog(nStr);
      Exit;
    end
    else
    begin
      nStr := Format('ץ�������[ %s ]����ץ�ĳɹ�', [FID]);
      WriteLog(nStr);
    end;
  end;

  if not Assigned(FSender) then
    FSender := THKDoorSnapSender.Create(Self);
  FSender.WakupMe;
end;

procedure THKDoorSnapManager.StopSnap;
var nIdx: Integer;
begin
  if Assigned(FSender) then
    FSender.StopMe;
  //xxxxx

  FSender := nil;

  try
    for nIdx:=Low(FDoorSnaps) to High(FDoorSnaps) do
    with FDoorSnaps[nIdx] do
    begin
      //stop play
      if FRealHandle>=0 then
      begin
          NET_DVR_StopRealPlay(FRealHandle);
          FRealHandle := -1;
      end;
      //logout
      if  FUserID>=0 then
      begin
          NET_DVR_Logout_V30(FUserID);
          FUserID := -1;
      end;
      NET_DVR_Cleanup();

      fFormMain.SnapView1.Caption := 'Stop!';
      fFormMain.SnapView2.Caption := 'Stop!';
      fFormMain.SnapView3.Caption := 'Stop!';
      fFormMain.SnapView4.Caption := 'Stop!';
    end;
  except
  end;
end;

//Date: 2017-12-1
//Parm: �б�
//Desc: ��ȡ����ץ�ı�ʶ�б�
procedure THKDoorSnapManager.GetDoorSnapList(const nList: TStrings);
var nIdx: Integer;
begin
  nList.Clear;
  for nIdx:=Low(FDoorSnaps) to High(FDoorSnaps) do
   with FDoorSnaps[nIdx] do
    nList.Values[FID] := FName;
  //xxxxx
end;

procedure THKDoorSnapManager.LoadConfig(const nFile: string);
var nIdx,nInt: Integer;
    nXML: TNativeXml;
    nNode,nTmp: TXmlNode;
begin
  nXML := TNativeXml.Create;
  try
    SetLength(FDoorSnaps, 0);
    nXML.LoadFromFile(nFile);
    nTmp := nXML.Root.FindNode('config');

    if Assigned(nTmp) then
    begin
      nIdx := nTmp.NodeByName('enable').ValueAsInteger;
      FEnabled := nIdx = 1;
    end;

    nTmp := nXML.Root.FindNode('Snaps');
    if Assigned(nTmp) then
    begin
      for nIdx:=0 to nTmp.NodeCount - 1 do
      begin
        nNode := nTmp.Nodes[nIdx];
        if nNode.NodeByName('enable').ValueAsInteger <> 1 then Continue;

        nInt := Length(FDoorSnaps);
        SetLength(FDoorSnaps, nInt + 1);

        with FDoorSnaps[nInt] do
        begin
          FID := nNode.AttributeByName['id'];
          FName := nNode.AttributeByName['name'];
          FPanelID := nNode.NodeByName('Idx').ValueAsInteger;
          FHost := nNode.NodeByName('ip').ValueAsString;
          FPort := nNode.NodeByName('port').ValueAsInteger;

          FUser := nNode.NodeByName('User').ValueAsString;
          FPassword := nNode.NodeByName('Password').ValueAsString;
          FChannel := nNode.NodeByName('Channel').ValueAsString;
          FLinkMode := nNode.NodeByName('LinkMode').ValueAsInteger;
          FUserID := -1;
          FRealHandle := -1;
          FFortifyHandle := -1;
        end;
      end;
    end;
  finally
    nXML.Free;
  end;
end;

//------------------------------------------------------------------------------
constructor THKDoorSnapSender.Create(AOwner: THKDoorSnapManager);
begin
  inherited Create(False);
  FreeOnTerminate := False;

  FOwner := AOwner;
  FWaiter := TWaitObject.Create;
  FWaiter.Interval := 1000;
end;

destructor THKDoorSnapSender.Destroy;
begin
  FWaiter.Free;
  inherited;
end;

procedure THKDoorSnapSender.WakupMe;
begin
  FWaiter.Wakeup;
end;

procedure THKDoorSnapSender.StopMe;
begin
  Terminate;
  FWaiter.Wakeup;

  WaitFor;
  Free;
end;

procedure THKDoorSnapSender.Execute;
begin
  while not Terminated do
  try
    FWaiter.EnterWait;
    if Terminated then Exit;
  except
    on nErr: Exception do
    begin
      WriteLog(nErr.Message);
    end;
  end;
end;

function THKDoorSnapManager.GetDoorID(nIP: string): string;
var nIdx : Integer;
begin
  Result := sSPost_In;
  for nIdx:=Low(FDoorSnaps) to High(FDoorSnaps) do
   with FDoorSnaps[nIdx] do
   begin
     if nIP = '' then
       Continue;
     if nIP = FHost then
     begin
       Result := FID;
       Break;
     end;
   end;
end;

initialization
  gHKDoorSnapManager := nil;
finalization
  FreeAndNil(gHKDoorSnapManager);
end.
