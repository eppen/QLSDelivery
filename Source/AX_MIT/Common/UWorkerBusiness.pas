{*******************************************************************************
  ����: dmzn@163.com 2013-12-04
  ����: ģ��ҵ�����
*******************************************************************************}
unit UWorkerBusiness;

{$I Link.Inc}
interface

uses
  Windows, Classes, Controls, DB, SysUtils, UBusinessWorker, UBusinessPacker,
  UBusinessConst, UMgrDBConn, UMgrParam, ZnMD5, ULibFun, UFormCtrl, USysLoger,
  USysDB, UMITConst, NativeXml;

type
  TBusWorkerQueryField = class(TBusinessWorkerBase)
  private
    FIn: TWorkerQueryFieldData;
    FOut: TWorkerQueryFieldData;
  public
    class function FunctionName: string; override;
    function GetFlagStr(const nFlag: Integer): string; override;
    function DoWork(var nData: string): Boolean; override;
    //ִ��ҵ��
  end;

  TMITDBWorker = class(TBusinessWorkerBase)
  protected
    FErrNum: Integer;
    //������
    FDBConn: PDBWorker;
    //����ͨ��
    FDataIn,FDataOut: PBWDataBase;
    //��γ���
    FDataOutNeedUnPack: Boolean;
    //��Ҫ���
    procedure GetInOutData(var nIn,nOut: PBWDataBase); virtual; abstract;
    //�������
    function VerifyParamIn(var nData: string): Boolean; virtual;
    //��֤���
    function DoDBWork(var nData: string): Boolean; virtual; abstract;
    function DoAfterDBWork(var nData: string; nResult: Boolean): Boolean; virtual;
    //����ҵ��
  public
    function DoWork(var nData: string): Boolean; override;
    //ִ��ҵ��
    procedure WriteLog(const nEvent: string);
    //��¼��־
  end;

  THuaYan = record
    FReriNo:string;
    FValue:Double;
    FZLVal:Double;
  end;

  TWorkerBusinessCommander = class(TMITDBWorker)
  private
    FListA,FListB,FListC,FListD,FListE: TStrings;
    //list
    FIn: TWorkerBusinessCommand;
    FOut: TWorkerBusinessCommand;
    FHuaYan: array of THuaYan;
  protected
    procedure GetInOutData(var nIn,nOut: PBWDataBase); override;
    function DoDBWork(var nData: string): Boolean; override;
    //base funciton
    function GetCardUsed(var nData: string): Boolean;
    //��ȡ��Ƭ����
    function Login(var nData: string):Boolean;
    function LogOut(var nData: string): Boolean;
    //��¼ע���������ƶ��ն�
    function GetServerNow(var nData: string): Boolean;
    //��ȡ������ʱ��
    function GetSerailID(var nData: string): Boolean;
    //��ȡ����
    function IsSystemExpired(var nData: string): Boolean;
    //ϵͳ�Ƿ��ѹ���
    function CustomerMaCredLmt(var nData: string): Boolean;
    //��֤�ͻ��Ƿ�ǿ�����ö��
    function GetCustomerValidMoney(var nData: string): Boolean;
    //��ȡ�ͻ����ý�
    function GetZhiKaValidMoney(var nData: string): Boolean;
    //��ȡֽ�����ý�
    function CustomerHasMoney(var nData: string): Boolean;
    //��֤�ͻ��Ƿ���Ǯ
    function SaveTruck(var nData: string): Boolean;
    function UpdateTruck(var nData: string): Boolean;
    //���泵����Truck��
    function GetTruckPoundData(var nData: string): Boolean;
    function SaveTruckPoundData(var nData: string): Boolean;
    //��ȡ������������
  public
    constructor Create; override;
    destructor destroy; override;
    //new free
    function GetFlagStr(const nFlag: Integer): string; override;
    class function FunctionName: string; override;
    //base function
    class function CallMe(const nCmd: Integer; const nData,nExt: string;
      const nOut: PWorkerBusinessCommand): Boolean;
    //local call
  end;

implementation
uses
  UDataModule;

class function TBusWorkerQueryField.FunctionName: string;
begin
  Result := sBus_GetQueryField;
end;

function TBusWorkerQueryField.GetFlagStr(const nFlag: Integer): string;
begin
  inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_GetQueryField;
  end;
end;

function TBusWorkerQueryField.DoWork(var nData: string): Boolean;
begin
  FOut.FData := '*';
  FPacker.UnPackIn(nData, @FIn);

  case FIn.FType of
   cQF_Bill: 
    FOut.FData := '*';
  end;

  Result := True;
  FOut.FBase.FResult := True;
  nData := FPacker.PackOut(@FOut);
end;

//------------------------------------------------------------------------------
//Date: 2012-3-13
//Parm: ���������
//Desc: ��ȡ�������ݿ��������Դ
function TMITDBWorker.DoWork(var nData: string): Boolean;
begin
  Result := False;
  FDBConn := nil;

  with gParamManager.ActiveParam^ do
  try
    FDBConn := gDBConnManager.GetConnection(FDB.FID, FErrNum);
    if not Assigned(FDBConn) then
    begin
      nData := '�������ݿ�ʧ��(DBConn Is Null).';
      Exit;
    end;

    if not FDBConn.FConn.Connected then
      FDBConn.FConn.Connected := True;
    //conn db

    FDataOutNeedUnPack := True;
    GetInOutData(FDataIn, FDataOut);
    FPacker.UnPackIn(nData, FDataIn);

    with FDataIn.FVia do
    begin
      FUser   := gSysParam.FAppFlag;
      FIP     := gSysParam.FLocalIP;
      FMAC    := gSysParam.FLocalMAC;
      FTime   := FWorkTime;
      FKpLong := FWorkTimeInit;
    end;

    {$IFDEF DEBUG}
    WriteLog('Fun: '+FunctionName+' InData:'+ FPacker.PackIn(FDataIn, False));
    {$ENDIF}
    if not VerifyParamIn(nData) then Exit;
    //invalid input parameter

    FPacker.InitData(FDataOut, False, True, False);
    //init exclude base
    FDataOut^ := FDataIn^;

    Result := DoDBWork(nData);
    //execute worker

    if Result then
    begin
      if FDataOutNeedUnPack then
        FPacker.UnPackOut(nData, FDataOut);
      //xxxxx

      Result := DoAfterDBWork(nData, True);
      if not Result then Exit;

      with FDataOut.FVia do
        FKpLong := GetTickCount - FWorkTimeInit;
      nData := FPacker.PackOut(FDataOut);

      {$IFDEF DEBUG}
      WriteLog('Fun: '+FunctionName+' OutData:'+ FPacker.PackOut(FDataOut, False));
      {$ENDIF}
    end else DoAfterDBWork(nData, False);
  finally
    gDBConnManager.ReleaseConnection(FDBConn);
  end;
end;

//Date: 2012-3-22
//Parm: �������;���
//Desc: ����ҵ��ִ����Ϻ����β����
function TMITDBWorker.DoAfterDBWork(var nData: string; nResult: Boolean): Boolean;
begin
  Result := True;
end;

//Date: 2012-3-18
//Parm: �������
//Desc: ��֤��������Ƿ���Ч
function TMITDBWorker.VerifyParamIn(var nData: string): Boolean;
begin
  Result := True;
end;

//Desc: ��¼nEvent��־
procedure TMITDBWorker.WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TMITDBWorker, FunctionName, nEvent);
end;

//------------------------------------------------------------------------------
class function TWorkerBusinessCommander.FunctionName: string;
begin
  Result := sBus_BusinessCommand;
end;

constructor TWorkerBusinessCommander.Create;
begin
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  FListC := TStringList.Create;
  FListD := TStringList.Create;
  FListE := TStringList.Create;
  inherited;
end;

destructor TWorkerBusinessCommander.destroy;
begin
  FreeAndNil(FListA);
  FreeAndNil(FListB);
  FreeAndNil(FListC);
  FreeAndNil(FListD);
  FreeAndNil(FListE);
  inherited;
end;

function TWorkerBusinessCommander.GetFlagStr(const nFlag: Integer): string;
begin
  Result := inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_BusinessCommand;
  end;
end;

procedure TWorkerBusinessCommander.GetInOutData(var nIn,nOut: PBWDataBase);
begin
  nIn := @FIn;
  nOut := @FOut;
  FDataOutNeedUnPack := False;
end;

//Date: 2014-09-15
//Parm: ����;����;����;���
//Desc: ���ص���ҵ�����
class function TWorkerBusinessCommander.CallMe(const nCmd: Integer;
  const nData, nExt: string; const nOut: PWorkerBusinessCommand): Boolean;
var nStr: string;
    nIn: TWorkerBusinessCommand;
    nPacker: TBusinessPackerBase;
    nWorker: TBusinessWorkerBase;
begin
  nPacker := nil;
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    nPacker := gBusinessPackerManager.LockPacker(sBus_BusinessCommand);
    nPacker.InitData(@nIn, True, False);
    //init
    
    nStr := nPacker.PackIn(@nIn);
    nWorker := gBusinessWorkerManager.LockWorker(FunctionName);
    //get worker

    Result := nWorker.WorkActive(nStr);
    if Result then
         nPacker.UnPackOut(nStr, nOut)
    else nOut.FData := nStr;
  finally
    gBusinessPackerManager.RelasePacker(nPacker);
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2012-3-22
//Parm: ��������
//Desc: ִ��nDataҵ��ָ��
function TWorkerBusinessCommander.DoDBWork(var nData: string): Boolean;
begin
  with FOut.FBase do
  begin
    FResult := True;
    FErrCode := 'S.00';
    FErrDesc := 'ҵ��ִ�гɹ�.';
  end;

  case FIn.FCommand of
   cBC_GetCardUsed         : Result := GetCardUsed(nData);
   cBC_ServerNow           : Result := GetServerNow(nData);
   cBC_GetSerialNO         : Result := GetSerailID(nData);
   cBC_IsSystemExpired     : Result := IsSystemExpired(nData);
   cBC_CustomerMaCredLmt   : Result := CustomerMaCredLmt(nData);
   cBC_GetCustomerMoney    : Result := GetCustomerValidMoney(nData);
   cBC_GetZhiKaMoney       : Result := GetZhiKaValidMoney(nData);
   cBC_CustomerHasMoney    : Result := CustomerHasMoney(nData);
   cBC_SaveTruckInfo       : Result := SaveTruck(nData);
   cBC_UpdateTruckInfo     : Result := UpdateTruck(nData);
   cBC_GetTruckPoundData   : Result := GetTruckPoundData(nData);
   cBC_SaveTruckPoundData  : Result := SaveTruckPoundData(nData);
   cBC_UserLogin           : Result := Login(nData);
   cBC_UserLogOut          : Result := LogOut(nData);
   else
    begin
      Result := False;
      nData := '��Ч��ҵ�����(Invalid Command).';
    end;
  end;
end;

//Date: 2014-09-05
//Desc: ��ȡ��Ƭ���ͣ�����S;�ɹ�P;����O
function TWorkerBusinessCommander.GetCardUsed(var nData: string): Boolean;
var nStr: string;
begin
  Result := False;

  nStr := 'Select C_Used From %s Where C_Card=''%s'' ' +
          'or C_Card3=''%s'' or C_Card2=''%s''';
  nStr := Format(nStr, [sTable_Card, FIn.FData, FIn.FData, FIn.FData]);
  //card status

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount<1 then Exit;

    FOut.FData := Fields[0].AsString;
    Result := True;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2015/9/9
//Parm: �û��������룻�����û�����
//Desc: �û���¼
function TWorkerBusinessCommander.Login(var nData: string): Boolean;
var nStr: string;
begin
  Result := False;

  FListA.Clear;
  FListA.Text := PackerDecodeStr(FIn.FData);
  if FListA.Values['User']='' then Exit;
  //δ�����û���

  nStr := 'Select U_Password From %s Where U_Name=''%s''';
  nStr := Format(nStr, [sTable_User, FListA.Values['User']]);
  //card status

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount<1 then Exit;

    nStr := Fields[0].AsString;
    if nStr<>FListA.Values['Password'] then Exit;
    {
    if CallMe(cBC_ServerNow, '', '', @nOut) then
         nStr := PackerEncodeStr(nOut.FData)
    else nStr := IntToStr(Random(999999));

    nInfo := FListA.Values['User'] + nStr;
    //xxxxx

    nStr := 'Insert into $EI(I_Group, I_ItemID, I_Item, I_Info) ' +
            'Values(''$Group'', ''$ItemID'', ''$Item'', ''$Info'')';
    nStr := MacroValue(nStr, [MI('$EI', sTable_ExtInfo),
            MI('$Group', sFlag_UserLogItem), MI('$ItemID', FListA.Values['User']),
            MI('$Item', PackerEncodeStr(FListA.Values['Password'])),
            MI('$Info', nInfo)]);
    gDBConnManager.WorkerExec(FDBConn, nStr);  }

    Result := True;
  end;
end;
//------------------------------------------------------------------------------
//Date: 2015/9/9
//Parm: �û�������֤����
//Desc: �û�ע��
function TWorkerBusinessCommander.LogOut(var nData: string): Boolean;
//var nStr: string;
begin
  {nStr := 'delete From %s Where I_ItemID=''%s''';
  nStr := Format(nStr, [sTable_ExtInfo, PackerDecodeStr(FIn.FData)]);
  //card status

  
  if gDBConnManager.WorkerExec(FDBConn, nStr)<1 then
       Result := False
  else Result := True;     }

  Result := True;
end;

//Date: 2014-09-05
//Desc: ��ȡ��������ǰʱ��
function TWorkerBusinessCommander.GetServerNow(var nData: string): Boolean;
var nStr: string;
begin
  nStr := 'Select ' + sField_SQLServer_Now;
  //sql

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    FOut.FData := DateTime2Str(Fields[0].AsDateTime);
    Result := True;
  end;
end;

//Date: 2012-3-25
//Desc: �������������б��
function TWorkerBusinessCommander.GetSerailID(var nData: string): Boolean;
var nInt: Integer;
    nStr,nP,nB: string;
begin
  FDBConn.FConn.BeginTrans;
  try
    Result := False;
    FListA.Text := FIn.FData;
    //param list

    nStr := 'Update %s Set B_Base=B_Base+1 ' +
            'Where B_Group=''%s'' And B_Object=''%s''';
    nStr := Format(nStr, [sTable_SerialBase, FListA.Values['Group'],
            FListA.Values['Object']]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nStr := 'Select B_Prefix,B_IDLen,B_Base,B_Date,%s as B_Now From %s ' +
            'Where B_Group=''%s'' And B_Object=''%s''';
    nStr := Format(nStr, [sField_SQLServer_Now, sTable_SerialBase,
            FListA.Values['Group'], FListA.Values['Object']]);
    //xxxxx

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      if RecordCount < 1 then
      begin
        nData := 'û��[ %s.%s ]�ı�������.';
        nData := Format(nData, [FListA.Values['Group'], FListA.Values['Object']]);

        FDBConn.FConn.RollbackTrans;
        Exit;
      end;

      nP := FieldByName('B_Prefix').AsString;
      nB := FieldByName('B_Base').AsString;
      nInt := FieldByName('B_IDLen').AsInteger;

      if FIn.FExtParam = sFlag_Yes then //�����ڱ���
      begin
        nStr := Date2Str(FieldByName('B_Date').AsDateTime, False);
        //old date

        if (nStr <> Date2Str(FieldByName('B_Now').AsDateTime, False)) and
           (FieldByName('B_Now').AsDateTime > FieldByName('B_Date').AsDateTime) then
        begin
          nStr := 'Update %s Set B_Base=1,B_Date=%s ' +
                  'Where B_Group=''%s'' And B_Object=''%s''';
          nStr := Format(nStr, [sTable_SerialBase, sField_SQLServer_Now,
                  FListA.Values['Group'], FListA.Values['Object']]);
          gDBConnManager.WorkerExec(FDBConn, nStr);

          nB := '1';
          nStr := Date2Str(FieldByName('B_Now').AsDateTime, False);
          //now date
        end;

        System.Delete(nStr, 1, 2);
        //yymmdd
        nInt := nInt - Length(nP) - Length(nStr) - Length(nB);
        FOut.FData := nP + nStr + StringOfChar('0', nInt) + nB;
      end else
      begin
        nInt := nInt - Length(nP) - Length(nB);
        nStr := StringOfChar('0', nInt);
        FOut.FData := nP + nStr + nB;
      end;
    end;

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2014-09-05
//Desc: ��֤ϵͳ�Ƿ��ѹ���
function TWorkerBusinessCommander.IsSystemExpired(var nData: string): Boolean;
var nStr: string;
    nDate: TDate;
    nInt: Integer;
begin
  nDate := Date();
  //server now

  nStr := 'Select D_Value,D_ParamB From %s ' +
          'Where D_Name=''%s'' and D_Memo=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_ValidDate]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    nStr := 'dmzn_stock_' + Fields[0].AsString;
    nStr := MD5Print(MD5String(nStr));

    if nStr = Fields[1].AsString then
      nDate := Str2Date(Fields[0].AsString);
    //xxxxx
  end;

  nInt := Trunc(nDate - Date());
  Result := nInt > 0;

  if nInt <= 0 then
  begin
    nStr := 'ϵͳ�ѹ��� %d ��,����ϵ����Ա!!';
    nData := Format(nStr, [-nInt]);
    Exit;
  end;

  FOut.FData := IntToStr(nInt);
  //last days

  if nInt <= 7 then
  begin
    nStr := Format('ϵͳ�� %d ������', [nInt]);
    FOut.FBase.FErrDesc := nStr;
    FOut.FBase.FErrCode := sFlag_ForceHint;
  end;
end;

{$IFDEF COMMON}
//2016-08-27
//��֤�ͻ��Ƿ�ǿ�����ö��
function TWorkerBusinessCommander.CustomerMaCredLmt(var nData: string): Boolean;
var
  nStr:string;
begin
  nStr := 'Select C_Name,C_MaCredLmt From %s Where C_ID=''%s''';
  nStr := Format(nStr, [sTable_Customer, FIn.FData]);
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount > 0 then
    begin
      if Fields[1].AsString='0' then //���������ö��
      begin
        FOut.FData := sFlag_No;
      end else
      begin
        FOut.FData := sFlag_Yes;
      end;
    end else
    begin
      FOut.FExtParam := '��ɾ��';
    end;
  end;
  Result:=True;
end;

//Date: 2014-09-05
//Desc: ��ȡָ���ͻ��Ŀ��ý��
function TWorkerBusinessCommander.GetCustomerValidMoney(var nData: string): Boolean;
var nStr: string;
    nVal,nCredit: Double;
    nContractId: string;
    nAXMoney: Double;
    nContQuota: string;//1 ר��ר��
    nCusID:string;
    nFailureDate: TDateTime;
begin
  nStr := 'Select zk.Z_Customer,sc.C_ID,sc.C_ContQuota From $ZK zk,$SC sc ' +
          'Where zk.Z_ID=''$CID'' and zk.Z_CID=sc.C_ID';
  nStr := MacroValue(nStr, [MI('$ZK', sTable_ZhiKa), MI('$CID', FIn.FData),
          MI('$SC', sTable_SaleContract)]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    nCusID:=FieldByName('Z_Customer').AsString;
    nContQuota:= FieldByName('C_ContQuota').AsString;
    if nContQuota ='1' then
    begin
      nContractId:=FieldByName('C_ID').AsString;
      nStr := 'Select cc.* From $ZK,$CC cc ' +
              'Where Z_ID=''$CID'' and Z_Customer=C_CusID and C_ContractId=''$TID'' ';
      nStr := MacroValue(nStr, [MI('$ZK', sTable_ZhiKa), MI('$CID', FIn.FData),
              MI('$CC', sTable_CusContCredit), MI('$TID', nContractId)]);
    end else
    begin
      nStr := 'Select cc.* From $ZK,$CC cc ' +
              'Where Z_ID=''$CID'' and Z_Customer=C_CusID';
      nStr := MacroValue(nStr, [MI('$ZK', sTable_ZhiKa), MI('$CID', FIn.FData),
              MI('$CC', sTable_CusCredit)]);
    end;
  end;
  
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount <1 then
    begin
      nAXMoney:=0;
    end else
    begin
      nFailureDate := FieldByName('C_FailureDate').AsDateTime;
      if (FieldByName('C_FailureDate').IsNull) or
        (FieldByName('C_FailureDate').AsString='') or
        (formatdatetime('yyyy-mm-dd',nFailureDate)='1900-01-01') then
      begin
        nAXMoney:= FieldByName('C_CashBalance').AsFloat+
                     FieldByName('C_BillBalance3M').AsFloat+
                     FieldByName('C_BillBalance6M').AsFloat-
                     FieldByName('C_PrestigeQuota').AsFloat;
      end else
      begin
        nFailureDate := StrToDateTime(formatdatetime('yyyy-mm-dd',nFailureDate)+' 23:59:59');
        if nFailureDate >= Now then
        begin
          nAXMoney:= FieldByName('C_CashBalance').AsFloat+
                     FieldByName('C_BillBalance3M').AsFloat+
                     FieldByName('C_BillBalance6M').AsFloat+
                     FieldByName('C_TemporBalance').AsFloat-
                     FieldByName('C_PrestigeQuota').AsFloat;
        end else
        begin
          nAXMoney:= FieldByName('C_CashBalance').AsFloat+
                     FieldByName('C_BillBalance3M').AsFloat+
                     FieldByName('C_BillBalance6M').AsFloat-
                     FieldByName('C_PrestigeQuota').AsFloat;
        end;
      end;
    end;
  end;


  nStr := 'Select * From %s Where A_CID=''%s''';
  nStr := Format(nStr, [sTable_CusAccount, nCusID]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := '���Ϊ[ %s ]�Ŀͻ��˻�������.';
      nData := Format(nData, [FIn.FData]);

      Result := False;
      Exit;
    end;
    if nContQuota ='1' then
    begin
      nVal := nAXMoney-FieldByName('A_ConFreezeMoney').AsFloat
    end else
    begin
      nVal := nAXMoney-FieldByName('A_FreezeMoney').AsFloat;
    end;
    //xxxxx

    nCredit := FieldByName('A_CreditLimit').AsFloat;
    nCredit := Float2PInt(nCredit, cPrecision, False) / cPrecision;

    if FIn.FExtParam = sFlag_Yes then
      nVal := nVal + nCredit;
    nVal := Float2PInt(nVal, cPrecision, False) / cPrecision;

    FOut.FData := FloatToStr(nVal);
    FOut.FExtParam := FloatToStr(nCredit);
    Result := True;
  end;
end;
{$ENDIF}

{$IFDEF COMMON}
//Date: 2014-09-05
//Desc: ��ȡָ��ֽ���Ŀ��ý��
function TWorkerBusinessCommander.GetZhiKaValidMoney(var nData: string): Boolean;
var nStr: string;
    nVal,nMoney: Double;
begin
  nStr := 'Select ca.*,Z_OnlyMoney,Z_FixedMoney From $ZK,$CA ca ' +
          'Where Z_ID=''$ZID'' and A_CID=Z_Customer';
  nStr := MacroValue(nStr, [MI('$ZK', sTable_ZhiKa), MI('$ZID', FIn.FData),
          MI('$CA', sTable_CusAccount)]);
  //xxxxx

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := '���Ϊ[ %s ]��ֽ��������,��ͻ��˻���Ч.';
      nData := Format(nData, [FIn.FData]);

      Result := False;
      Exit;
    end;

    FOut.FExtParam := FieldByName('Z_OnlyMoney').AsString;
    nMoney := FieldByName('Z_FixedMoney').AsFloat;

    nVal := FieldByName('A_InMoney').AsFloat -
            FieldByName('A_OutMoney').AsFloat -
            FieldByName('A_Compensation').AsFloat -
            FieldByName('A_FreezeMoney').AsFloat +
            FieldByName('A_CreditLimit').AsFloat;
    nVal := Float2PInt(nVal, cPrecision, False) / cPrecision;

    if FOut.FExtParam = sFlag_Yes then
    begin
      if nMoney > nVal then
        nMoney := nVal;
      //enough money
    end else nMoney := nVal;

    FOut.FData := FloatToStr(nMoney);
    Result := True;
  end;
end;
{$ENDIF}

//Date: 2014-09-05
//Desc: ��֤�ͻ��Ƿ���Ǯ,�Լ������Ƿ����
function TWorkerBusinessCommander.CustomerHasMoney(var nData: string): Boolean;
var nStr,nName: string;
    nM,nC: Double;
begin
  Result:=CustomerMaCredLmt(nData);
  if not Result then Exit;
  if FOut.FData = sFlag_No then
  begin
    FOut.FData := sFlag_Yes;
    Exit;
  end;
  FIn.FExtParam := sFlag_No;
  Result := GetCustomerValidMoney(nData);
  if not Result then Exit;

  nM := StrToFloat(FOut.FData);
  FOut.FData := sFlag_Yes;
  if nM > 0 then Exit;

  nC := StrToFloat(FOut.FExtParam);
  if (nC <= 0) or (nC + nM <= 0) then
  begin
    nData := Format('�ͻ�[ %s ]���ʽ�����.', [nName]);
    Result := False;
    Exit;
  end;

  nStr := 'Select MAX(C_End) From %s Where C_CusID=''%s'' and C_Money>=0';
  nStr := Format(nStr, [sTable_CusCredit, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if (Fields[0].AsDateTime > Str2Date('2000-01-01')) and
     (Fields[0].AsDateTime < Date()) then
  begin
    nData := Format('�ͻ�[ %s ]�������ѹ���.', [nName]);
    Result := False;
  end;
end;

//Date: 2014-10-02
//Parm: ���ƺ�[FIn.FData];
//Desc: ���泵����sTable_Truck��
function TWorkerBusinessCommander.SaveTruck(var nData: string): Boolean;
var nStr: string;
begin
  Result := True;
  FIn.FData := UpperCase(FIn.FData);
  
  nStr := 'Select Count(*) From %s Where T_Truck=''%s''';
  nStr := Format(nStr, [sTable_Truck, FIn.FData]);
  //xxxxx

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if Fields[0].AsInteger < 1 then
  begin
    nStr := 'Insert Into %s(T_Truck, T_PY) Values(''%s'', ''%s'')';
    nStr := Format(nStr, [sTable_Truck, FIn.FData, GetPinYinOfStr(FIn.FData)]);
    gDBConnManager.WorkerExec(FDBConn, nStr);
  end;
end;

//Date: 2016-02-16
//Parm: ���ƺ�(Truck); ���ֶ���(Field);����ֵ(Value)
//Desc: ���³�����Ϣ��sTable_Truck��
function TWorkerBusinessCommander.UpdateTruck(var nData: string): Boolean;
var nStr: string;
    nValInt: Integer;
    nValFloat: Double;
begin
  Result := True;
  FListA.Text := FIn.FData;

  if FListA.Values['Field'] = 'T_PValue' then
  begin
    nStr := 'Select T_PValue, T_PTime From %s Where T_Truck=''%s''';
    nStr := Format(nStr, [sTable_Truck, FListA.Values['Truck']]);

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    if RecordCount > 0 then
    begin
      nValInt := Fields[1].AsInteger;
      nValFloat := Fields[0].AsFloat;
    end else Exit;

    nValFloat := nValFloat * nValInt + StrToFloatDef(FListA.Values['Value'], 0);
    nValFloat := nValFloat / (nValInt + 1);
    nValFloat := Float2Float(nValFloat, cPrecision);

    nStr := 'Update %s Set T_PValue=%.2f, T_PTime=T_PTime+1 Where T_Truck=''%s''';
    nStr := Format(nStr, [sTable_Truck, nValFloat, FListA.Values['Truck']]);
    gDBConnManager.WorkerExec(FDBConn, nStr);
  end;
end;

//Date: 2014-09-25
//Parm: ���ƺ�[FIn.FData]
//Desc: ��ȡָ�����ƺŵĳ�Ƥ����(ʹ�����ģʽ,δ����)
function TWorkerBusinessCommander.GetTruckPoundData(var nData: string): Boolean;
var nStr: string;
    nPound: TLadingBillItems;
begin
  SetLength(nPound, 1);
  FillChar(nPound[0], SizeOf(TLadingBillItem), #0);

  nStr := 'Select * From %s Where P_Truck=''%s'' And ' +
          'P_MValue Is Null And P_PModel=''%s''';
  nStr := Format(nStr, [sTable_PoundLog, FIn.FData, sFlag_PoundPD]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr),nPound[0] do
  begin
    if RecordCount > 0 then
    begin
      FCusID      := FieldByName('P_CusID').AsString;
      FCusName    := FieldByName('P_CusName').AsString;
      FTruck      := FieldByName('P_Truck').AsString;

      FType       := FieldByName('P_MType').AsString;
      FStockNo    := FieldByName('P_MID').AsString;
      FStockName  := FieldByName('P_MName').AsString;

      with FPData do
      begin
        FStation  := FieldByName('P_PStation').AsString;
        FValue    := FieldByName('P_PValue').AsFloat;
        FDate     := FieldByName('P_PDate').AsDateTime;
        FOperator := FieldByName('P_PMan').AsString;
      end;  

      FFactory    := FieldByName('P_FactID').AsString;
      FPModel     := FieldByName('P_PModel').AsString;
      FPType      := FieldByName('P_Type').AsString;
      FPoundID    := FieldByName('P_ID').AsString;

      FStatus     := sFlag_TruckBFP;
      FNextStatus := sFlag_TruckBFM;
      FSelected   := True;
    end else
    begin
      FTruck      := FIn.FData;
      FPModel     := sFlag_PoundPD;

      FStatus     := '';
      FNextStatus := sFlag_TruckBFP;
      FSelected   := True;
    end;
  end;

  FOut.FData := CombineBillItmes(nPound);
  Result := True;
end;

//Date: 2014-09-25
//Parm: ��������[FIn.FData]
//Desc: ��ȡָ�����ƺŵĳ�Ƥ����(ʹ�����ģʽ,δ����)
function TWorkerBusinessCommander.SaveTruckPoundData(var nData: string): Boolean;
var nStr,nSQL: string;
    nPound: TLadingBillItems;
    nOut: TWorkerBusinessCommand;
begin
  AnalyseBillItems(FIn.FData, nPound);
  //��������

  with nPound[0] do
  begin
    if FPoundID = '' then
    begin
      TWorkerBusinessCommander.CallMe(cBC_SaveTruckInfo, FTruck, '', @nOut);
      //���泵�ƺ�

      FListC.Clear;
      FListC.Values['Group'] := sFlag_BusGroup;
      FListC.Values['Object'] := sFlag_PoundID;

      if not CallMe(cBC_GetSerialNO,
            FListC.Text, sFlag_Yes, @nOut) then
        raise Exception.Create(nOut.FData);
      //xxxxx

      FPoundID := nOut.FData;
      //new id

      if FPModel = sFlag_PoundLS then
           nStr := sFlag_Other
      else nStr := sFlag_Provide;

      nSQL := MakeSQLByStr([
              SF('P_ID', FPoundID),
              SF('P_Type', nStr),
              SF('P_Truck', FTruck),
              SF('P_CusID', FCusID),
              SF('P_CusName', FCusName),
              SF('P_MID', FStockNo),
              SF('P_MName', FStockName),
              SF('P_MType', sFlag_San),
              SF('P_PValue', FPData.FValue, sfVal),
              SF('P_PDate', sField_SQLServer_Now, sfVal),
              SF('P_PMan', FIn.FBase.FFrom.FUser),
              SF('P_FactID', FFactory),
              SF('P_PStation', FPData.FStation),
              SF('P_Direction', '����'),
              SF('P_PModel', FPModel),
              SF('P_Status', sFlag_TruckBFP),
              SF('P_Valid', sFlag_Yes),
              SF('P_PrintNum', 1, sfVal)
              ], sTable_PoundLog, '', True);
      gDBConnManager.WorkerExec(FDBConn, nSQL);
    end else
    begin
      nStr := SF('P_ID', FPoundID);
      //where

      if FNextStatus = sFlag_TruckBFP then
      begin
        nSQL := MakeSQLByStr([
                SF('P_PValue', FPData.FValue, sfVal),
                SF('P_PDate', sField_SQLServer_Now, sfVal),
                SF('P_PMan', FIn.FBase.FFrom.FUser),
                SF('P_PStation', FPData.FStation),
                SF('P_MValue', FMData.FValue, sfVal),
                SF('P_MDate', DateTime2Str(FMData.FDate)),
                SF('P_MMan', FMData.FOperator),
                SF('P_MStation', FMData.FStation)
                ], sTable_PoundLog, nStr, False);
        //����ʱ,����Ƥ�ش�,����Ƥë������
      end else
      begin
        nSQL := MakeSQLByStr([
                SF('P_MValue', FMData.FValue, sfVal),
                SF('P_MDate', sField_SQLServer_Now, sfVal),
                SF('P_MMan', FIn.FBase.FFrom.FUser),
                SF('P_MStation', FMData.FStation)
                ], sTable_PoundLog, nStr, False);
        //xxxxx
      end;

      gDBConnManager.WorkerExec(FDBConn, nSQL);
    end;

    FOut.FData := FPoundID;
    Result := True;
  end;
end;

{$IFDEF XAZL}
//Date: 2014-10-14
//Desc: ͬ���°�����ԭ�������ݵ�DLϵͳ
function TWorkerBusinessCommander.SyncRemoteMaterails(var nData: string): Boolean;
var nStr: string;
    nIdx: Integer;
    nDBWorker: PDBWorker;
begin
  FListA.Clear;
  Result := True;

  nDBWorker := nil;
  try
    nStr := 'Select FItemID,FName,FNumber From t_ICItem ';// +
            //'Where (FFullName like ''%%ԭ����_��Ҫ����%%'') or ' +
            //'(FFullName like ''%%ԭ����_ȼ��%%'')';
    //xxxxx

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_K3) do
    if RecordCount > 0 then
    begin
      First;

      while not Eof do
      begin
        nStr := MakeSQLByStr([SF('M_ID', Fields[0].AsString),
                SF('M_Name', Fields[1].AsString),
                SF('M_PY', GetPinYinOfStr(Fields[1].AsString)),
                SF('M_Memo', GetPinYinOfStr(Fields[2].AsString))
                ], sTable_Materails, '', True);
        //xxxxx

        FListA.Add(nStr);
        Next;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;

  if FListA.Count > 0 then
  try
    FDBConn.FConn.BeginTrans;
    nStr := 'Delete From ' + sTable_Materails;
    gDBConnManager.WorkerExec(FDBConn, nStr);

    for nIdx:=0 to FListA.Count - 1 do
      gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);
    FDBConn.FConn.CommitTrans;
  except
    if FDBConn.FConn.InTransaction then
      FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;
{$ENDIF}

initialization
  gBusinessWorkerManager.RegisteWorker(TBusWorkerQueryField, sPlug_ModuleBus);
  gBusinessWorkerManager.RegisteWorker(TWorkerBusinessCommander, sPlug_ModuleBus);
end.
