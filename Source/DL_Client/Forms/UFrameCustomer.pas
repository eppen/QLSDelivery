{*******************************************************************************
  ����: dmzn@163.com 2009-6-11
  ����: �ͻ�����
*******************************************************************************}
unit UFrameCustomer;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFrameNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, cxContainer, Menus, dxLayoutControl,
  cxTextEdit, cxMaskEdit, cxButtonEdit, ADODB, cxLabel, UBitmapPanel,
  cxSplitter, cxGridLevel, cxClasses, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  ComCtrls, ToolWin;

type
  TfFrameCustomer = class(TfFrameNormal)
    EditID: TcxButtonEdit;
    dxLayout1Item1: TdxLayoutItem;
    EditName: TcxButtonEdit;
    dxLayout1Item2: TdxLayoutItem;
    cxTextEdit1: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    cxTextEdit2: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    cxTextEdit3: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    cxTextEdit4: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    PMenu1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    m_bindWechartAccount: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    N10: TMenuItem;
    N11: TMenuItem;
    procedure EditIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnAddClick(Sender: TObject);
    procedure BtnEditClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
    procedure BtnExitClick(Sender: TObject);
    procedure cxView1DblClick(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure PMenu1Popup(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure m_bindWechartAccountClick(Sender: TObject);
    procedure N5Click(Sender: TObject);
    procedure N7Click(Sender: TObject);
    procedure N8Click(Sender: TObject);
    procedure N9Click(Sender: TObject);
    procedure N11Click(Sender: TObject);
  private
    { Private declarations }
  protected
    function InitFormDataSQL(const nWhere: string): string; override;
    {*��ѯSQL*}

    function AddMallUser(const nBindcustomerid,nCus_num,nCus_name:string):Boolean;
    function DelMallUser(const nNamepinyin,nCus_id:string):boolean;    
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, UDataModule, UFormBase, UFormWait, USysBusiness,
  USysConst, USysDB, uFormGetWechartAccount, UBusinessPacker, USysLoger,
  UFormInputbox;

class function TfFrameCustomer.FrameID: integer;
begin
  Result := cFI_FrameCustomer;
end;

//Desc: ���ݲ�ѯSQL
function TfFrameCustomer.InitFormDataSQL(const nWhere: string): string;
begin
  Result := 'Select cus.*,sd.S_CusID,bind.* From $Cus cus' +
            ' Left Join $SD sd On sd.S_CusID=cus.C_ID ' +
            ' Left Join $Bind bind On bind.w_CID=cus.C_ID';
  //xxxxx

  if nWhere = '' then
       Result := Result + ' Where C_XuNi<>''$Yes'''
  else Result := Result + ' Where (' + nWhere + ')';

  Result := MacroValue(Result, [MI('$Cus', sTable_Customer),
            MI('$SD', sTable_CusShadow),
            MI('$Bind', sTable_WeixinBind), MI('$Yes', sFlag_Yes)]);
  //xxxxx
end;

//Desc: �ر�
procedure TfFrameCustomer.BtnExitClick(Sender: TObject);
var nParam: TFormCommandParam;
begin
  if not IsBusy then
  begin
    nParam.FCommand := cCmd_FormClose;
    CreateBaseFormItem(cFI_FormCustomer, '', @nParam); Close;
  end;
end;

//------------------------------------------------------------------------------
//Desc: ���
procedure TfFrameCustomer.BtnAddClick(Sender: TObject);
var nParam: TFormCommandParam;
begin
  nParam.FCommand := cCmd_AddData;
  CreateBaseFormItem(cFI_FormCustomer, PopedomItem, @nParam);

  if (nParam.FCommand = cCmd_ModalResult) and (nParam.FParamA = mrOK) then
  begin
    InitFormData('');
  end;
end;

//Desc: �޸�
procedure TfFrameCustomer.BtnEditClick(Sender: TObject);
var nParam: TFormCommandParam;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('��ѡ��Ҫ�༭�ļ�¼', sHint); Exit;
  end;

  nParam.FCommand := cCmd_EditData;
  nParam.FParamA := SQLQuery.FieldByName('C_ID').AsString;
  CreateBaseFormItem(cFI_FormCustomer, PopedomItem, @nParam);

  if (nParam.FCommand = cCmd_ModalResult) and (nParam.FParamA = mrOK) then
  begin
    InitFormData(FWhere);
  end;
end;

//Desc: ɾ��
procedure TfFrameCustomer.BtnDelClick(Sender: TObject);
var nStr,nSQL: string;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('��ѡ��Ҫɾ���ļ�¼', sHint); Exit;
  end;

  nStr := SQLQuery.FieldByName('C_ID').AsString;
  nSQL := 'Select Count(*) From %s Where Z_Customer=''%s''';
  nSQL := Format(nSQL, [sTable_ZhiKa, nStr]);

  with FDM.QueryTemp(nSQL) do
  if Fields[0].AsInteger > 0 then
  begin
    ShowMsg('�ÿͻ�����ɾ��', '�Ѱ�ֽ��'); Exit;
  end;

  nStr := SQLQuery.FieldByName('C_Name').AsString;
  if not QueryDlg('ȷ��Ҫɾ������Ϊ[ ' + nStr + ' ]�Ŀͻ���', sAsk) then Exit;

  FDM.ADOConn.BeginTrans;
  try
    nStr := SQLQuery.FieldByName('C_ID').AsString;
    nSQL := 'Delete From %s Where C_ID=''%s''';
    nSQL := Format(nSQL, [sTable_Customer, nStr]);
    FDM.ExecuteSQL(nSQL);

    nSQL := 'Delete From %s Where I_Group=''%s'' and I_ItemID=''%s''';
    nSQL := Format(nSQL, [sTable_ExtInfo, sFlag_CustomerItem, nStr]);
    FDM.ExecuteSQL(nSQL);

    nSQL := 'Delete From %s Where A_CID=''%s''';
    nSQL := Format(nSQL, [sTable_CusAccount, nStr]);
    FDM.ExecuteSQL(nSQL);

    nSQL := 'Delete From %s Where C_CusID=''%s''';
    nSQL := Format(nSQL, [sTable_CusCredit, nStr]);
    FDM.ExecuteSQL(nSQL);

    FDM.ADOConn.CommitTrans;
    InitFormData(FWhere);
    ShowMsg('�ѳɹ�ɾ����¼', sHint);
  except
    FDM.ADOConn.RollbackTrans;
    ShowMsg('ɾ����¼ʧ��', 'δ֪����');
  end;
end;

//Desc: �鿴����
procedure TfFrameCustomer.cxView1DblClick(Sender: TObject);
var nParam: TFormCommandParam;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nParam.FCommand := cCmd_ViewData;
    nParam.FParamA := SQLQuery.FieldByName('C_ID').AsString;
    CreateBaseFormItem(cFI_FormCustomer, PopedomItem, @nParam);
  end;
end;

//Desc: ִ�в�ѯ
procedure TfFrameCustomer.EditIDPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditID then
  begin
    EditID.Text := Trim(EditID.Text);
    if EditID.Text = '' then Exit;

    FWhere := 'C_ID like ''%' + EditID.Text + '%''';
    InitFormData(FWhere);
  end else

  if Sender = EditName then
  begin
    EditName.Text := Trim(EditName.Text);
    if EditName.Text = '' then Exit;

    FWhere := 'C_Name like ''%%%s%%'' Or C_PY like ''%%%s%%''';
    FWhere := Format(FWhere, [EditName.Text, EditName.Text]);
    InitFormData(FWhere);
  end;
end;

//------------------------------------------------------------------------------

procedure TfFrameCustomer.PMenu1Popup(Sender: TObject);
begin
  {$IFDEF SyncRemote}
  N3.Visible := True;
  N4.Visible := True;
  {$ELSE}
  N3.Visible := False;
  N4.Visible := False;
  {$ENDIF}

  N7.Enabled := BtnEdit.Enabled;
  N8.Enabled := BtnEdit.Enabled;
  //Ӱ�ӿͻ�����

  N11.Enabled := BtnEdit.Enabled;
  //��AX��ʱ���
end;


//Desc: ��ݲ˵�
procedure TfFrameCustomer.N2Click(Sender: TObject);
begin
  case TComponent(Sender).Tag of
    10: FWhere := Format('IsNull(C_XuNi, '''')=''%s''', [sFlag_Yes]);
    20: FWhere := '1=1';
  end;

  InitFormData(FWhere);
end;

procedure TfFrameCustomer.N4Click(Sender: TObject);
begin
  ShowWaitForm(ParentForm, '����ͬ��,���Ժ�');
  try
    if SyncRemoteCustomer then InitFormData(FWhere);
  finally
    CloseWaitForm;
  end; 
end;

procedure TfFrameCustomer.m_bindWechartAccountClick(Sender: TObject);
var
  nParam: TFormCommandParam;
  nCus_ID,nCusName:string;
  nBindcustomerid:string;
  nWechartAccount:string;
  nWechartPhone:string;
  nStr:string;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('��ѡ��Ҫ��ͨ�ļ�¼', sHint);
    Exit;
  end;

  nCus_ID := SQLQuery.FieldByName('C_ID').AsString;
  nCusName := SQLQuery.FieldByName('C_Name').AsString;
  nWechartAccount := SQLQuery.FieldByName('wcb_Namepinyin').AsString;
  if nWechartAccount<>'' then
  begin
    ShowMsg('�̳��˻�['+nWechartAccount+']�Ѵ���', sHint);
    Exit;
  end;
  
  nParam.FCommand := cCmd_AddData;
  CreateBaseFormItem(cFI_FormGetWechartAccount, PopedomItem, @nParam);

  if (nParam.FCommand = cCmd_ModalResult) and (nParam.FParamA = mrOK) then
  begin
    nBindcustomerid := PackerDecodeStr(nParam.FParamB);
    nWechartAccount := PackerDecodeStr(nParam.FParamC);
    nWechartPhone := PackerDecodeStr(nParam.FParamD);
    if not AddMallUser(nBindcustomerid,nCus_ID,nCusName) then Exit;
    
    nStr := 'Insert into %s (w_CID, w_CusName, wcb_Phone, wcb_Bindcustomerid, wcb_Namepinyin) '+
            'values (''%s'',''%s'',''%s'',''%s'',''%s'')';
    nStr := Format(nStr,[sTable_WeixinBind,nCus_ID,nCusName,nWechartPhone,nBindcustomerid,nWechartAccount]);
    //gSysLoger.AddLog(nStr);

    FDM.ADOConn.BeginTrans;
    try
      FDM.ExecuteSQL(nStr);
      FDM.ADOConn.CommitTrans;
      ShowMsg('�ͻ� [ '+nCusName+' ] �����̳��û��ɹ���',sHint);
      InitFormData(FWhere);
    except
      FDM.ADOConn.RollbackTrans;
      ShowMsg('�����̳��û�ʧ��', 'δ֪����');
    end;
  end;
end;

function TfFrameCustomer.AddMallUser(const nBindcustomerid,nCus_num,nCus_name:string): Boolean;
var
  nXmlStr:string;
  nData:string;
begin
  Result := False;
  //���Ͱ����󿪻�����
  nXmlStr := '<?xml version="1.0" encoding="UTF-8" ?>'
            +'<DATA>'
            +'<head>'
            +'<Factory>%s</Factory>'
            +'<Customer>%s</Customer>'   //������Ҫ������ͻ���
            +'<Provider></Provider>'     //�ɹ���Ҫ����ڵ㴫��Ӧ�̱��
            +'<type>add</type>'
            +'</head>'
            +'<Items>'
            +'<Item>'
            +'<clientname>%s</clientname>'
            +'<cash>0</cash>'
            +'<clientnumber>%s</clientnumber>'
            +'</Item>'
            +'</Items>'
            +'<remark />'
            +'</DATA>';
  nXmlStr := Format(nXmlStr,[gSysParam.FFactory,nBindcustomerid,nCus_name,nCus_num]);
  nXmlStr := PackerEncodeStr(nXmlStr);
//  nXmlStr := PackerEncodeStr(UTF8Encode(nXmlStr));

  nData := edit_shopclients(nXmlStr);
  gSysLoger.AddLog(TfFrameCustomer,'AddMallUser',nData);
  if nData<>sFlag_Yes then
  begin
    ShowMsg('�ͻ�[ '+nCus_num+' ]�����̳��û�ʧ�ܣ�', sError);
    Exit;
  end;
  Result := True;
end;

function TfFrameCustomer.DelMallUser(const nNamepinyin,nCus_id:string):boolean;
var
  nXmlStr:string;
  nData:string;
begin
  Result := False;
  //����http����
  nXmlStr := '<?xml version="1.0" encoding="UTF-8"?>'
      +'<DATA>'
      +'<head>'
      +'<Factory>%s</Factory>'
      +'<Customer>%s</Customer>'
      +'<type>del</type>'
      +'</head>'
      +'<Items>'
      +'<Item>'
      +'<clientnumber>%s</clientnumber>'
      +'</Item></Items><remark/></DATA>';
  nXmlStr := Format(nXmlStr,[gSysParam.FFactory,nNamepinyin,nCus_id]);
  nXmlStr := PackerEncodeStr(nXmlStr);
  nData := edit_shopclients(nXmlStr);
  gSysLoger.AddLog(TfFrameCustomer,'DelMallUser',nData);
  if nData<>sFlag_Yes then
  begin
    ShowMsg('�ͻ�[ '+nCus_id+' ]ȡ���̳��˻����� ʧ�ܣ�', sError);
    Exit;
  end;
  Result := True;
end;

procedure TfFrameCustomer.N5Click(Sender: TObject);
var
  nWechartAccount:string;
  nStr:string;
  nCus_ID,nCusName:string;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('��ѡ��Ҫȡ���ļ�¼', sHint);
    Exit;
  end;

  nCus_ID := SQLQuery.FieldByName('C_ID').AsString;
  nCusName := SQLQuery.FieldByName('C_Name').AsString;
  nWechartAccount := SQLQuery.FieldByName('wcb_Namepinyin').AsString;
  if nWechartAccount='' then
  begin
    ShowMsg('�̳��˻����Ѵ���',sHint);
    Exit;
  end;

  if not DelMallUser(nWechartAccount, nCus_ID) then Exit;
  nStr := 'delete from %s where w_CID=''%s'' and wcb_Namepinyin=''%s'' ';
  nStr := Format(nStr,[sTable_WeixinBind,nCus_ID,nWechartAccount]);
  FDM.ADOConn.BeginTrans;
  try
    FDM.ExecuteSQL(nStr);
    FDM.ADOConn.CommitTrans;
    ShowMsg('�ͻ� [ '+nCusName+' ] ȡ���̳��˻����� �ɹ���',sHint);
    InitFormData(FWhere);
  except
    FDM.ADOConn.RollbackTrans;
    ShowMsg('ȡ���̳��˻����� ʧ��', 'δ֪����');
  end;
end;

//------------------------------------------------------------------------------
//Desc: ����Ӱ�ӿͻ�
procedure TfFrameCustomer.N7Click(Sender: TObject);
var nStr: string;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('��ѡ��Ҫ���õĿͻ�', sHint);
    Exit;
  end;

  if SQLQuery.FieldByName('S_CusID').AsString = '' then
  begin
    nStr := 'Insert Into %s(S_CusID) Values(''%s'')';
    nStr := Format(nStr, [sTable_CusShadow,
            SQLQuery.FieldByName('C_ID').AsString]);
    FDM.ExecuteSQL(nStr);
  end;

  ShowMsg('���óɹ�', sHint);
end;

//Desc: ȡ��Ӱ�ӿͻ�
procedure TfFrameCustomer.N8Click(Sender: TObject);
var nStr: string;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('��ѡ��Ҫȡ���Ŀͻ�', sHint);
    Exit;
  end;

  if SQLQuery.FieldByName('S_CusID').AsString <> '' then
  begin
    nStr := 'Delete From %s Where S_CusID=''%s''';
    nStr := Format(nStr, [sTable_CusShadow,
            SQLQuery.FieldByName('C_ID').AsString]);
    //xxxxx
    
    FDM.ExecuteSQL(nStr);
    InitFormData(FWhere);
  end;

  ShowMsg('ȡ���ɹ�', sHint);
end;

procedure TfFrameCustomer.N9Click(Sender: TObject);
var nStr: string;
begin
  FWhere := 'S_CusID Is Not Null';
  FWhere := Format(FWhere, [sTable_CusShadow]);
  InitFormData(FWhere);
end;

procedure TfFrameCustomer.N11Click(Sender: TObject);
var nStr,nMoney: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nMoney := SQLQuery.FieldByName('C_AntiAXCredit').AsString;
    while True do
    begin
      if not ShowInputBox('��������ʱ���Ž��: ', '', nMoney, 12) then Exit;
      if IsNumber(nMoney, True) then Break;
    end;

    nStr := 'Update %s Set C_AntiAXCredit=%s Where C_ID=''%s''';
    nStr := Format(nStr, [sTable_Customer, nMoney,
            SQLQuery.FieldByName('C_ID').AsString]);
    FDM.ExecuteSQL(nStr);

    nStr := '�����ͻ�[ %s ]��ʱ����[ %.2f -> %s ].';
    nStr := Format(nStr, [SQLQuery.FieldByName('C_Name').AsString,
            SQLQuery.FieldByName('C_AntiAXCredit').AsFloat, nMoney]);
    FDM.WriteSysLog(sFlag_CustomerItem, SQLQuery.FieldByName('C_ID').AsString,nStr);

    InitFormData(FWhere);
    ShowMsg('���ųɹ�', sHint);
  end;
end;

initialization
  gControlManager.RegCtrl(TfFrameCustomer, TfFrameCustomer.FrameID);
end.
