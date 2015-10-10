object FormMain: TFormMain
  Left = 322
  Top = 179
  Width = 928
  Height = 480
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  Caption = 'Conquest'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnMouseWheelDown = FormMouseWheelDown
  OnMouseWheelUp = FormMouseWheelUp
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object ImageViewport: TImage
    Left = 215
    Top = 0
    Width = 705
    Height = 434
    Align = alClient
    OnMouseDown = ImageViewportMouseDown
    OnMouseMove = ImageViewportMouseMove
    OnMouseUp = ImageViewportMouseUp
  end
  object Splitter1: TSplitter
    Left = 212
    Top = 0
    Height = 434
    AutoSnap = False
    MinSize = 100
    OnMoved = FormResize
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 212
    Height = 434
    Align = alLeft
    BevelOuter = bvNone
    TabOrder = 0
    object Splitter2: TSplitter
      Left = 0
      Top = 141
      Width = 212
      Height = 3
      Cursor = crVSplit
      Align = alTop
      AutoSnap = False
      MinSize = 50
    end
    object PanelSelectedItemDetails: TPanel
      Left = 0
      Top = 0
      Width = 212
      Height = 67
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 0
    end
    object ListBoxActions: TListBox
      Left = 0
      Top = 67
      Width = 212
      Height = 74
      Align = alTop
      ItemHeight = 13
      TabOrder = 1
    end
    object ListBoxAvailableItems: TListBox
      Left = 0
      Top = 144
      Width = 212
      Height = 290
      Align = alClient
      ItemHeight = 13
      TabOrder = 2
    end
  end
  object MainMenu: TMainMenu
    Left = 308
    Top = 50
    object MenuFile: TMenuItem
      Caption = '&File'
      object MenuItemExit: TMenuItem
        Caption = 'E&xit'
        OnClick = MenuItemExitClick
      end
    end
    object MenuView: TMenuItem
      Caption = '&View'
      object MenuItemShowAxes: TMenuItem
        Caption = 'Show &Axes'
        Checked = True
        OnClick = MenuItemShowAxesClick
      end
      object MenuItemShowGrid: TMenuItem
        Caption = 'Show &Grid'
        Checked = True
        OnClick = MenuItemShowGridClick
      end
      object MenuItemReset: TMenuItem
        Caption = '&Reset'
        OnClick = MenuItemResetClick
      end
    end
    object MenuOptions: TMenuItem
      Caption = '&Options'
    end
  end
end
