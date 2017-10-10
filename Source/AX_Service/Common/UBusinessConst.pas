{*******************************************************************************
  ����: dmzn@163.com 2012-02-03
  ����: ҵ��������

  ��ע:
  *.����In/Out����,��ô���TBWDataBase������,��λ�ڵ�һ��Ԫ��.
*******************************************************************************}
unit UBusinessConst;

interface

uses
  UBusinessPacker;

const
  {*channel type*}
  cBus_Channel_Connection     = $0002;
  cBus_Channel_Business       = $0005;

  {*business command*}
  cBC_ReadBillInfo            = $0001;
  cBC_AXSalesOrder            = $0300;//��ȡAX���۶���
  cBC_AXSalesOrdLine          = $0301;//��ȡAX���۶�����
  cBC_AXSupAgreement          = $0302;//��ȡ����Э��
  cBC_AXCreLimCust            = $0303;//��ȡ���ö���������ͻ���
  cBC_AXCreLimCusCont         = $0304;//��ȡ���ö���������ͻ�-��ͬ��
  cBC_AXSalesCont             = $0305;//��ȡ���ۺ�ͬ
  cBC_AXSalesContLine         = $0306;//��ȡ���ۺ�ͬ��
  cBC_AXVehicleNo             = $0307;//��ȡ����
  cBC_AXPurOrder              = $0308;//��ȡ�ɹ�����
  cBC_AXPurOrdLine            = $0309;//��ȡ�ɹ�������
  cBC_AXCustNo                = $0310;//��ȡ�ͻ���Ϣ
  cBC_AXProvider              = $0311;//��ȡ��Ӧ����Ϣ
  cBC_AXMaterails             = $0312;//��ȡ������Ϣ
  cBC_AXThInfo                = $0313;//��ȡ�����Ϣ
  cBC_AXYKAmount              = $0314;//����Ԥ�۽��

type
  PReadXSSaleOrderIn = ^TReadXSSaleOrderIn;
  TReadXSSaleOrderIn = record
    FBase  : TBWDataBase;          //��������
    FVBELN : string;               //���۶�����
    FVSTEL : string;               //װ�˵�,���յ�
  end;

  PWorkerMessageData = ^TWorkerMessageData;
  TWorkerMessageData = record
    FBase     : TBWDataBase;
    FCommand  : Integer;           //����
    FData     : string;            //����
    FExtParam : string;            //����
  end;

  PWorkerBusinessAXCommand = ^TWorkerBusinessAXCommand;
  TWorkerBusinessAXCommand = record
    FBase     : TBWDataBase;
    FCommand  : Integer;           //����
    FData     : string;            //����
    FExtParam : string;            //����
    FExXml    : string;            //xml
    FRemoteUL : string;            //����������UL
  end;

resourcestring
  {*plug module id*}
  sPlug_ModuleBus             = '{DF261765-48DC-411D-B6F2-0B37B14E014E}';
                                                        //ҵ��ģ��
  {*common function*}
  sSys_SweetHeart             = 'Sys_SweetHeart';       //����ָ��
  sSys_BasePacker             = 'Sys_BasePacker';       //���������

  {*business mit function name*}
  sBus_ServiceStatus          = 'Bus_ServiceStatus';    //����״̬
  sBus_BusinessAXCommand        = 'Bus_BusinessAXCommand';  //ҵ��ָ��
  sBus_BusinessMessage        = 'Bus_BusinessMessage'; //�������Ϣָ��

  {*client function name*}
  sCLI_BusinessMessage        = 'CLI_BusinessMessage';  //�ͻ�����Ϣָ��

implementation

end.


