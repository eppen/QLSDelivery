{*******************************************************************************
  ����: dmzn@163.com 2012-02-03
  ����: ҵ��������

  ��ע:
  *.����In/Out����,��ô���TBWDataBase������,��λ�ڵ�һ��Ԫ��.
*******************************************************************************}
unit UBusinessConst;

interface

uses
  Classes, SysUtils, UBusinessPacker, ULibFun, USysDB;

const
  {*channel type*}
  cBus_Channel_Connection     = $0002;
  cBus_Channel_Business       = $0005;

  {*query field define*}
  cQF_Bill                    = $0001;

  {*business command*}
  cBC_GetSerialNO             = $0001;   //��ȡ���б��
  cBC_ServerNow               = $0002;   //��������ǰʱ��
  cBC_IsSystemExpired         = $0003;   //ϵͳ�Ƿ��ѹ���
  cBC_GetCardUsed             = $0004;   //��ȡ��Ƭ����
  cBC_UserLogin               = $0005;   //�û���¼
  cBC_UserLogOut              = $0006;   //�û�ע��

  cBC_CustomerMaCredLmt       = $0009;   //��ȡ�ͻ��Ƿ�ǿ��У������
  cBC_GetCustomerMoney        = $0010;   //��ȡ�ͻ����ý�
  cBC_GetZhiKaMoney           = $0011;   //��ȡֽ�����ý�
  cBC_CustomerHasMoney        = $0012;   //�ͻ��Ƿ������

  cBC_SaveTruckInfo           = $0013;   //���泵����Ϣ
  cBC_UpdateTruckInfo         = $0017;   //���泵����Ϣ
  cBC_GetTruckPoundData       = $0015;   //��ȡ������������
  cBC_SaveTruckPoundData      = $0016;   //���泵����������

  cBC_SaveBills               = $0020;   //���潻�����б�
  cBC_DeleteBill              = $0021;   //ɾ��������
  cBC_ModifyBillTruck         = $0022;   //�޸ĳ��ƺ�
  cBC_SaleAdjust              = $0023;   //���۵���
  cBC_SaveBillCard            = $0024;   //�󶨽������ſ�
  cBC_LogoffCard              = $0025;   //ע���ſ�
  cBC_GetSampleID             = $0026;   //��ȡ�������
  cBC_GetCenterID             = $0027;   //��ȡ������ID

  cBC_SaveOrder               = $0040;
  cBC_DeleteOrder             = $0041;
  cBC_SaveOrderCard           = $0042;
  cBC_LogOffOrderCard         = $0043;
  cBC_GetPostOrders           = $0044;   //��ȡ��λ�ɹ���
  cBC_SavePostOrders          = $0045;   //�����λ�ɹ���
  cBC_SaveOrderBase           = $0046;   //����ɹ����뵥
  cBC_DeleteOrderBase         = $0047;   //ɾ���ɹ����뵥
  cBC_GetGYOrderValue         = $0048;   //��ȡ���ջ���

  cBC_SaveDDCard              = $0047;
  cBC_LogOffDDCard            = $0048;
  cBC_GetPostDDs              = $0049;   //��ȡ��λ�ɹ���
  cBC_SavePostDDs             = $0050;   //�����λ�ɹ���
  cBC_AXSyncDuanDao           = $0051;   //ͬ���̵�

  cBC_GetPostBills            = $0030;   //��ȡ��λ������
  cBC_SavePostBills           = $0031;   //�����λ������

  cBC_ChangeDispatchMode      = $0053;   //�л�����ģʽ
  cBC_GetPoundCard            = $0054;   //��ȡ��վ����
  cBC_GetQueueData            = $0055;   //��ȡ��������
  cBC_PrintCode               = $0056;
  cBC_PrintFixCode            = $0057;   //����
  cBC_PrinterEnable           = $0058;   //�������ͣ

  cBC_JSStart                 = $0060;
  cBC_JSStop                  = $0061;
  cBC_JSPause                 = $0062;
  cBC_JSGetStatus             = $0063;
  cBC_SaveCountData           = $0064;   //����������
  cBC_RemoteExecSQL           = $0065;

  cBC_IsTunnelOK              = $0075;   //��ѯ����״̬
  cBC_TunnelOC                = $0076;   //���̵ƿ���
  cBC_OPenPoundDoor           = $0077;   //��բ̧��

  cBC_SyncCustomer            = $0080;   //Զ��ͬ���ͻ�
  cBC_SyncSaleMan             = $0081;   //Զ��ͬ��ҵ��Ա
  cBC_SyncStockBill           = $0082;   //ͬ�����ݵ�Զ��
  cBC_CheckStockValid         = $0083;   //��֤�Ƿ�������
  cBC_SyncStockOrder          = $0084;   //ͬ���ɹ����ݵ�Զ��
  cBC_SyncProvider            = $0085;   //Զ��ͬ����Ӧ��
  cBC_SyncMaterails           = $0086;   //Զ��ͬ��ԭ����

  cBC_RegWeiXin               = $0087;   //΢��ע��
  cBC_BindUserWeiXin          = $0088;   //���û�

  cBC_SyncInvDim              = $0089;   //Զ��ͬ��ά����Ϣ
  cBC_SyncInvCenter           = $0090;   //Զ��ͬ����������Ϣ
  cBC_SyncInvLocation         = $0091;   //Զ��ͬ���ֿ���Ϣ
  cBC_SyncTprGem              = $0092;   //Զ��ͬ�����ö�ȣ��ͻ���
  cBC_SyncTprGemCont          = $0093;   //Զ��ͬ�����ö�ȣ��ͻ�-��ͬ��
  cBC_SyncEmpTable            = $0094;   //Զ��ͬ��Ա����Ϣ
  cBC_SyncInvCenGroup         = $0095;   //Զ��ͬ��������������
  cBC_GetSalesOrder           = $0096;   //��ȡ���۶���
  cBC_GetSalesOrdLine         = $0097;   //��ȡ���۶�����
  cBC_GetSupAgreement         = $0098;   //��ȡ����Э��
  cBC_GetCreLimCust           = $0099;   //��ȡ���ö���������ͻ���
  cBC_GetCreLimCusCont        = $0100;   //��ȡ���ö���������ͻ�-��ͬ��
  cBC_GetSalesCont            = $0101;   //��ȡ���ۺ�ͬ
  cBC_GetSalesContLine        = $0102;   //��ȡ���ۺ�ͬ��
  cBC_GetVehicleNo            = $0103;   //��ȡ����
  cBC_GetPurOrder             = $0104;   //��ȡ�ɹ�����
  cBC_GetPurOrdLine           = $0105;   //��ȡ�ɹ�������
  cBC_SyncFYBillAX            = $0106;   //ͬ���������AX
  cBC_SyncVehNoAX             = $0107;   //ͬ�����ŵ�AX
  cBC_SyncAXCement            = $0108;   //Զ��ͬ��ˮ������
  cBC_GetTprGem               = $0109;   //���߻�ȡ���ö�ȣ��ͻ���
  cBC_GetTprGemCont           = $0110;   //���߻�ȡ���ö�ȣ��ͻ�-��ͬ��
  cBC_SyncDelSBillAX          = $0111;   //ͬ��ɾ�������
  cBC_SyncEmpOutBillAX        = $0112;   //ͬ���ճ����������
  cBC_GetTriangleTrade        = $0113;   //�ж��Ƿ�����ó��
  cBC_GetAXMaCredLmt          = $0114;   //�Ƿ�ǿ�����ö��
  cBC_GetAXContQuota          = $0115;   //�Ƿ�ר��ר��
  cBC_GetCustNo               = $0116;   //��ȡ���տͻ�
  cBC_GetAXCompanyArea        = $0117;   //���߻�ȡ��������
  cBC_GetAXInVentSum          = $0118;   //���߻�ȡ����������
  cBC_SyncAXwmsLocation       = $0119;   //ͬ����λ��Ϣ��DL

type
  PWorkerQueryFieldData = ^TWorkerQueryFieldData;
  TWorkerQueryFieldData = record
    FBase     : TBWDataBase;
    FType     : Integer;           //����
    FData     : string;            //����
  end;

  PWorkerBusinessCommand = ^TWorkerBusinessCommand;
  TWorkerBusinessCommand = record
    FBase     : TBWDataBase;
    FCommand  : Integer;           //����
    FData     : string;            //����
    FExtParam : string;            //����
  end;

  TPoundStationData = record
    FStation  : string;            //��վ��ʶ
    FValue    : Double;           //Ƥ��
    FDate     : TDateTime;        //��������
    FOperator : string;           //����Ա
  end;

  PLadingBillItem = ^TLadingBillItem;
  TLadingBillItem = record
    FID         : string;          //��������
    FZhiKa      : string;          //ֽ�����
    FCusID      : string;          //�ͻ����
    FCusName    : string;          //�ͻ�����
    FTruck      : string;          //���ƺ���

    FType       : string;          //Ʒ������
    FStockNo    : string;          //Ʒ�ֱ��
    FStockName  : string;          //Ʒ������
    FValue      : Double;          //�����
    FPrice      : Double;          //�������

    FCard       : string;          //�ſ���
    FIsVIP      : string;          //ͨ������
    FStatus     : string;          //��ǰ״̬
    FNextStatus : string;          //��һ״̬

    FPData      : TPoundStationData; //��Ƥ
    FMData      : TPoundStationData; //��ë
    FFactory    : string;          //�������
    FPModel     : string;          //����ģʽ
    FPType      : string;          //ҵ������
    FPoundID    : string;          //���ؼ�¼
    FSelected   : Boolean;         //ѡ��״̬

    FYSValid    : string;          //���ս����Y���ճɹ���N���գ�
    FKZValue    : Double;          //��Ӧ�۳�
    FMemo       : string;          //������ע
    FSampleID   : string;          //�������
    FCenterID   : string;          //������ID
    FLocationID : string;          //�ֿ�ID
    FSalesType  : string;          //��������
    FRecID      : string;          //�����б���
    FKw         : string;          //��λ
    FWorkOrder  : string;          //���
    FTriaTrade  : string;          //����ó��
    FNeiDao     : string;          //�ڵ�
  end;

  TLadingBillItems = array of TLadingBillItem;
  //�������б�

procedure AnalyseBillItems(const nData: string; var nItems: TLadingBillItems);
//������ҵ����󷵻صĽ���������
function CombineBillItmes(const nItems: TLadingBillItems): string;
//�ϲ�����������Ϊҵ������ܴ�����ַ���

resourcestring
  {*PBWDataBase.FParam*}
  sParam_NoHintOnError        = 'NHE';                  //����ʾ����

  {*plug module id*}
  sPlug_ModuleBus             = '{DF261765-48DC-411D-B6F2-0B37B14E014E}';
                                                        //ҵ��ģ��
  sPlug_ModuleHD              = '{B584DCD6-40E5-413C-B9F3-6DD75AEF1C62}';
                                                        //Ӳ���ػ�
                                                                                                   
  {*common function*}  
  sSys_BasePacker             = 'Sys_BasePacker';       //���������

  {*business mit function name*}
  sBus_ServiceStatus          = 'Bus_ServiceStatus';    //����״̬
  sBus_GetQueryField          = 'Bus_GetQueryField';    //��ѯ���ֶ�

  sBus_BusinessSaleBill       = 'Bus_BusinessSaleBill'; //���������
  sBus_BusinessCommand        = 'Bus_BusinessCommand';  //ҵ��ָ��
  sBus_HardwareCommand        = 'Bus_HardwareCommand';  //Ӳ��ָ��
  sBus_BusinessPurchaseOrder  = 'Bus_BusinessPurchaseOrder'; //�ɹ������
  sBus_BusinessRegWeiXin      = 'Bus_BusinessRegWeiXin'; //΢��ע�����
  sBus_BusinessDuanDao        = 'Bus_BusinessDuanDao';  //�̵�ҵ�����

  {*client function name*}
  sCLI_ServiceStatus          = 'CLI_ServiceStatus';    //����״̬
  sCLI_GetQueryField          = 'CLI_GetQueryField';    //��ѯ���ֶ�

  sCLI_BusinessSaleBill       = 'CLI_BusinessSaleBill'; //������ҵ��
  sCLI_BusinessCommand        = 'CLI_BusinessCommand';  //ҵ��ָ��
  sCLI_HardwareCommand        = 'CLI_HardwareCommand';  //Ӳ��ָ��
  sCLI_BusinessPurchaseOrder  = 'CLI_BusinessPurchaseOrder'; //�ɹ������
  sCLI_BusinessRegWeiXin      = 'CLI_BusinessRegWeiXin';  //΢��ע��
  sCLI_BusinessBindUserWeiXin = 'CLI_BusinessBindUserWeiXin'; //�������û���΢�ţ�
  sCLI_BusinessDuanDao        = 'CLI_BusinessDuanDao';  //�̵�ҵ�����

implementation

//Date: 2014-09-17
//Parm: ����������;�������
//Desc: ����nDataΪ�ṹ���б�����
procedure AnalyseBillItems(const nData: string; var nItems: TLadingBillItems);
var nStr: string;
    nIdx,nInt: Integer;
    nListA,nListB: TStrings;
begin
  nListA := TStringList.Create;
  nListB := TStringList.Create;
  try
    nListA.Text := PackerDecodeStr(nData);
    //bill list
    nInt := 0;
    SetLength(nItems, nListA.Count);

    for nIdx:=0 to nListA.Count - 1 do
    begin
      nListB.Text := PackerDecodeStr(nListA[nIdx]);
      //bill item

      with nListB,nItems[nInt] do
      begin
        FID         := Values['ID'];
        FZhiKa      := Values['ZhiKa'];
        FCusID      := Values['CusID'];
        FCusName    := Values['CusName'];
        FTruck      := Values['Truck'];

        FType       := Values['Type'];
        FStockNo    := Values['StockNo'];
        FStockName  := Values['StockName'];

        FCard       := Values['Card'];
        FIsVIP      := Values['IsVIP'];
        FStatus     := Values['Status'];
        FNextStatus := Values['NextStatus'];

        FFactory    := Values['Factory'];
        FPModel     := Values['PModel'];
        FPType      := Values['PType'];
        FPoundID    := Values['PoundID'];
        FSelected   := Values['Selected'] = sFlag_Yes;

        with FPData do
        begin
          FStation  := Values['PStation'];
          FDate     := Str2DateTime(Values['PDate']);
          FOperator := Values['PMan'];

          nStr := Trim(Values['PValue']);
          if (nStr <> '') and IsNumber(nStr, True) then
               FPData.FValue := StrToFloat(nStr)
          else FPData.FValue := 0;
        end;

        with FMData do
        begin
          FStation  := Values['MStation'];
          FDate     := Str2DateTime(Values['MDate']);
          FOperator := Values['MMan'];

          nStr := Trim(Values['MValue']);
          if (nStr <> '') and IsNumber(nStr, True) then
               FMData.FValue := StrToFloat(nStr)
          else FMData.FValue := 0;
        end;

        nStr := Trim(Values['Value']);
        if (nStr <> '') and IsNumber(nStr, True) then
             FValue := StrToFloat(nStr)
        else FValue := 0;

        nStr := Trim(Values['Price']);
        if (nStr <> '') and IsNumber(nStr, True) then
             FPrice := StrToFloat(nStr)
        else FPrice := 0;

        nStr := Trim(Values['KZValue']);
        if (nStr <> '') and IsNumber(nStr, True) then
             FKZValue := StrToFloat(nStr)
        else FKZValue := 0;

        FYSValid:= Values['YSValid'];
        FMemo := Values['Memo'];
        FSampleID := Values['SampleID'];          //�������
        FCenterID := Values['CenterID'];          //������ID
        FLocationID:= Values['LocationID'];       //�ֿ�ID
        FSalesType:= Values['SalesType'];         //��������
        FRecID    := Values['RecID'];             //�����б���
        FKw       := Values['KuWei'];             //��λ
        FWorkOrder:= Values['WorkOrder'];         //���
        FTriaTrade:= Values['TriaTrade'];         //����ó��
        FNeiDao   := Values['NeiDao'];            //�ڵ�
      end;

      Inc(nInt);
    end;
  finally
    nListB.Free;
    nListA.Free;
  end;   
end;

//Date: 2014-09-18
//Parm: �������б�
//Desc: ��nItems�ϲ�Ϊҵ������ܴ����
function CombineBillItmes(const nItems: TLadingBillItems): string;
var nIdx: Integer;
    nListA,nListB: TStrings;
begin
  nListA := TStringList.Create;
  nListB := TStringList.Create;
  try
    Result := '';
    nListA.Clear;
    nListB.Clear;

    for nIdx:=Low(nItems) to High(nItems) do
    with nItems[nIdx] do
    begin
      if not FSelected then Continue;
      //ignored

      with nListB do
      begin
        Values['ID']         := FID;
        Values['ZhiKa']      := FZhiKa;
        Values['CusID']      := FCusID;
        Values['CusName']    := FCusName;
        Values['Truck']      := FTruck;

        Values['Type']       := FType;
        Values['StockNo']    := FStockNo;
        Values['StockName']  := FStockName;
        Values['Value']      := FloatToStr(FValue);
        Values['Price']      := FloatToStr(FPrice);

        Values['Card']       := FCard;
        Values['IsVIP']      := FIsVIP;
        Values['Status']     := FStatus;
        Values['NextStatus'] := FNextStatus;

        Values['Factory']    := FFactory;
        Values['PModel']     := FPModel;
        Values['PType']      := FPType;
        Values['PoundID']    := FPoundID;

        with FPData do
        begin
          Values['PStation'] := FStation;
          Values['PValue']   := FloatToStr(FPData.FValue);
          Values['PDate']    := DateTime2Str(FDate);
          Values['PMan']     := FOperator;
        end;

        with FMData do
        begin
          Values['MStation'] := FStation;
          Values['MValue']   := FloatToStr(FMData.FValue);
          Values['MDate']    := DateTime2Str(FDate);
          Values['MMan']     := FOperator;
        end;

        if FSelected then
             Values['Selected'] := sFlag_Yes
        else Values['Selected'] := sFlag_No;

        Values['KZValue']    := FloatToStr(FKZValue);
        Values['YSValid']    := FYSValid;
        Values['Memo']       := FMemo;
        
        Values['SampleID']   := FSampleID;          //�������
        Values['CenterID']   := FCenterID;          //������ID
        Values['LocationID'] := FLocationID;        //�ֿ�ID
        Values['SalesType']  := FSalesType;         //��������
        Values['RecID']      := FRecID;             //�����б���
        Values['KuWei']      := FKw;                //��λ
        Values['WorkOrder']  := FWorkOrder;         //���
        Values['TriaTrade']  := FTriaTrade;         //����ó��
        Values['NeiDao']     := FNeiDao;              //�ڵ�
      end;

      nListA.Add(PackerEncodeStr(nListB.Text));
      //add bill
    end;

    Result := PackerEncodeStr(nListA.Text);
    //pack all
  finally
    nListB.Free;
    nListA.Free;
  end;
end;

end.


