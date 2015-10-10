unit Main;

interface

uses
  Windows,
  SysUtils,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  ExtCtrls,
  ComCtrls,
  Menus,
  StdCtrls,
  Math, JMC_ControlGrid;

type

  TFormMain = class(TForm)
    ImageViewport: TImage;
    Panel1: TPanel;
    MainMenu: TMainMenu;
    MenuFile: TMenuItem;
    MenuView: TMenuItem;
    MenuOptions: TMenuItem;
    MenuItemShowAxes: TMenuItem;
    MenuItemShowGrid: TMenuItem;
    MenuItemExit: TMenuItem;
    MenuItemReset: TMenuItem;
    PanelSelectedItemDetails: TPanel;
    Splitter1: TSplitter;
    ListBoxActions: TListBox;
    ListBoxAvailableItems: TListBox;
    Splitter2: TSplitter;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure ImageViewportMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ImageViewportMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ImageViewportMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure MenuItemExitClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure MenuItemShowAxesClick(Sender: TObject);
    procedure MenuItemShowGridClick(Sender: TObject);
    procedure MenuItemResetClick(Sender: TObject);
  private
    FMouseDownCoordX: Double;
    FMouseDownCoordY: Double;
    FMouseDownCoord: Windows.TPoint;
    FImageBuffer: Graphics.TBitmap;
    FViewportMinX: Double;
    FViewportMaxX: Double;
    FViewportMinY: Double;
    FViewportMaxY: Double;
    FViewportRangeX: Double;
    FViewportRangeY: Double;
    FPixelsPerUnit: Double;
    FZoomFactor: Double;
    FMinPixelsPerUnit: Double;
    FMaxPixelsPerUnit: Double;
    FSnapDistance: Double;
  public
    procedure RepaintViewport;
    procedure ConvertPixelToNodeCoord(const PixelCoord: Windows.TPoint; var NodeX, NodeY: Double);
    function ConvertNodeToPixelCoord(const NodeX, NodeY: Double): Windows.TPoint;
    procedure ResetViewport;
  end;

var
  FormMain: TFormMain;

implementation

{$R *.dfm}

{ TFormMain }

procedure TFormMain.RepaintViewport;
var
  P1: Windows.TPoint;
  P2: Windows.TPoint;
  i: Integer;
  n: Integer;
begin
  FImageBuffer.Canvas.Brush.Color := clBlack;
  FImageBuffer.Canvas.FillRect(ImageViewport.ClientRect);
  if MenuItemShowGrid.Checked then
  begin
    FImageBuffer.Canvas.Pen.Color := Windows.RGB(10, 10, 10);
    for i := 0 to Round(FViewportRangeX / FSnapDistance) do
    begin
      P1 := ConvertNodeToPixelCoord((Round(FViewportMinX / FSnapDistance) + i) * FSnapDistance, 0);
      FImageBuffer.Canvas.MoveTo(P1.X, 0);
      FImageBuffer.Canvas.LineTo(P1.X, FImageBuffer.Height);
    end;
    for i := 0 to Round(FViewportRangeY / FSnapDistance) do
    begin
      P1 := ConvertNodeToPixelCoord(0, (Round(FViewportMinY / FSnapDistance) + i) * FSnapDistance);
      FImageBuffer.Canvas.MoveTo(0, P1.Y);
      FImageBuffer.Canvas.LineTo(FImageBuffer.Width, P1.Y);
    end;
  end;
  if MenuItemShowAxes.Checked then
  begin
    FImageBuffer.Canvas.Pen.Color := clGray;
    P1 := ConvertNodeToPixelCoord(0, 0);
    FImageBuffer.Canvas.MoveTo(P1.X, 0);
    FImageBuffer.Canvas.LineTo(P1.X, FImageBuffer.Height);
    FImageBuffer.Canvas.MoveTo(0, P1.Y);
    FImageBuffer.Canvas.LineTo(FImageBuffer.Width, P1.Y);
  end;
  ImageViewport.Canvas.Draw(0, 0, FImageBuffer);
end;

procedure TFormMain.ConvertPixelToNodeCoord(const PixelCoord: Windows.TPoint; var NodeX, NodeY: Double);
begin
  NodeX := PixelCoord.X / FPixelsPerUnit + FViewportMinX;
  NodeY := (FImageBuffer.Height - 1 - PixelCoord.Y) / FPixelsPerUnit + FViewportMinY;
end;

function TFormMain.ConvertNodeToPixelCoord(const NodeX, NodeY: Double): Windows.TPoint;
begin
  Result.X := Round((NodeX - FViewportMinX) * FPixelsPerUnit);
  Result.Y := FImageBuffer.Height - 1 - Round((NodeY - FViewportMinY) * FPixelsPerUnit);
end;

procedure TFormMain.ResetViewport;
begin
  FZoomFactor := 1.1;
  FViewportMinX := 0.0;
  FViewportMaxX := 100.0;
  FViewportMinY := 0.0;
  FViewportRangeX := FViewportMaxX - FViewportMinX;
  FPixelsPerUnit := (FImageBuffer.Width - 1) / FViewportRangeX;
  FViewportMaxY := (FImageBuffer.Height - 1) / FPixelsPerUnit + FViewportMinY;
  FViewportRangeY := FViewportMaxY - FViewportMinY;
  RepaintViewport;
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
  FMouseDownCoordX := 1e12;
  FMouseDownCoordY := 1e12;
  FMouseDownCoord := Classes.Point(MaxInt, MaxInt);
  FImageBuffer := Graphics.TBitmap.Create;
  FImageBuffer.Width := ImageViewport.Width;
  FImageBuffer.Height := ImageViewport.Height;
  ImageViewport.Picture.Bitmap.Width := ImageViewport.Width;
  ImageViewport.Picture.Bitmap.Height := ImageViewport.Height;
  FSnapDistance := 10;
  FMinPixelsPerUnit := 0.1;
  FMaxPixelsPerUnit := 1000;
  ResetViewport;
end;

procedure TFormMain.FormDestroy(Sender: TObject);
begin
  FImageBuffer.Free;
end;

procedure TFormMain.FormMouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
var
  ViewportMousePos: Windows.TPoint;
  ViewportX: Double;
  ViewportY: Double;
  DXL: Double;
  DXR: Double;
  DYT: Double;
  DYB: Double;
  PPU: Double;
begin
  ViewportMousePos := ImageViewport.ScreenToClient(MousePos);
  if (ViewPortMousePos.X >= 0) and (ViewPortMousePos.Y >= 0) and (ViewPortMousePos.X < ImageViewport.Width) and (ViewPortMousePos.Y < ImageViewport.Height) then
  begin
    ConvertPixelToNodeCoord(ViewPortMousePos, ViewportX, ViewportY);
    DXL := FZoomFactor * (ViewPortX - FViewportMinX);
    DXR := FZoomFactor * (FViewportMaxX - ViewPortX);
    DYT := FZoomFactor * (ViewPortY - FViewportMinY);
    DYB := FZoomFactor * (FViewportMaxY - ViewPortY);
    PPU := (FImageBuffer.Width - 1) / ((ViewPortX + DXR) - (ViewPortX - DXL));
    if (PPU < FMinPixelsPerUnit) or (PPU > FMaxPixelsPerUnit) then
      Exit;
    FViewportMinX := ViewPortX - DXL;
    FViewportMaxX := ViewPortX + DXR;
    FViewportMinY := ViewPortY - DYT;
    FViewportMaxY := ViewPortY + DYB;
    FViewportRangeX := FViewportMaxX - FViewportMinX;
    FViewportRangeY := FViewportMaxY - FViewportMinY;
    FPixelsPerUnit := (FImageBuffer.Width - 1) / FViewportRangeX;
    RepaintViewport;
    Handled := True;
    Exit;
  end;
  Handled := False;
end;

procedure TFormMain.FormMouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
var
  ViewportMousePos: Windows.TPoint;
  ViewportX: Double;
  ViewportY: Double;
  DXL: Double;
  DXR: Double;
  DYT: Double;
  DYB: Double;
  PPU: Double;
begin
  ViewportMousePos := ImageViewport.ScreenToClient(MousePos);
  if (ViewPortMousePos.X >= 0) and (ViewPortMousePos.Y >= 0) and (ViewPortMousePos.X < ImageViewport.Width) and (ViewPortMousePos.Y < ImageViewport.Height) then
  begin
    ConvertPixelToNodeCoord(ViewPortMousePos, ViewportX, ViewportY);
    DXL := 1 / FZoomFactor * (ViewPortX - FViewportMinX);
    DXR := 1 / FZoomFactor * (FViewportMaxX - ViewPortX);
    DYT := 1 / FZoomFactor * (ViewPortY - FViewportMinY);
    DYB := 1 / FZoomFactor * (FViewportMaxY - ViewPortY);
    if (DXL > 0) and (DXR > 0) and (DYT > 0) and (DYB > 0) then
    begin
      PPU := (FImageBuffer.Width - 1) / ((ViewPortX + DXR) - (ViewPortX - DXL));
      if (PPU < FMinPixelsPerUnit) or (PPU > FMaxPixelsPerUnit) then
        Exit;
      FViewportMinX := ViewPortX - DXL;
      FViewportMaxX := ViewPortX + DXR;
      FViewportMinY := ViewPortY - DYT;
      FViewportMaxY := ViewPortY + DYB;
      FViewportRangeX := FViewportMaxX - FViewportMinX;
      FViewportRangeY := FViewportMaxY - FViewportMinY;
      FPixelsPerUnit := (FImageBuffer.Width - 1) / FViewportRangeX;
      RepaintViewport;
      Handled := True;
      Exit;
    end;
  end;
  Handled := False;
end;

procedure TFormMain.ImageViewportMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FMouseDownCoord := Classes.Point(X, Y);
  ConvertPixelToNodeCoord(Classes.Point(X, Y), FMouseDownCoordX, FMouseDownCoordY);
  if ssLeft in Shift then
  begin

  end;
  RepaintViewport;
end;

procedure TFormMain.ImageViewportMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FMouseDownCoordX := 1e12;
  FMouseDownCoordY := 1e12;
  FMouseDownCoord := Classes.Point(MaxInt, MaxInt);
end;

procedure TFormMain.ImageViewportMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  pixel_dx: Integer;
  pixel_dy: Integer;
  node_dx: Double;
  node_dy: Double;
  node_x: Double;
  node_y: Double;
  closest_dist: Double;
  dist: Double;
  i: Integer;
begin
  ConvertPixelToNodeCoord(Classes.Point(X, Y), node_x, node_y);
  if (ssRight in Shift) and (FMouseDownCoord.X <> MaxInt) and (FMouseDownCoord.Y <> MaxInt) then
  begin
    pixel_dx := X - FMouseDownCoord.X;
    pixel_dy := Y - FMouseDownCoord.Y;
    node_dx := pixel_dx / FPixelsPerUnit;
    node_dy := pixel_dy / FPixelsPerUnit;
    FViewportMinX := FViewportMinX - node_dx;
    FViewportMaxX := FViewportMaxX - node_dx;
    FViewportMinY := FViewportMinY + node_dy;
    FViewportMaxY := FViewportMaxY + node_dy;
    FViewportRangeX := FViewportMaxX - FViewportMinX;
    FViewportRangeY := FViewportMaxY - FViewportMinY;
    RepaintViewport;
    FMouseDownCoordX := node_x;
    FMouseDownCoordY := node_y;
    FMouseDownCoord := Classes.Point(X, Y);
  end;
end;

procedure TFormMain.MenuItemExitClick(Sender: TObject);
begin
  Close;
end;

procedure TFormMain.FormResize(Sender: TObject);
begin
  if csDestroying in ComponentState then
    Exit;
  if FPixelsPerUnit = 0 then
    Exit;
  FImageBuffer.Width := ImageViewport.Width;
  FImageBuffer.Height := ImageViewport.Height;
  ImageViewport.Picture.Bitmap.Width := ImageViewport.Width;
  ImageViewport.Picture.Bitmap.Height := ImageViewport.Height;
  FViewportMaxX := (FImageBuffer.Width - 1) / FPixelsPerUnit + FViewportMinX;
  FViewportMinY := FViewportMaxY - (FImageBuffer.Height - 1) / FPixelsPerUnit;
  FViewportRangeX := FViewportMaxX - FViewportMinX;
  FViewportRangeY := FViewportMaxY - FViewportMinY;
  RepaintViewport;
end;

procedure TFormMain.MenuItemShowAxesClick(Sender: TObject);
begin
  MenuItemShowAxes.Checked := not MenuItemShowAxes.Checked;
  RepaintViewport;
end;

procedure TFormMain.MenuItemShowGridClick(Sender: TObject);
begin
  MenuItemShowGrid.Checked := not MenuItemShowGrid.Checked;
  RepaintViewport;
end;

procedure TFormMain.MenuItemResetClick(Sender: TObject);
begin
  ResetViewport;
end;

end.
