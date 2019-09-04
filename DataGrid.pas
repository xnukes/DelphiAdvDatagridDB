unit DataGrid;

interface

uses
  Winapi.Windows, System.Classes, System.SysUtils, Vcl.Controls, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Graphics, AdvGrid,
  Vcl.Grids, Vcl.Buttons, Vcl.Dialogs, Vcl.Forms, System.UITypes, pngimage, dmDatabaseModule, FireDAC.Phys.Intf,
  Paginator, FireDAC.Comp.Client, FireDAC.Stan.Option, FireDAC.Stan.Intf, Data.DB, StrUtils, tmsAdvGridExcel,
  uHelperCurrencies,  HelperChilds, UBaseForm, AdvMenus, Vcl.Menus, clisted, asgprint, Printers, IniFiles, HelperDebugger,
  Winapi.Messages, AdvDateTimePicker;

type
  TDataGridColumn = class;
  TDataGridFilter = class;
  TColumnType = (ctText, ctNumber, ctCurrency, ctDate, ctTime, ctDateTime, ctBoolean, ctFloat, ctFileSize, ctVirtual);
  TDataGridFilterType = (ftText, ftSelect, ftDate, ftDateTime, ftCheckBox);
  TDataGridFilterCondition = (fcEqual, fcNotEqual, fcLowThen, fcHighThen, fcLike);
  TDataGridDblClickEvent = procedure(IndexKey: Integer) of object;
  TDataGridBtnCreateEvent = procedure(Sender: TObject) of object;
  TDataGridColumnRenderer = function(Query: TFDCustomQuery; DataGridColumn: TDataGridColumn): String of object;
  TDataGridOnFilterRecords = procedure(DataSet: TDataSet; var Accept: Boolean) of object;
  TDataGridBeforeReloadGrid = procedure(DataSet: TDataSet) of object;
  TDataGridAfterReloadGrid = procedure(DataSet: TDataSet) of object;
  TDataGridDeleteRecordEvent = procedure(DataSet: TDataSet; Index: Integer) of object;
  TDataGridFilter = class(TObject)
    private
      FilterValueString: string;
      FilterValueInteger: Integer;
      FilterValueFloat: Double;
      FilterValueDateTime: TDateTime;
    protected
      Index: Integer;
      Key: string;
      Title: string;
      FilterType: TDataGridFilterType;
      FilterCondition: TDataGridFilterCondition;
      FilterShowLabel: Boolean;
      _APairTableName: string;
      _APairColumnIndex: string;
      _APairColumnTitle: string;
      _AQueryWhere: string;
    public
      constructor Create;
      function SetPairs(TableName, ColumnIndex, ColumnTitle: string; const
          QueryWhere: string = ''): TDataGridFilter;
    published
      property ValueString: string read FilterValueString;
      property ValueInteger: Integer read FilterValueInteger;
      property ValueFloat: Double read FilterValueFloat;
      property ValueDateTime: TDateTime read FilterValueDateTime;
  end;
  TArrayDataGridFilter = Array of TDataGridFilter;
  TDataGridColumn = class(TObject)
    protected
      Index: Integer;
      Key: string;
      Title: string;
      ColumnType: TColumnType;
      _ASuffix: string;
      _APrefix: string;
      _AColor: TColor;
      _ABgColor: TColor;
      _ABold: Boolean;
      _AAlign: TAlignment;
      _ASortable: Boolean;
      _ACurrencyRefference: string;
      _AHidden: Boolean;
      ColumnRenderer: TDataGridColumnRenderer;
    public
      constructor Create;
      function GetKey: string;
      function GetTitle: string;
      function SetSuffix(Suffix: string): TDataGridColumn;
      function SetPrefix(Prefix: string): TDataGridColumn;
      function SetBold(const Bold: Boolean = true): TDataGridColumn;
      function SetColor(Color: TColor): TDataGridColumn;
      function SetBgColor(Color: TColor): TDataGridColumn;
      function SetAlign(Align: TAlignment): TDataGridColumn;
      function SetSortable(const Sortable: Boolean = true): TDataGridColumn;
      function SetCurrencyRefference(Column: string): TDataGridColumn;
      function SetHidden(const Hidden: Boolean = True): TDataGridColumn;
    published
      property Renderer: TDataGridColumnRenderer read ColumnRenderer write ColumnRenderer;
  end;
  TArrayDataGridColumn = Array of TDataGridColumn;
  TDataGridSortingColumn = record
    Key: string;
    Title: string;
  end;
  TDataGridSortingColumns = Array of TDataGridSortingColumn;
  TDataGridFilterDefault = record
    Name: String;
    Value: String;
  end;
  TDataGridFilterDefaults = Array of TDataGridFilterDefault;
  TDataGrid = class(TObject)
    protected
      IndexKey: string;
      ItemsPerPage: Integer;
      QuerySQL: String;
      FilterDefaults: TDataGridFilterDefaults;
      _AHidePrintBtn: Boolean;
      _AHideExcelBtn: Boolean;
      _AHidePaginatorLabel: Boolean;
      _AHidePaginatorPagesInfo: Boolean;
      _AShowDeleteBtn: Boolean;
      function GetRecordIndex(): Integer;
    private
      Parent: TWinControl;
      ColumnsCheckList: TCheckListEdit;
      BarPanel: TPanel;
      FilterPanel: TPanel;
      PageInfo: TLabel;
      LabelBeforePaginator: TLabel;
      ExportToXlsButton: TBitBtn;
      RefreshButton: TBitBtn;
      CreateRecordButton: TBitBtn;
      DeleteRecordButton: TBitBtn;
      Columns: TArrayDataGridColumn;
      Filters: TArrayDataGridFilter;
      AdvGrid: TAdvStringGrid;
      AdvGridPrintSettings: TAdvGridPrintSettingsDialog;
      DataGridDblClickEvent: TDataGridDblClickEvent;
      DataGridBtnCreateEvent: TDataGridBtnCreateEvent;
      DataGridOnFilterRecords: TDataGridOnFilterRecords;
      DataGridBeforeReloadGrid: TDataGridBeforeReloadGrid;
      DataGridAfterReloadGrid: TDataGridAfterReloadGrid;
      DataGridDeleteRecordEvent: TDataGridDeleteRecordEvent;
      ShowEdit: Boolean;
      HelperCurrencies: TCurrencies;
      _AQuerySorting: string;
      _AQuerySortingAscDESC: string;
      _AFormCreate: TBaseFormClass;
      procedure OnChangePage(Page, Offset, Limit: Integer);
      procedure AdvGridDblClick(Sender: TObject);
      procedure ButtonRefreshClick(Sender: TObject);
      procedure ButtonDeleteClick(Sender: TObject);
      procedure ButtonExportXlsClick(Sender: TObject);
      procedure ButtonPrintGridClick(Sender: TObject);
      procedure CreateComponentSorting(Parent: TWinControl; Panel: TPanel);
      procedure ColumnsControlCheckShow(Sender: TObject);
      procedure CreateComponentColumnsControl(Parent: TWinControl; Panel: TPanel);
      procedure CreateComponentFilters(Parent: TWinControl; BarPanel: TPanel);
      procedure OnChangeFilter(Sender: TObject);
      function GetSortingColumns: TDataGridSortingColumns;
    public
      Query: TFDCustomQuery;
      Paginator: TPaginator;
      constructor Create();
      destructor Destroy; override;
      procedure SetQuery(Query: TFDCustomQuery);
      procedure SetIndexKey(Key: string);
      procedure SetItemsPerPage(ItemsPerPage: Integer);
      procedure LoadSettingsColsHide;
      function IsSortable: Boolean;
      procedure Render(Parent: TWinControl; const ReloadGrid: Boolean = True);
      function BytesToDisplay(const num: Int64): string;
      procedure ReloadGrid(Sender: TObject);
      procedure OnCloseReloadGrid(Sender: TObject; var Action: TCloseAction);
      procedure QueryFilterRecord(DataSet: TDataSet; var Accept: Boolean);
      function AddColumn(Key: string; Title: string; ColumnType: TColumnType): TDataGridColumn;
      function AddFilter(Key, Title: string; FilterType: TDataGridFilterType; const
          FilterCondition: TDataGridFilterCondition = fcEqual; const ShowLabel: Boolean = True): TDataGridFilter;
      procedure AddButtonBar(Button: TCustomButton);
      function GetColumn(Key: string): TDataGridColumn;
      function GetFilter(Key: string): TDataGridFilter;
      procedure Sorting(BySort: string; AscDesc: string);
      procedure AddFilterDefault(ColumnName: string; ColumnValue: string);
      procedure SetCreateForm(Form: TBaseFormClass);
      procedure OnClickButtonCreateForm(Sender: TObject);
      procedure OnDblClickGridCreateForm(IndexKey: Integer);
    published
      property OnDataGridDblClick: TDataGridDblClickEvent read DataGridDblClickEvent write DataGridDblClickEvent;
      property OnDataGridBtnCreateEvent: TDataGridBtnCreateEvent read DataGridBtnCreateEvent write DataGridBtnCreateEvent;
      property OnDataGridOnFilterRecords: TDataGridOnFilterRecords read DataGridOnFilterRecords write DataGridOnFilterRecords;
      property OnBeforeReloadGrid: TDataGridBeforeReloadGrid read DataGridBeforeReloadGrid write DataGridBeforeReloadGrid;
      property OnAfterReloadGrid: TDataGridAfterReloadGrid read DataGridAfterReloadGrid write DataGridAfterReloadGrid;
      property OnDeleteRecordEvent: TDataGridDeleteRecordEvent read DataGridDeleteRecordEvent write DataGridDeleteRecordEvent;
      property HidePrintBtn: Boolean read _AHidePrintBtn write _AHidePrintBtn;
      property HideExcelBtn: Boolean read _AHideExcelBtn write _AHideExcelBtn;
      property ShowDeleteBtn: Boolean read _AShowDeleteBtn write _AShowDeleteBtn;
      property HidePaginatorLabel: Boolean read _AHidePaginatorLabel write _AHidePaginatorLabel;
      property HidePaginatorPagesInfo: Boolean read _AHidePaginatorPagesInfo write _AHidePaginatorPagesInfo;
  end;

implementation

// TDataGridFilter ----------------------------------------

constructor TDataGridFilter.Create();
begin
  Key := '';
  FilterShowLabel := True;
  _APairTableName := '';
  _APairColumnIndex := '';
  _APairColumnTitle := '';
  _AQueryWhere := '';
end;

function TDataGridFilter.SetPairs(TableName, ColumnIndex, ColumnTitle: string;
    const QueryWhere: string = ''): TDataGridFilter;
begin
  _APairTableName := TableName;
  _APairColumnIndex := ColumnIndex;
  _APairColumnTitle := ColumnTitle;
  _AQueryWhere := QueryWhere;
  Result := Self;
end;

// TDataGridColumn ----------------------------------------

constructor TDataGridColumn.Create();
begin
  Self._ASuffix := '';
  Self._APrefix := '';
  Self._AColor := clNone;
  Self._ABgColor := clNone;
  Self._ABold := false;
  Self._AAlign := taLeftJustify;
  Self._ACurrencyRefference := '';
  Self._AHidden := False;
end;

function TDataGridColumn.GetKey: string;
begin
  Result := Self.Key;
end;

function TDataGridColumn.GetTitle: string;
begin
  Result := Self.Title;
end;

function TDataGridColumn.SetSuffix(Suffix: string): TDataGridColumn;
begin
  Self._ASuffix := Suffix;
  Result := Self;
end;

function TDataGridColumn.SetPrefix(Prefix: string): TDataGridColumn;
begin
  Self._APrefix := Prefix;
  Result := Self;
end;

function TDataGridColumn.SetBold(const Bold: Boolean = true): TDataGridColumn;
begin
  Self._ABold := Bold;
  Result := Self;
end;

function TDataGridColumn.SetColor(Color: TColor): TDataGridColumn;
begin
  Self._AColor := Color;
  Result := Self;
end;

function TDataGridColumn.SetBgColor(Color: TColor): TDataGridColumn;
begin
  Self._ABgColor := Color;
  Result := Self;
end;

function TDataGridColumn.SetAlign(Align: TAlignment): TDataGridColumn;
begin
  Self._AAlign := Align;
  Result := Self;
end;

function TDataGridColumn.SetSortable(const Sortable: Boolean = true): TDataGridColumn;
begin
  Self._ASortable := Sortable;
  Result := Self;
end;

function TDataGridColumn.SetCurrencyRefference(Column: string): TDataGridColumn;
begin
  Self._ACurrencyRefference := Column;
  Result := Self;
end;

function TDataGridColumn.SetHidden(const Hidden: Boolean = True): TDataGridColumn;
begin
  Self._AHidden := Hidden;
  Result := Self;
end;

// TDataGrid ----------------------------------------

constructor TDataGrid.Create();
begin
  SetLength(Columns, 0);
  SetLength(Filters, 0);
  SetLength(FilterDefaults, 0);
  Self.ShowEdit := False;
  Self._AQuerySorting := '';
  Self._AQuerySortingAscDESC := '';
  SetItemsPerPage(200); {TODO: load if saved per page in grid}
  _AHidePrintBtn := False;
  _AHideExcelBtn := False;
  _AHidePaginatorLabel := False;
  _AShowDeleteBtn := False;
end;

destructor TDataGrid.Destroy();
begin
//  Self.Query.FreeOnRelease;
end;

procedure TDataGrid.SetQuery(Query: TFDCustomQuery);
begin
  // assign query
  Self.Query := Query;

  // store default SQL query
  Self.QuerySQL := Self.Query.SQL.Text;
end;

procedure TDataGrid.SetIndexKey(Key: string);
begin
  Self.IndexKey := Key;
end;

procedure TDataGrid.SetItemsPerPage(ItemsPerPage: Integer);
begin
  Self.ItemsPerPage := ItemsPerPage;
end;

procedure TDataGrid.OnChangePage(Page, Offset, Limit: Integer);
begin
  ReloadGrid(Self);
end;

procedure TDataGrid.AddButtonBar(Button: TCustomButton);
begin
  Button.Parent := Self.BarPanel;
  Button.Align := alRight;
  Button.AlignWithMargins := True;
end;

procedure TDataGrid.AdvGridDblClick(Sender: TObject);
begin
  if Assigned(OnDataGridDblClick) then
    DataGridDblClickEvent(GetRecordIndex());
end;

procedure TDataGrid.ButtonPrintGridClick(Sender: TObject);
var
  PrinterSetupDialog: TPrinterSetupDialog;
begin
  try
    PrinterSetupDialog := TPrinterSetupDialog.Create(Self.Parent);
    AdvGridPrintSettings := TAdvGridPrintSettingsDialog.Create(Self.Parent);
    AdvGridPrintSettings.Grid := AdvGrid;

    AdvGridPrintSettings.Form.Caption := 'Náhled tisku';
    AdvGrid.PrintSettings.FitToPage := fpAlways;
    AdvGrid.PrintSettings.Orientation := poLandscape; // initialize to default poLandscape
    if AdvGridPrintSettings.Execute then
    begin
      Printer.Orientation := AdvGrid.PrintSettings.Orientation;
      if PrinterSetupDialog.Execute then
      begin
        AdvGrid.PrintSettings.Orientation := Printer.Orientation;
        AdvGrid.Print;
      end;
    end;
  finally
    PrinterSetupDialog.Free;
  end;
end;

procedure TDataGrid.ButtonExportXlsClick(Sender: TObject);
var
  SaveDialog : TSaveDialog;
  AdvGridExcelIO: TAdvGridExcelIO;
begin
  SaveDialog := TSaveDialog.Create(Self.Parent);
  SaveDialog.InitialDir := GetCurrentDir;
  SaveDialog.Filter := 'xls|*.xls';
  SaveDialog.DefaultExt := 'xls';
  SaveDialog.FileName := 'DataGridExport';

  if SaveDialog.Execute then
  begin
    AdvGridExcelIO := TAdvGridExcelIO.Create(Self.Parent);
    try
      AdvGridExcelIO.GridStartRow := 0;
      AdvGridExcelIO.GridStartCol := 0;
      AdvGridExcelIO.UseUnicode := True;
      AdvGridExcelIO.Options.ExportShowGridLines := True;
      AdvGridExcelIO.Options.ExportWordWrapped := False;
      AdvGridExcelIO.Options.ExportHardBorders := True;
      AdvGridExcelIO.Options.ExportSummaryRowsBelowDetail := True;
      AdvGridExcelIO.Options.ExportOverwrite := omWarn;
      AdvGridExcelIO.Options.ExportOverwriteMessage := 'Soubor %s existuje, chcete jej pøepsat ?';
      AdvGridExcelIO.Options.ExportHTMLTags := False;
      AdvGridExcelIO.Options.ExportHiddenColumns := True;
      AdvGridExcelIO.Options.ExportCellFormats := True;
      AdvGridExcelIO.Options.ExportCellProperties := True;
      AdvGridExcelIO.AutoResizeGrid := True;
      AdvGridExcelIO.Options.UseExcelStandardColorPalette := True;
      AdvGridExcelIO.Options.ExportShowInExcel := True;
      AdvGridExcelIO.AdvStringGrid := Self.AdvGrid;
      AdvGridExcelIO.XLSExport(SaveDialog.FileName);
    except on E: Exception do
      MessageDlg('Chyba exportu !' + #13#10 + E.Message, mtError, [mbOK], 0);
    end;
    AdvGridExcelIO.Free;
  end;

  SaveDialog.Free;
end;

procedure TDataGrid.ButtonRefreshClick(Sender: TObject);
begin
  ReloadGrid(Sender);
end;

procedure TDataGrid.ButtonDeleteClick(Sender: TObject);
begin
  if DatabaseModule.GetUser.User_Level_Id < 2 then
  begin
    showMessage('Nemáte dostateèná práva pro vymazání záznamu.');
    exit;
  end;
  if GetRecordIndex <> -1 then
  begin
    if MessageDlg('Opravdu chcete smazat záznam "' + AdvGrid.Cells[1, AdvGrid.Row] + '" ?', mtCustom, [mbNo, mbYes], 0) = mrYes then
    begin
      Self.Query.IndexFieldNames := Self.IndexKey; // must first set index
      Self.Query.FindKey([GetRecordIndex]);

      if Assigned(OnDeleteRecordEvent) then
      begin
        DataGridDeleteRecordEvent(Self.Query, GetRecordIndex); // pro smazani zaznamu musime zavolat nad datagridem Query.Delete;
      end
      else
      begin
        Self.Query.Delete; // mazeme zaznam pokud neni prirazena udalost smazani zaznamu
      end;

      Self.Query.IndexFieldNames := ''; // for sorting must be delete index
      ReloadGrid(Sender);
    end;
  end
  else
  begin
    ShowMessage('Prosím vyberte záznam.');
  end;
end;

function ResourceBITMAP(Identifier: String): TBitmap;
begin
  Result := TBitmap.Create;
  Result.LoadFromResourceName(HInstance, Identifier);
end;

function TDataGrid.GetRecordIndex(): Integer;
begin
  Result := StrToIntDef(AdvGrid.Cells[0, AdvGrid.Row], -1);
end;

function TDataGrid.IsSortable: Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := Low(Self.Columns) to High(Self.Columns) do
    if Self.Columns[I]._ASortable then
      Result := True;
end;

procedure TDataGrid.Render(Parent: TWinControl; const ReloadGrid: Boolean = True);
var
  I: Integer;
  MenuItem: TMenuItem;
begin
  Self.Parent := Parent;

  // fix form minwidth
  if Parent is TForm then
  begin
    Parent.Constraints.MinWidth := 800;
    Parent.Constraints.MinHeight := 300;
  end;

  if not Assigned(Self.Query) then
    raise Exception.Create('Please set query before render !');

  if IndexKey = '' then
    raise Exception.Create('Please set index key before render !');

  // create helpers
  HelperCurrencies := TCurrencies.Create(Parent);

  // create bar panel
  if not Assigned(BarPanel) then
    BarPanel := TPanel.Create(Parent);

  BarPanel.Parent := Parent;
  BarPanel.Align := alBottom;
  BarPanel.ParentBackground := False;
  BarPanel.Height := 34;
  BarPanel.BevelInner := bvNone;
  BarPanel.BevelOuter := bvNone;

  // create filter panel
  if not Assigned(FilterPanel) then
    FilterPanel := TPanel.Create(Parent);

  FilterPanel.Parent := Parent;
  FilterPanel.Align := alTop;
  FilterPanel.ParentBackground := False;
  FilterPanel.Height := 34;
  FilterPanel.BevelInner := bvNone;
  FilterPanel.BevelOuter := bvNone;

  // create paginator
  if not Assigned(PageInfo) then
    PageInfo := TLabel.Create(BarPanel);

  PageInfo.Parent := BarPanel;
  PageInfo.Left := 250;
  PageInfo.Align := alLeft;
  PageInfo.AlignWithMargins := True;
  PageInfo.Margins.Left := 5;
  PageInfo.Margins.Top := 10;
  PageInfo.Caption := '0 z 0';
  PageInfo.Name := 'PageInfo';
  PageInfo.Font.Style := [fsBold];

  if not Assigned(Paginator) then
    Paginator := TPaginator.Create(BarPanel);

  Paginator.Parent := BarPanel;
  Paginator.Left := 0;
  Paginator.Align := alLeft;
  Paginator.AlignWithMargins := True;
  Paginator.Width := 200;
  Paginator.ItemsPerPage := Self.ItemsPerPage;
  Paginator.TotalItemsCount := 0;
  Paginator.OnPageChange := OnChangePage;

  if not _AHidePaginatorLabel then
  begin
    if not Assigned(LabelBeforePaginator) then
      LabelBeforePaginator := TLabel.Create(BarPanel);

    LabelBeforePaginator.Parent := BarPanel;
    LabelBeforePaginator.Align := alLeft;
    LabelBeforePaginator.AlignWithMargins := True;
    LabelBeforePaginator.Margins.Left := 5;
    LabelBeforePaginator.Margins.Top := 10;
    LabelBeforePaginator.Caption := 'Stránkování: ';
    LabelBeforePaginator.Font.Style := [fsBold];
  end;

  // create buttons if assigned IFormFactory
  if Assigned(Self._AFormCreate) then
  begin
    if not Assigned(CreateRecordButton) then
      CreateRecordButton := TBitBtn.Create(BarPanel);

    CreateRecordButton.Parent := BarPanel;
    CreateRecordButton.Align := alRight;
    CreateRecordButton.Caption := '&Vytvoøit';
    CreateRecordButton.Default := True;
    CreateRecordButton.AlignWithMargins := True;
    CreateRecordButton.OnClick := OnClickButtonCreateForm;
    CreateRecordButton.Glyph.Assign(ResourceBITMAP('BTNADD'));

    Self.OnDataGridDblClick := OnDblClickGridCreateForm;

    if not Assigned(DeleteRecordButton) then
      DeleteRecordButton := TBitBtn.Create(BarPanel);

    DeleteRecordButton.Parent := BarPanel;
    DeleteRecordButton.Align := alRight;
    DeleteRecordButton.Caption := '&Smazat';
    DeleteRecordButton.AlignWithMargins := True;
    DeleteRecordButton.OnClick := ButtonDeleteClick;
    DeleteRecordButton.Glyph.Assign(ResourceBITMAP('BTNDELETE'));
  end;

  // create button new record & delete if assigned event
  if Assigned(OnDataGridBtnCreateEvent) and not Assigned(Self._AFormCreate) then
  begin
    if not Assigned(CreateRecordButton) then
      CreateRecordButton := TBitBtn.Create(BarPanel);

    CreateRecordButton.Parent := BarPanel;
    CreateRecordButton.Align := alRight;
    CreateRecordButton.Caption := '&Vytvoøit';
    CreateRecordButton.Default := True;
    CreateRecordButton.AlignWithMargins := True;
    CreateRecordButton.OnClick := OnDataGridBtnCreateEvent;
    CreateRecordButton.Glyph.Assign(ResourceBITMAP('BTNADD'));

    if not Assigned(DeleteRecordButton) then
      DeleteRecordButton := TBitBtn.Create(BarPanel);

    DeleteRecordButton.Parent := BarPanel;
    DeleteRecordButton.Align := alRight;
    DeleteRecordButton.Caption := '&Smazat';
    DeleteRecordButton.AlignWithMargins := True;
    DeleteRecordButton.OnClick := ButtonDeleteClick;
    DeleteRecordButton.Glyph.Assign(ResourceBITMAP('BTNDELETE'));
  end;

  if _AShowDeleteBtn then
  begin
    if not Assigned(DeleteRecordButton) then
      DeleteRecordButton := TBitBtn.Create(BarPanel);

    DeleteRecordButton.Parent := BarPanel;
    DeleteRecordButton.Align := alRight;
    DeleteRecordButton.Caption := '&Smazat';
    DeleteRecordButton.AlignWithMargins := True;
    DeleteRecordButton.OnClick := ButtonDeleteClick;
    DeleteRecordButton.Glyph.Assign(ResourceBITMAP('BTNDELETE'));
  end;

  // create refresh button
  if not Assigned(RefreshButton) then
    RefreshButton := TBitBtn.Create(BarPanel);

  RefreshButton.Parent := BarPanel;
  RefreshButton.Align := alRight;
  RefreshButton.Caption := '&Obnovit';
  RefreshButton.AlignWithMargins := True;
  RefreshButton.OnClick := ButtonRefreshClick;
  RefreshButton.Glyph.Assign(ResourceBITMAP('BTNREFRESH'));

  // create export to xls button
  if not _AHideExcelBtn then
  begin
    if not Assigned(ExportToXlsButton) then
      ExportToXlsButton := TBitBtn.Create(BarPanel);

    ExportToXlsButton.Parent := BarPanel;
    ExportToXlsButton.Align := alRight;
    ExportToXlsButton.Caption := '&XLS';
    ExportToXlsButton.AlignWithMargins := True;
    ExportToXlsButton.OnClick := ButtonExportXlsClick;
    ExportToXlsButton.Glyph.Assign(ResourceBITMAP('EXTXLS'));
  end;

  // create print grid button
  if not _AHidePrintBtn then
  begin
    with TBitBtn.Create(BarPanel) do
    begin
      Parent := BarPanel;
      Align := alRight;
      Caption := '&Tisk';
      AlignWithMargins := True;
      OnClick := ButtonPrintGridClick;
      Glyph.Assign(ResourceBITMAP('BTNPRINT'));
    end;
  end;

  // create datagrid visual component
  if not Assigned(AdvGrid) then
    AdvGrid := TAdvStringGrid.Create(Parent);

  AdvGrid.Parent := Parent;
  AdvGrid.Align := alClient;
  AdvGrid.ParentColor := False;
  AdvGrid.FixedCols := 1;
  AdvGrid.ColumnSize.StretchColumn := -1;
  AdvGrid.ColumnSize.Stretch := True;
  AdvGrid.ColumnSize.StretchAll := True;
  AdvGrid.ColumnSize.Rows := arNormal;
  AdvGrid.Options := AdvGrid.Options + [goRowSelect] - [goRangeSelect];
  AdvGrid.OnDblClick := AdvGridDblClick;
  AdvGrid.EditMode := False;
  AdvGrid.AutoThemeAdapt := False;
  AdvGrid.BorderStyle := bsNone;
//  AdvGrid.BorderColor := clBlack;

  AdvGrid.RowCount := 2;
  AdvGrid.FixedRows := 1;
  AdvGrid.ColCount := Length(Self.Columns) + 1;
  AdvGrid.ColWidths[0] := 0;

  // set header columns
  AdvGrid.Cells[0,0] := '-1';
  AdvGrid.Cells[1,0] := '-1';
  for I := Low(Self.Columns) to High(Self.Columns) do
  begin
    AdvGrid.Cells[I+1,0] := Self.Columns[I].Title;
    if Self.Columns[I]._AHidden then
      AdvGrid.HideColumn(I+1);
  end;

  // set fetch filtering options
  Self.Query.OnFilterRecord := QueryFilterRecord;
  Self.Query.Filtered := True;

  // set fetch option for best perfomance and custom paginator
  Self.Query.FetchOptions.CursorKind := ckDefault;
  Self.Query.FetchOptions.Mode := fmOnDemand;
  Self.Query.FetchOptions.RecordCountMode := cmTotal; // set fetch count mode to cmTotal
  Self.Query.FetchOptions.RowsetSize := Paginator.ItemsPerPage; // set dataset count items per page

  // open query
  if not Self.Query.OpenOrExecute then
    Self.Query.Open();

  Paginator.SetTotalItems(Self.Query.RecordCount); // set paginator total record count

  // create list checkboxes of show/hide columns
  CreateComponentColumnsControl(Parent, FilterPanel);

  // create sorting
  CreateComponentSorting(Parent, FilterPanel);

  // create filters
  CreateComponentFilters(Parent, FilterPanel);

  // reload grid
  if ReloadGrid then
    Self.ReloadGrid(Self);

  // set focus to string grid
  if AdvGrid.Showing then
    AdvGrid.SetFocus;
end;

procedure TDataGrid.ReloadGrid(Sender: TObject);
var
  I,ROW: Integer;
  RecordValue: String;
  ComboBox: TComboBox;
  SortingColumn: String;
  SortingType: String;
  TimerStart: Cardinal;
  DataField: TField;
begin
  TimerStart := GetTickCount;
  Debugger.Start('ReloadGrid');

  // set default sql query if difference
  if Self.Query.SQL.Text <> Self.QuerySQL then
    Self.Query.SQL.Text := Self.QuerySQL;

  // sorting by column if sortables or if datagrid sorting
  if IsSortable then
  begin
    // get sort by
    ComboBox := TComboBox(Self.Parent.FindComponent('SortingColumn'));
    if Assigned(ComboBox) then
    begin
      SortingColumn := string(ComboBox.Items.Objects[ComboBox.ItemIndex]);
    end;
    // get sort ascending or descending
    ComboBox := TComboBox(Self.Parent.FindComponent('SortingType'));
    if ComboBox.ItemIndex = 0 then
      SortingType := 'ASC'
    else
      SortingType := 'DESC';
    // add sql order by
    if (SortingColumn <> '') and (SortingType <> '') then
      Self.Query.SQL.Add(' ORDER BY ' + SortingColumn + ' ' + SortingType);
  end
  else
  begin
    if Self._AQuerySorting <> '' then
    begin
      Self.Query.SQL.Add(' ORDER BY ' + Self._AQuerySorting + ' ' + Self._AQuerySortingAscDESC);
    end;
  end;

  // callback before reload
  if Assigned(OnBeforeReloadGrid) then
    DataGridBeforeReloadGrid(Self.Query);

  Debugger.Point('BeforeQueryOpen');

  if not Self.Query.OpenOrExecute then
    Self.Query.Open();

  Debugger.Point('AfterQueryOpen');

  Debugger.Point('BeforeQueryFetchAgain');

  Self.Query.RecNo := Paginator.OffsetStart; // set dataset cursor

  // Debuger point
  Debugger.Point('AfterQueryFetchAgain');

  // set grid rows count
  AdvGrid.RowCount := Paginator.ItemsPerPage + 1;

  // disable control dataset
  Self.Query.DisableControls;

  // disable adv grid
  AdvGrid.Enabled := False;

  // grid start update
  AdvGrid.StartUpdate;

  // reset rows
  for I := 1 to AdvGrid.RowCount do
    AdvGrid.Rows[I].Clear;

  // set label page info
  PageInfo.Caption := Format('%d ze %d záznamù', [Paginator.OffsetStart, Paginator.TotalItemsCount]);

  // add rows
  ROW := 1;
  while not (Self.Query.Eof) and (ROW <= Paginator.ItemsPerPage) do
  begin
    AdvGrid.Cells[0,ROW] := Self.Query.FieldByName(Self.IndexKey).AsString;
    for I := Low(Self.Columns) to High(Self.Columns) do
    begin
      DataField := Self.Query.FieldByName(Self.Columns[I].Key);

      if Self.Columns[I].ColumnType = ctVirtual then
        RecordValue := ''
      else
        RecordValue := DataField.AsString;

      // column callback value renderer
      if Assigned(Self.Columns[I].ColumnRenderer) then
        RecordValue := Self.Columns[I].ColumnRenderer(Self.Query, Self.Columns[I]);

      // text value prefix
      if Self.Columns[I]._APrefix <> '' then
        RecordValue := Self.Columns[I]._APrefix + ' ' + RecordValue;

      // text value suffix
      if Self.Columns[I]._ASuffix <> '' then
        RecordValue := RecordValue + ' ' + Self.Columns[I]._ASuffix;

      // set column bold
      if Self.Columns[I]._ABold then
        AdvGrid.FontStyles[I+1,ROW] := AdvGrid.FontStyles[I+1,ROW] + [fsBold];

      // font color
      if Self.Columns[I]._AColor <> clNone then
        AdvGrid.FontColors[I+1,ROW] := Self.Columns[I]._AColor;

      // backgroud column color
      if (Self.Columns[I]._ABgColor <> clNone) and (Self.Columns[I]._ABgColor <> clWhite) then
        RecordValue := '<font bgColor="' + ColorToString(Self.Columns[I]._ABgColor) + '">' + RecordValue + '</font>';
//        AdvGrid.Colors[I+1,ROW] := Self.Columns[I]._ABgColor;

      // set column align
      if Self.Columns[I]._AAlign <> taLeftJustify then
        AdvGrid.Alignments[I+1,ROW] := Self.Columns[I]._AAlign;

      // assert value into column by type
      if Self.Columns[I].ColumnType = ctText then
        AdvGrid.Cells[I+1,ROW] := RecordValue;

      if Self.Columns[I].ColumnType = ctCurrency then
      begin
        if Self.Columns[I]._ACurrencyRefference <> '' then
          AdvGrid.Cells[I+1,ROW] := FormatFloat('#,##0.00', DataField.AsFloat)
          + ' ' + HelperCurrencies.GetCurrencyIdText(Self.Query.FieldByName(Self.Columns[I]._ACurrencyRefference).AsInteger, ctSymbol)
        else
          AdvGrid.Cells[I+1,ROW] := FormatFloat('#,##0.00', DataField.AsFloat);
      end;
      if Self.Columns[I].ColumnType = ctDate then
        AdvGrid.Cells[I+1,ROW] := DateToStr(DataField.AsDateTime);
      if Self.Columns[I].ColumnType = ctTime then
        AdvGrid.Cells[I+1,ROW] := TimeToStr(DataField.AsDateTime);
      if Self.Columns[I].ColumnType = ctDateTime then
        AdvGrid.Cells[I+1,ROW] := DateTimeToStr(DataField.AsDateTime);
      if Self.Columns[I].ColumnType = ctBoolean then
        AdvGrid.Cells[I+1,ROW] :=  IfThen(DataField.AsBoolean, 'Ano', 'Ne');
      if Self.Columns[I].ColumnType = ctFloat then
        AdvGrid.Cells[I+1,ROW] := FormatFloat('0.0000', DataField.AsFloat);
      if Self.Columns[I].ColumnType = ctFileSize then
        AdvGrid.Cells[I+1,ROW] := BytesToDisplay(DataField.AsInteger);
      if Self.Columns[I].ColumnType = ctVirtual then
        AdvGrid.Cells[I+1,ROW] := RecordValue;
    end;

    Inc(ROW);
    Self.Query.Next;
  end;

  Debugger.Point('AfterStringGridFillCols');

  // set record count to fit grid rows
  if ROW <> 1 then
    AdvGrid.RowCount := ROW
  else
    AdvGrid.RowCount := ROW+1;

  // callback after reload
  if Assigned(OnAfterReloadGrid) then
    DataGridAfterReloadGrid(Self.Query);

  // grid end update
  AdvGrid.EndUpdate;

  // enable adv grid
  AdvGrid.Enabled := True;

  // enable controls dataset
  Self.Query.EnableControls;

  // Debugger point STOP
  Debugger.Stop('ReloadGrid');

  // show on label time of load
  PageInfo.Caption := PageInfo.Caption + ' (' + IntToStr(GetTickCount - TimerStart) + 'ms)';
end;

procedure TDataGrid.ColumnsControlCheckShow(Sender: TObject);
var
  I: Integer;
  IniFile: TIniFile;
begin
  IniFile := TIniFile.Create(ExtractFilePath(Application.ExeName) + 'datagrid.ini');

  for I := 0 to ColumnsCheckList.Items.Count - 1 do
  begin
    if ColumnsCheckList.Checked[I] then
    begin
      AdvGrid.UnHideColumn(I+1);
      IniFile.WriteBool(Parent.Name, Self.Columns[I].GetKey, True);
    end
    else
    begin
      AdvGrid.HideColumn(I+1);
      IniFile.WriteBool(Parent.Name, Self.Columns[I].GetKey, False);
    end;
  end;

  IniFile.Free;
end;

procedure TDataGrid.CreateComponentColumnsControl(Parent: TWinControl; Panel: TPanel);
var
  I: Integer;
  Column: TDataGridColumn;
  IniFile: TIniFile;
begin
  ColumnsCheckList := TCheckListEdit.Create(Parent);
  ColumnsCheckList.Parent := FilterPanel;
  ColumnsCheckList.Align := alRight;
  ColumnsCheckList.AlignWithMargins := True;
  ColumnsCheckList.Margins.Top := 6;
  ColumnsCheckList.Margins.Bottom := 7;
  ColumnsCheckList.OnChange := ColumnsControlCheckShow;

  // load stored visibled columns
  IniFile := TIniFile.Create(ExtractFilePath(Application.ExeName) + 'datagrid.ini');

  // fill combobox
  ColumnsCheckList.Items.BeginUpdate;
  ColumnsCheckList.Items.Clear;
  for I := Low(Self.Columns) to High(Self.Columns) do
  begin
    Column := Self.Columns[I];
    ColumnsCheckList.Items.Add(Column.Title);

    if (Column._AHidden) and (IniFile.ReadBool(Parent.Name, Column.GetKey, False) = False) then
      ColumnsCheckList.Checked[I] := False
    else
      ColumnsCheckList.Checked[I] := True;
  end;
  ColumnsCheckList.Items.EndUpdate;

  IniFile.Free;
end;

procedure TDataGrid.LoadSettingsColsHide;
var
  I: Integer;
  Column: TDataGridColumn;
  IniFile: TIniFile;
  ColumnsShowHide: array of Boolean;
begin
  IniFile := TIniFile.Create(ExtractFilePath(Application.ExeName) + 'datagrid.ini');

  SetLength(ColumnsShowHide, Length(Self.Columns));

  ColumnsCheckList.Items.BeginUpdate;
  for I := Low(Self.Columns) to High(Self.Columns) do
  begin
    Column := Self.Columns[I];
    if IniFile.ReadBool(Parent.Name, Column.GetKey, True) = False then
      ColumnsShowHide[I] := False
    else
      ColumnsShowHide[I] := True;
  end;

  for I := Low(Self.Columns) to High(Self.Columns) do
    ColumnsCheckList.Checked[I] := ColumnsShowHide[I];

  ColumnsCheckList.Items.EndUpdate;
end;

procedure TDataGrid.CreateComponentSorting(Parent: TWinControl; Panel: TPanel);
var
  I: Integer;
  Column: TDataGridColumn;
  SortingColumns: TDataGridSortingColumns;
begin
  if IsSortable then
  begin
    SortingColumns := GetSortingColumns;
    with TComboBox.Create(Parent) do
    begin
      Parent := Panel;
      Name := 'SortingType';
      Align := alRight;
      AlignWithMargins := True;
      Margins.Top := 6;
      Style := csOwnerDrawFixed;
      Items.BeginUpdate;
      Items.Add('Vzestupnì');
      Items.Add('Sestupnì');
      Items.EndUpdate;
      Width := 75;
      OnChange := ReloadGrid;

      if Self._AQuerySortingAscDESC <> '' then
      begin
        if UpperCase(Self._AQuerySortingAscDESC) = 'DESC' then
          ItemIndex := 1
        else
          ItemIndex := 0;
      end
      else
      begin
        ItemIndex := 0;
      end;
    end;
    with TComboBox.Create(Parent) do
    begin
      Parent := Panel;
      Name := 'SortingColumn';
      Align := alRight;
      AlignWithMargins := True;
      Margins.Top := 6;
      Style := csOwnerDrawFixed;
      Items.BeginUpdate;

      for I := Low(SortingColumns) to High(SortingColumns) do
        Items.AddObject(SortingColumns[I].Title, TObject(SortingColumns[I].Key));

      Items.EndUpdate;
      OnChange := ReloadGrid;
      ItemIndex := 0;
      if Self._AQuerySorting <> '' then
        for I := Low(SortingColumns) to High(SortingColumns) do
          if SortingColumns[I].Key = Self._AQuerySorting then
            ItemIndex := I;

    end;
    with TLabel.Create(Parent) do
    begin
      Parent := Panel;
      Align := alRight;
      AlignWithMargins := True;
      Caption := 'Øazení:';
      Margins.Left := 5;
      Margins.Top := 10;
      Font.Style := [fsBold];
    end;

  end;
end;

procedure TDataGrid.CreateComponentFilters(Parent: TWinControl; BarPanel: TPanel);
var
  I: Integer;
  Filter: TDataGridFilter;
  CustomQuery: TFDQuery;
  SQL: string;
begin
  if Length(Self.Filters) > 0 then
  begin
    for I := Low(Self.Filters) to High(Self.Filters) do
    begin
      Filter := Self.Filters[I];

      // create label
      if Filter.FilterShowLabel then
      begin
        with TLabel.Create(Parent) do
        begin
          Parent := BarPanel;
          Caption := Filter.Title;
          Left := 900;
          Align := alLeft;
          Font.Style := [fsBold];
          Margins.Top := 10;
          Margins.Bottom := 10;
          AlignWithMargins := True;
        end;
      end;

      // type text
      if Filter.FilterType = TDataGridFilterType.ftText then
      begin
        with TEdit.Create(Parent) do
        begin
          Parent := BarPanel;
          Name := Filter.Key;
          Text := '';
          Left := 1000;
          Align := alLeft;
          Margins.Top := 7;
          Margins.Bottom := 6;
          AlignWithMargins := True;
          Width := 100;
          OnChange := OnChangeFilter;
        end;
      end;

      // type select
      if Filter.FilterType = TDataGridFilterType.ftSelect then
      begin
        with TComboBox.Create(Parent) do
        begin
          Parent := BarPanel;
          Name := Filter.Key;
          Left := 1000;
          Align := alLeft;
          Margins.Top := 7;
          Margins.Bottom := 6;
          AlignWithMargins := True;
          Width := 100;
          Style := csOwnerDrawFixed;
          OnChange := OnChangeFilter;
          Items.BeginUpdate;
          Items.AddObject('-- nevybráno --', TObject(-1));

          if (Filter._APairTableName <> '') and (Filter._APairColumnIndex <> '') and (Filter._APairColumnTitle <> '') then
          begin
            SQL := 'SELECT ' + Filter._APairColumnIndex + ',' + Filter._APairColumnTitle + ' FROM ' + Filter._APairTableName;
            if Filter._AQueryWhere <> '' then
              SQL := SQL + ' WHERE ' + Filter._AQueryWhere;
            CustomQuery := DatabaseModule.SetQuery(SQL);
            while not CustomQuery.Eof do
            begin
              Items.AddObject(CustomQuery.FieldByName(Filter._APairColumnTitle).AsString, TObject(CustomQuery.FieldByName(Filter._APairColumnIndex).AsInteger));
              CustomQuery.Next;
            end;
            CustomQuery.Free;
          end
          else
            raise Exception.Create('DataGrid: Please set pairs for filter of type select !');

          Items.EndUpdate;
          ItemIndex := 0;
        end;
      end;

      // type date
      if (Filter.FilterType = TDataGridFilterType.ftDate) or (Filter.FilterType = TDataGridFilterType.ftDateTime) then
      begin
        with TAdvDateTimePicker.Create(Parent) do
        begin
          Parent := BarPanel;
          Name := Filter.Key;
          Left := 1000;
          Align := alLeft;
          Margins.Top := 7;
          Margins.Bottom := 6;
          AlignWithMargins := True;
          Width := 100;
          OnChange := OnChangeFilter;
          if Filter.FilterType = TDataGridFilterType.ftDate then
            Kind := dkDate;
          if Filter.FilterType = TDataGridFilterType.ftDateTime then
          begin
            Kind := dkDateTime;
            Width := Width + 80;
          end;
          ShowCheckbox := True;
          Checked := False;
        end;
      end;

      // type checkbox
      if (Filter.FilterType = TDataGridFilterType.ftCheckBox) then
      begin
        with TCheckBox.Create(Parent) do
        begin
          Parent := BarPanel;
          Name := Filter.Key;
          Caption := '';
          Left := 1000;
          Align := alLeft;
          Margins.Top := 7;
          Margins.Bottom := 6;
          AlignWithMargins := True;
          Width := 14;
          OnClick := OnChangeFilter;
        end;
      end;

      // end foreach
    end;
  end;
end;

procedure TDataGrid.OnChangeFilter(Sender: TObject);
begin
  ReloadGrid(Sender);
  Paginator.SetTotalItems(Self.Query.RecordCount);
end;

function TDataGrid.GetSortingColumns: TDataGridSortingColumns;
var
  I,Len: Integer;
begin
  SetLength(Result, 0);
  for I := Low(Self.Columns) to High(Self.Columns) do
  begin
    if Self.Columns[I]._ASortable then
    begin
      Len := Length(Result);
      SetLength(Result, Len+1);
      Result[Len].Key := Self.Columns[I].GetKey;
      Result[Len].Title := Self.Columns[I].GetTitle;
    end;
  end;
end;

procedure TDataGrid.OnCloseReloadGrid(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
//  TForm(Sender).Free;
  ReloadGrid(Sender);
end;

procedure TDataGrid.QueryFilterRecord(DataSet: TDataSet; var Accept: Boolean);
var
  FilterDateTimePicker: TAdvDateTimePicker;
  FilterText: TEdit;
  FilterSelect: TComboBox;
  FilterSelectValue: Integer;
  FilterCheckbox: TCheckBox;
  Filter: TDataGridFilter;
  FilterDefault: TDataGridFilterDefault;
  DateTimeValue: TDateTime;
  I: Integer;
//  ColumnFilterKey: string;
begin
  Accept := True;

  for I := Low(Self.Filters) to High(Self.Filters) do
  begin
    Filter := Self.Filters[I];

    // filtrovani dle textu
    if Filter.FilterType = ftText then
    begin
    { TODO -oxnuke -c : zde prosím dodìlat podmínky dle nastavení condition 27.03.2019 9:04:12 }
      FilterText := Self.Parent.FindComponent(Filter.Key) as TEdit;
      Filter.FilterValueString := FilterText.Text;
      if (Length(FilterText.Text) > 0) and not (AnsiContainsText(DataSet.FieldByName(Filter.Key).AsString, FilterText.Text)) then
      begin
        Accept := False;
        Break;
      end;
    end;

    // filtrování dle checkboxu
    if Filter.FilterType = ftCheckBox then
    begin
      FilterCheckbox := TCheckBox(Self.Parent.FindComponent(Filter.Key));
      if Assigned(FilterCheckbox) and (FilterCheckbox.Checked) then
        if DataSet.FieldByName(Filter.Key).AsBoolean <> True then
        begin
          Accept := False;
          Break;
        end;
    end;

    // filtrovani dle vyberu select
    if Filter.FilterType = ftSelect then
    begin
      FilterSelect := Self.Parent.FindComponent(Filter.Key) as TComboBox;
      Filter.FilterValueInteger := -1;
      if (Assigned(FilterSelect)) and (FilterSelect.ItemIndex <> -1) then
      begin
        FilterSelectValue := Integer(FilterSelect.Items.Objects[FilterSelect.ItemIndex]);
        Filter.FilterValueInteger := FilterSelectValue;
        if (FilterSelectValue > 0) and (DataSet.FieldByName(Filter._APairColumnIndex).AsInteger <> FilterSelectValue) then
        begin
          Accept := False;
          Break;
        end;
      end;
    end;

    // filtrovani dle datumu nebo i casu
    if (Filter.FilterType = ftDate) or (Filter.FilterType = ftDateTime) then
    begin
      FilterDateTimePicker := Self.Parent.FindComponent(Filter.Key) as TAdvDateTimePicker;
      if FilterDateTimePicker is TAdvDateTimePicker then
      begin
        Filter.FilterValueDateTime := FilterDateTimePicker.DateTime;
        if FilterDateTimePicker.Checked then
        begin
          if Filter.FilterType = ftDate then
          begin
            DateTimeValue := DataSet.FieldByName(Filter.Key).AsDateTime;
            if Filter.FilterCondition = fcEqual then
              if DateTimeValue <> FilterDateTimePicker.DateTime then
              begin
                Accept := False;
                Break;
              end;
            if Filter.FilterCondition = fcNotEqual then
              if DateTimeValue = FilterDateTimePicker.DateTime then
              begin
                Accept := False;
                Break;
              end;
            if Filter.FilterCondition = fcLowThen then
            begin
              if DateTimeValue > FilterDateTimePicker.DateTime then
              begin
                Accept := False;
                Break;
              end;
            end;
            if Filter.FilterCondition = fcHighThen then
            begin
              ReplaceTime(DateTimeValue, EncodeTime(23, 59, 59, 0));  // fix for only date
              if DateTimeValue < FilterDateTimePicker.DateTime then
              begin
                Accept := False;
                Break;
              end;
            end;
          end;
          if Filter.FilterType = ftDateTime then
          begin
            if Filter.FilterCondition = fcEqual then
              if DataSet.FieldByName(Filter.Key).AsDateTime <> FilterDateTimePicker.DateTime then
              begin
                Accept := False;
                Break;
              end;
            if Filter.FilterCondition = fcNotEqual then
              if DataSet.FieldByName(Filter.Key).AsDateTime = FilterDateTimePicker.DateTime then
              begin
                Accept := False;
                Break;
              end;
            if Filter.FilterCondition = fcLowThen then
              if DataSet.FieldByName(Filter.Key).AsDateTime > FilterDateTimePicker.DateTime then
              begin
                Accept := False;
                Break;
              end;
            if Filter.FilterCondition = fcHighThen then
              if DataSet.FieldByName(Filter.Key).AsDateTime < FilterDateTimePicker.DateTime then
              begin
                Accept := False;
                Break;
              end;
          end;
        end;
      end;
    end;
  end;

  for I := Low(Self.FilterDefaults) to High(Self.FilterDefaults) do
  begin
    FilterDefault := Self.FilterDefaults[I];
    if DataSet.FieldByName(FilterDefault.Name).AsString <> FilterDefault.Value then
    begin
      Accept := False;
      Break;
    end;
  end;

  if Assigned(OnDataGridOnFilterRecords) then
    OnDataGridOnFilterRecords(DataSet, Accept);
end;

procedure TDataGrid.Sorting(BySort: string; AscDesc: string);
begin
  Self._AQuerySorting := BySort;
  Self._AQuerySortingAscDESC := AscDesc;
end;

procedure TDataGrid.AddFilterDefault(ColumnName: string; ColumnValue: string);
var
  Len: Integer;
begin
  Len := Length(Self.FilterDefaults);
  SetLength(Self.FilterDefaults, Len+1);
  Self.FilterDefaults[Len].Name := ColumnName;
  Self.FilterDefaults[Len].Value := ColumnValue;

  if Self.Query.OpenOrExecute then
  begin
    ReloadGrid(Self);
    Paginator.SetTotalItems(Self.Query.RecordCount);
  end;
end;

procedure TDataGrid.SetCreateForm(Form: TBaseFormClass);
begin
  Self._AFormCreate := Form;
end;

procedure TDataGrid.OnClickButtonCreateForm(Sender: TObject);
var
  ChildWindow: TBaseForm;
begin
  if not Self._AFormCreate.InheritsFrom(TBaseForm) then
    raise Exception.Create('Invalid FormClass - must be a descendant of TBaseForm!');

  ChildWindow := Self._AFormCreate.Create(Self.Parent);
  ChildWindow.Show;
  ChildWindow.OnClose := Self.OnCloseReloadGrid;
  AddChildTab(ChildWindow);
end;

procedure TDataGrid.OnDblClickGridCreateForm(IndexKey: Integer);
var
  ChildWindow: TBaseForm;
begin
  if IndexKey <> -1 then
  begin
    if not Self._AFormCreate.InheritsFrom(TBaseForm) then
      raise Exception.Create('Invalid FormClass - must be a descendant of TBaseForm!');

    ChildWindow := Self._AFormCreate.Create(Self.Parent);
    ChildWindow.Load(IndexKey);
    ChildWindow.Show;
    ChildWindow.OnClose := Self.OnCloseReloadGrid;
    AddChildTab(ChildWindow);
  end;
end;

function TDataGrid.BytesToDisplay(const num: Int64): string;
var
  A1, A2, A3: double;
begin
  A1 := num / 1024;
  A2 := A1 / 1024;
  A3 := A2 / 1024;
  if A1 < 1 then Result := floattostrf(num, ffNumber, 15, 0) + ' bytes'
  else if A1 < 10 then Result := floattostrf(A1, ffNumber, 15, 2) + ' KB'
  else if A1 < 100 then Result := floattostrf(A1, ffNumber, 15, 1) + ' KB'
  else if A2 < 1 then Result := floattostrf(A1, ffNumber, 15, 0) + ' KB'
  else if A2 < 10 then Result := floattostrf(A2, ffNumber, 15, 2) + ' MB'
  else if A2 < 100 then Result := floattostrf(A2, ffNumber, 15, 1) + ' MB'
  else if A3 < 1 then Result := floattostrf(A2, ffNumber, 15, 0) + ' MB'
  else if A3 < 10 then Result := floattostrf(A3, ffNumber, 15, 2) + ' GB'
  else if A3 < 100 then Result := floattostrf(A3, ffNumber, 15, 1) + ' GB'
  else Result := floattostrf(A3, ffNumber, 15, 0) + ' GB';
  Result := Result + ' (' + floattostrf(num, ffNumber, 15, 0) + ' bytes)';
end;

function TDataGrid.AddColumn(Key: string; Title: string; ColumnType: TColumnType): TDataGridColumn;
var
  Column: TDataGridColumn;
begin
  Column := TDataGridColumn.Create;
  Column.Index := Length(Self.Columns);
  Column.Key := Key;
  Column.Title := Title;
  Column.ColumnType := ColumnType;

  SetLength(Self.Columns, Column.Index + 1);
  Self.Columns[Column.Index] := Column;
  Result := Self.Columns[Column.Index];
end;

function TDataGrid.AddFilter(Key, Title: string; FilterType:
    TDataGridFilterType; const FilterCondition: TDataGridFilterCondition =
    fcEqual; const ShowLabel: Boolean = True): TDataGridFilter;
begin
  Result := TDataGridFilter.Create;
  Result.Index := Length(Self.Filters);
  Result.Key := Key;
  Result.Title := Title;
  Result.FilterType := FilterType;
  Result.FilterCondition := FilterCondition;
  Result.FilterShowLabel := ShowLabel;

  SetLength(Self.Filters, Result.Index + 1);
  Self.Filters[Result.Index] := Result;
  Result := Self.Filters[Result.Index];
end;

function TDataGrid.GetColumn(Key: string): TDataGridColumn;
var
  I: Integer;
begin
  Result := nil;
  for I := Low(Self.Columns) to High(Self.Columns) do
  begin
    if Self.Columns[I].Key = Key then
      Result := Self.Columns[I];
  end;

  if not Assigned(Result) then
    raise Exception.Create('Column "' + Key + '" not found !');
end;

function TDataGrid.GetFilter(Key: string): TDataGridFilter;
var
  I: Integer;
begin
  Result := nil;

  for I := Low(Self.Filters) to High(Self.Filters) do
    if Self.Filters[I].Key = Key then
      Result := Self.Filters[I];

  if not Assigned(Result) then
    raise Exception.Create('Filter "' + Key + '" not found !');
end;

end.
