{*******************************************************************************
  ����: dmzn@163.com 2012-5-3
  ����: ����ģ��
*******************************************************************************}
unit UDataModule;

interface

uses
  SysUtils, Classes, DB, ADODB, USysLoger;

type
  TFDM = class(TDataModule)
    ADOConn: TADOConnection;
    SQLQuery1: TADOQuery;
    SQLTemp: TADOQuery;
  private
    { Private declarations }
  public
    { Public declarations }
    function SQLQuery(const nSQL: string; const nQuery: TADOQuery): TDataSet;
    //��ѯ���ݿ�
    function SQLExecute(const nSQL: string; const nQuery: TADOQuery): Integer;
    //д���ݿ�
  end;

var
  FDM: TFDM;

implementation

{$R *.dfm}

procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TFDM, '����ģ��', nEvent);
end;

function TFDM.SQLExecute(const nSQL: string; const nQuery: TADOQuery): Integer;
begin
  Result := -1;

  try
    if not ADOConn.Connected then
      ADOConn.Connected := True;

    with nQuery do
    begin
      Close;
      SQL.Text := nSQL;
      Result:= ExecSQL;
    end;
  except
    on E:Exception do
    begin
      ADOConn.Connected := False;
      WriteLog(E.Message);
    end;
  end;
end;

//Date: 2012-5-3
//Parm: SQL;�Ƿ񱣳�����
//Desc: ִ��SQL���ݿ��ѯ
function TFDM.SQLQuery(const nSQL: string; const nQuery: TADOQuery): TDataSet;
var nInt: Integer;
begin
  Result := nil;
  nInt := 0;

  while nInt < 2 do
  try
    if not ADOConn.Connected then
      ADOConn.Connected := True;
    //xxxxx

    with nQuery do
    begin
      Close;
      SQL.Text := nSQL;
      Open;
    end;

    Result := nQuery;
    Exit;
  except
    on E:Exception do
    begin
      ADOConn.Connected := False;
      Inc(nInt);
      WriteLog(E.Message);
    end;
  end;
end;

end.
