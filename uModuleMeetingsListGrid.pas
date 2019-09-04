unit uModuleMeetingsListGrid;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, dmDatabaseModule, FireDAC.Comp.Client, DataGrid, uModuleMeetingsClientListGrid, HelperChilds;

type
  TModuleMeetingsListGrid = class(TForm)
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure OnDataGridDblClick(IndexKey: Integer);
  private
    TableQuery: TFDQuery;
  public
    DataGrid: TDataGrid;
  end;

var
  ModuleMeetingsListGrid: TModuleMeetingsListGrid;

implementation

{$R *.dfm}

procedure TModuleMeetingsListGrid.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Self.Free;
end;

procedure TModuleMeetingsListGrid.FormCreate(Sender: TObject);
begin
  TableQuery := DatabaseModule.SetQuery('SELECT *, COUNT(m.meeting_id) AS meeting_total FROM p_meetings AS m', False);
  TableQuery.SQL.Add(' LEFT JOIN p_clients AS c ON m.meeting_client_id = c.client_id');
  TableQuery.SQL.Add(' GROUP BY meeting_client_id');

  DataGrid := TDataGrid.Create;
  DataGrid.SetIndexKey('meeting_id');
  DataGrid.SetQuery(TableQuery);
  DataGrid.Sorting('meeting_date', 'DESC');

  DataGrid.OnDataGridDblClick := OnDataGridDblClick;

  DataGrid.AddColumn('client_name', 'Firma', ctText).SetSortable;
  DataGrid.AddColumn('meeting_date', 'Poslední zápis', ctDate).SetSortable;
  DataGrid.AddColumn('meeting_total', 'Poèet zápisù', ctText);

  DataGrid.AddFilter('client_name', 'Firma:', ftText);
end;

procedure TModuleMeetingsListGrid.FormShow(Sender: TObject);
begin
  DataGrid.Render(Self);
end;

procedure TModuleMeetingsListGrid.OnDataGridDblClick(IndexKey: Integer);
var
  ModuleMeetingsClientListGrid: TModuleMeetingsClientListGrid;
begin
  if IndexKey <> -1 then
  begin
    TableQuery.IndexFieldNames := 'meeting_id';
    TableQuery.FindKey([IndexKey]);

    ModuleMeetingsClientListGrid := TModuleMeetingsClientListGrid.Create(Self);
    ModuleMeetingsClientListGrid.MeetingsByClient(TableQuery.FieldByName('meeting_client_id').AsInteger);
    ModuleMeetingsClientListGrid.Caption := TableQuery.FieldByName('client_name').AsString + ' - Seznam jednání';
    ModuleMeetingsClientListGrid.Show;
    ModuleMeetingsClientListGrid.OnClose := DataGrid.OnCloseReloadGrid;

    AddChildTab(ModuleMeetingsClientListGrid);
  end;
end;

end.
