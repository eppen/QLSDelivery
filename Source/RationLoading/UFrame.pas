unit UFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ToolWin, StdCtrls, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, ULEDFont, cxGraphics,
  cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit,
  cxTextEdit, cxLabel, cxMaskEdit, cxDropDownEdit, UMgrdOPCTunnels,
  ExtCtrls, IdTCPServer, IdContext, IdGlobal, UBusinessConst, ULibFun,
  Menus, cxButtons, UMgrSendCardNo, USysLoger, cxCurrencyEdit, dxSkinsCore,
  dxSkinsDefaultPainters, cxSpinEdit, DateUtils, dOPCIntf, dOPCComn,
  dOPCDA, dOPC, Activex;

type
  TFrame1 = class(TFrame)
    ToolBar1: TToolBar;
    ToolButton2: TToolButton;
    btnPause: TToolButton;
    ToolButton6: TToolButton;
    ToolButton9: TToolButton;
    ToolButton10: TToolButton;
    ToolButton1: TToolButton;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    EditValue: TLEDFontNum;
    GroupBox3: TGroupBox;
    cxLabel4: TcxLabel;
    EditBill: TcxComboBox;
    cxLabel5: TcxLabel;
    EditTruck: TcxComboBox;
    cxLabel7: TcxLabel;
    EditCusID: TcxComboBox;
    cxLabel8: TcxLabel;
    EditStockID: TcxComboBox;
    cxLabel6: TcxLabel;
    EditMaxValue: TcxTextEdit;
    cxLabel1: TcxLabel;
    editPValue: TcxTextEdit;
    cxLabel2: TcxLabel;
    editZValue: TcxTextEdit;
    editNetValue: TLEDFontNum;
    editBiLi: TLEDFontNum;
    cxLabel3: TcxLabel;
    cxLabel9: TcxLabel;
    BtnStop: TButton;
    BtnStart: TButton;
    LblWarn: TcxLabel;
    dOPCServer: TdOPCServer;
    StateTimer: TTimer;
    procedure BtnStopClick(Sender: TObject);
    procedure BtnStartClick(Sender: TObject);
    procedure StateTimerTimer(Sender: TObject);
  private
    { Private declarations }
    FCardUsed: string;            //��Ƭ����
    FUIData: TLadingBillItem;     //��������
    FOPCTunnel: PPTOPCItem;       //OPCͨ��
    FCard: string;
    FHasDone: Double;
    procedure SetUIData(const nReset: Boolean; const nOnlyData: Boolean = False);
    //���ý�������
    procedure SetTunnel(const Value: PPTOPCItem);
    procedure WriteLog(const nEvent: string);
    procedure OnDatachange(Sender: TObject; ItemList: TdOPCItemList);
    procedure SyncReadValues(const FromCache: boolean);
  public
    FrameId:Integer;              //PLCͨ��
    FIsBusy: Boolean;             //ռ�ñ�ʶ
    FSysLoger : TSysLoger;
    property OPCTunnel: PPTOPCItem read FOPCTunnel write SetTunnel;
    procedure LoadBillItems(const nCard: string);
    //��ȡ������
    procedure StopPound;
  end;

implementation

{$R *.dfm}

uses
   USysBusiness, USysDB, USysConst, UDataModule, UFormInputbox;

//Parm: �ſ��򽻻�����
//Desc: ��ȡnCard��Ӧ�Ľ�����
procedure TFrame1.LoadBillItems(const nCard: string);
var
  nStr: string;
  nBills: TLadingBillItems;
  nRet: Boolean;
  nOPCServer: TdOPCServer;
  nGroup: TdOPCGroup;
  nIdx: Integer;
begin
  LblWarn.Caption := '';
  FCard := nCard;

  FCardUsed := GetCardUsed(nCard);
  if FCardUsed=sFlag_Provide then
       nRet := GetPurchaseOrders(nCard, sFlag_TruckBFP, nBills)
  else nRet := GetLadingBills(nCard, sFlag_TruckBFP, nBills);

  if (not nRet) or (Length(nBills) < 1) then
  begin
    nStr := '��ȡ�ſ���Ϣʧ��,����ϵ����Ա';
    WriteLog(nStr);
    SetUIData(True);
    Exit;
  end;

  //��ȡ�������ֵ
  //nBills[0].FMData.FValue := StrToFloatDef(GetLimitValue(nBills[0].FTruck),0);

  FUIData := nBills[0];

  FHasDone := ReadDoneValue(FUIData.FID);

  if FHasDone >= FUIData.FValue then
  begin
    nStr := '������[ %s ]������[ %.2f ],��װ��[ %.2f ],�޷�����װ��';
    nStr := Format(nStr, [FUIData.FID, FUIData.FValue, FHasDone]);
    WriteLog(nStr);
    LineClose(FOPCTunnel.FID, sFlag_Yes);
    ShowLedText(FOPCTunnel.FID, 'װ�����Ѵﵽ������');
    SetUIData(True);
    Exit;
  end;

  EditValue.Text := Format('%.2f', [FHasDone]);

  SetUIData(False);

  try
    CoInitialize(nil);
    nOPCServer := TdOPCServer.Create(nil);

    nOPCServer.ServerName  := FOPCTunnel.FServer;
    nOPCServer.ComputerName:= FOPCTunnel.FComputer;

    nGroup := nOPCServer.OPCGroups.Add('Group');         // make a new group
    nGroup.IsActive := False;

    nGroup.OPCItems.AddItem(FOPCTunnel.FSetValTag);
    nGroup.OPCItems.AddItem(FOPCTunnel.FStartTag);

    nOPCServer.Active := true;
    Application.ProcessMessages;

    nGroup.OPCItems[0].WriteSync(FUIData.FValue - FHasDone);
    WriteLog(FOPCTunnel.FID +'���������:'+ FloatToStr(FUIData.FValue - FHasDone));
    for nIdx := 1 to 30 do
    begin
      Sleep(100);
      Application.ProcessMessages;
    end;

    nGroup.OPCItems[1].WriteSync(FOPCTunnel.FStartOrder);
    for nIdx := 1 to 30 do
    begin
      Sleep(100);
      Application.ProcessMessages;
    end;
    nGroup.OPCItems[1].WriteSync(FOPCTunnel.FStopOrder);

    LblWarn.Caption := '������������ɹ�...';
    WriteLog(FOPCTunnel.FID +'������������ɹ�');
    StateTimer.Tag := 0;
  finally
    nOPCServer.Free;
    CoUninitialize;                        // !!!!!!!!!!!!!
  end;
end;

procedure TFrame1.SetUIData(const nReset: Boolean; const nOnlyData: Boolean = False);
var
  nItem: TLadingBillItem;
begin
  LblWarn.Caption := '';
  if nReset then
  begin
    FillChar(nItem, SizeOf(nItem), #0);
    nItem.FFactory := gSysParam.FFactNum;

    FUIData := nItem;
    if nOnlyData then Exit;

    EditValue.Text := '0.00';
    editNetValue.Text := '0.00';
    editBiLi.Text := '0';
    EditBill.Properties.Items.Clear;
  end;

  with FUIData do
  begin
    EditBill.Text := FID;
    EditTruck.Text := FTruck;
    EditStockID.Text := FStockName;
    EditCusID.Text := FCusName;

    EditMaxValue.Text := Format('%.2f', [FMData.FValue]);
    EditPValue.Text := Format('%.2f', [FPData.FValue]);
    EditZValue.Text := Format('%.2f', [FValue]);
  end;
end;

procedure TFrame1.WriteLog(const nEvent: string);
begin
  FSysLoger.AddLog(TFrame, '����װ��OPC����Ԫ', nEvent);
end;

procedure TFrame1.SetTunnel(const Value: PPTOPCItem);
begin
  FOPCTunnel := Value;
  SetUIData(true);
end;

procedure TFrame1.StopPound;
var
  nItemList: TdOPCItemList;
  nOPCServer: TdOPCServer;
  nGroup: TdOPCGroup;
  nIdx: Integer;
begin
  SetUIData(true);
  try
    CoInitialize(nil);
    nOPCServer := TdOPCServer.Create(nil);

    nOPCServer.ServerName  := FOPCTunnel.FServer;
    nOPCServer.ComputerName:= FOPCTunnel.FComputer;

    nGroup := nOPCServer.OPCGroups.Add('Group');         // make a new group
    nGroup.IsActive := False;

    nGroup.OPCItems.AddItem(FOPCTunnel.FStopTag);

    nOPCServer.Active := true;
    Application.ProcessMessages;

    nGroup.OPCItems[1].WriteSync(FOPCTunnel.FStartOrder);
    for nIdx := 1 to 30 do
    begin
      Sleep(100);
      Application.ProcessMessages;
    end;
    nGroup.OPCItems[1].WriteSync(FOPCTunnel.FStopOrder);

    LblWarn.Caption := '����ֹͣ����ɹ�...';
    WriteLog(FOPCTunnel.FID +'����ֹͣ����ɹ�');
  finally
    nOPCServer.Free;
    CoUninitialize;                        // !!!!!!!!!!!!!
  end;
  SaveDoneValue(FUIData.FID, StrToFloatDef(EditValue.Text, 0));
end;

procedure TFrame1.BtnStopClick(Sender: TObject);
begin
  StopPound;
end;

procedure TFrame1.BtnStartClick(Sender: TObject);
var nStr: string;
begin
  nStr := FCard;
  if not ShowInputBox('������ſ���:', '��ʾ', nStr) then Exit;
  LoadBillItems(nStr);
end;

procedure TFrame1.SyncReadValues(const FromCache: boolean);
var
  nItemList: TdOPCItemList;
  nOPCServer: TdOPCServer;
  nGroup: TdOPCGroup;
begin
  CoInitialize(nil);
  nOPCServer := TdOPCServer.Create(nil);
  try
    nOPCServer.ServerName  := FOPCTunnel.FServer;
    nOPCServer.ComputerName:= FOPCTunnel.FComputer;

    nGroup := nOPCServer.OPCGroups.Add('Group');         // make a new group

    nGroup.OPCItems.AddItem(FOPCTunnel.FImpDataTag);

    nOPCServer.Active := true;
    Application.ProcessMessages;

    nGroup.SyncRead(nil,FromCache);
    //nGroup.ASyncRead(nil);
    Application.ProcessMessages;
    nItemList := TdOPCItemList.create(nGroup.OPCItems);
    try
      OnDatachange(self,nItemList);
    except

    end;
  finally
    if Assigned(nItemList) then
      nItemList.Free;
    nOPCServer.Free;
    CoUninitialize;                        // !!!!!!!!!!!!!
  end;
end;

procedure TFrame1.OnDatachange(Sender: TObject;
  ItemList: TdOPCItemList);
var
  nIdx: Integer;
  nValue: Double;
  nZValue, nBiLi : Double;
begin
  for nIdx := 0 to Itemlist.Count-1 do
  begin
    if Itemlist[nIdx].ItemId = FOPCTunnel.FImpDataTag then
    begin
      WriteLog(FOPCTunnel.FImpDataTag+':'+Itemlist[nIdx].ValueStr);
      if IsNumber(Itemlist[nIdx].ValueStr, True) then
      begin
        nValue := StrToFloat(Itemlist[nIdx].ValueStr) + FHasDone;
        EditValue.Text := Format('%.2f', [nValue]);
        if Length(Trim(EditBill.Text)) > 0 then
          ShowLedText(FOPCTunnel.FID, '��ǰ�ۼ�����:'+ EditValue.Text);

        nZValue := StrToFloatDef(editZValue.Text,0);    //Ʊ��

        nBiLi := 0;
        if nZValue > 0 then
          nBiLi := nValue/nZValue *100;                //��ɱ���

        editNetValue.Text := EditValue.Text;
        editBiLi.Text := Format('%.2f',[nBiLi]);
      end;
    end;
  end;
end;

procedure TFrame1.StateTimerTimer(Sender: TObject);
begin
  StateTimer.Enabled := False;
  StateTimer.Tag := StateTimer.Tag + 1;
  SyncReadValues(False);
  StateTimer.Enabled := True;
end;

end.
