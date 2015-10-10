unit GameClasses;

interface

uses
  Windows,
  SysUtils,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  JMC_Strings,
  JMC_Parts;

type

  TGameResource = class;
  TGameResourceArray = class;
  TGameBuildingDefinition = class;
  TGameBuildingDefinitionArray = class;
  TGameBuilding = class;
  TGameBuildingArray = class;
  TGamePlayer = class;
  TGamePlayerArray = class;
  TGame = class;

  TGameResource = class(TObject)
  private
    FDescription: string;
    FQuantity: Double;
  public
    property Description: string read FDescription write FDescription;
    property Quantity: Double read FQuantity write FQuantity;
  end;

  TGameResourceArray = class(TObject)
  private
    FItems: Classes.TList;
  private
    function GetCount: Integer;
    function GetItem(const Index: Integer): TGameResource;
  public
    constructor Create;
    destructor Destroy; override;
  public
    procedure Add(const Item: TGameResource); overload;
    procedure Add(const Item: string); overload;
    procedure Add(const Description: string; const Quantity: Double); overload;
    procedure AddMultiple(const Items: string);
    procedure Clear;
    function IndexOf(const Description: string): Integer;
  public
    property Count: Integer read GetCount;
    property Items[const Index: Integer]: TGameResource read GetItem; default;
  end;

  TGameBuildingDefinition = class(TObject)
  private
    FDescription: string;
    FAvailability: Integer;
    FConstruct: TGameResourceArray;
    FRecycle: TGameResourceArray;
    FRecyclePermitted: Boolean;
    FProductionRate: TGameResourceArray;
    FConsumptionRate: TGameResourceArray;
    FCapacity: TGameResourceArray;
    FRequires: TGameBuildingArray;
    FOwner: TGameBuildingDefinitionArray;
  public
    constructor Create(const Owner: TGameBuildingDefinitionArray);
    destructor Destroy; override;
  public
    property Description: string read FDescription write FDescription;
    property Availability: Integer read FAvailability write FAvailability;
    property Construct: TGameResourceArray read FConstruct;
    property Recycle: TGameResourceArray read FRecycle;
    property RecyclePermitted: Boolean read FRecyclePermitted write FRecyclePermitted;
    property ProductionRate: TGameResourceArray read FProductionRate;
    property ConsumptionRate: TGameResourceArray read FConsumptionRate;
    property Capacity: TGameResourceArray read FCapacity;
    property Requires: TGameBuildingArray read FRequires;
    property Owner: TGameBuildingDefinitionArray read FOwner;
  end;

  TGameBuildingDefinitionArray = class(TObject)
  private
    FItems: Classes.TList;
    FOwner: TGame;
  private
    function GetCount: Integer;
    function GetItem(const Index: Integer): TGameBuildingDefinition;
  public
    constructor Create(const Owner: TGame);
    destructor Destroy; override;
  public
    procedure Add(const Item: TGameBuildingDefinition); overload;
    procedure Add(const Definitions: JMC_Strings.TStoredIniFile; const Description: string); overload;
    procedure Clear;
    function IndexOf(const Description: string): Integer;
  public
    property Owner: TGame read FOwner;
    property Count: Integer read GetCount;
    property Items[const Index: Integer]: TGameBuildingDefinition read GetItem; default;
  end;

  TGameBuilding = class(TObject)
  private
    FDefinition: TGameBuildingDefinition;
    FQuantity: Integer;
    FStore: TGameResourceArray;
  public
    constructor Create;
    destructor Destroy; override;
  public
    property Definition: TGameBuildingDefinition read FDefinition write FDefinition;
    property Quantity: Integer read FQuantity write FQuantity;
    property Store: TGameResourceArray read FStore;
  end;

  TGameBuildingArray = class(TObject)
  private
    FItems: Classes.TList;
    FDefinitions: TGameBuildingDefinitionArray;
  private
    function GetCount: Integer;
    function GetItem(const Index: Integer): TGameBuilding;
  public
    constructor Create(const Definitions: TGameBuildingDefinitionArray);
    destructor Destroy; override;
  public
    procedure Add(const Item: TGameBuilding); overload;
    procedure Add(const Item: string); overload;
    procedure AddMultiple(const Items: string);
    procedure AddResource(const Item: string);
    procedure Clear;
    procedure Increment;
    function IndexOf(const Description: string): Integer;
    function Quantity(const Resource: string): Double;
    function Capacity(const Resource: string): Double;
    procedure Tick;
  public
    property Count: Integer read GetCount;
    property Items[const Index: Integer]: TGameBuilding read GetItem; default;
  end;

  TGamePlayer = class(TObject)
  private
    FName: string;
    FBuildings: TGameBuildingArray;
    FDefinitions: TGameBuildingDefinitionArray;
  public
    constructor Create(const Definitions: TGameBuildingDefinitionArray);
    destructor Destroy; override;
  public
    property Name: string read FName write FName;
    property Buildings: TGameBuildingArray read FBuildings;
  end;

  TGamePlayerArray = class(TObject)
  private
    FItems: Classes.TList;
  private
    function GetCount: Integer;
    function GetItem(const Index: Integer): TGamePlayer;
  public
    constructor Create;
    destructor Destroy; override;
  public
    procedure Add(const Item: TGamePlayer);
    procedure Clear;
  public
    property Count: Integer read GetCount;
    property Items[const Index: Integer]: TGamePlayer read GetItem; default;
  end;

  TGame = class(TObject)
  private
    FBuildingDefinitions: TGameBuildingDefinitionArray;
    FPlayers: TGamePlayerArray;
    FInterval: Integer;
  public
    constructor Create;
    destructor Destroy; override;
  public
    function LoadBuildingDefinitions(const FileName: string): Boolean;
    function LoadPlayerDefaults(const FileName: string): Boolean;
    procedure Tick;
  public
    property BuildingDefinitions: TGameBuildingDefinitionArray read FBuildingDefinitions;
    property Players: TGamePlayerArray read FPlayers;
    property Interval: Integer read FInterval write FInterval;
  end;

implementation

{ TGameResourceArray }

procedure TGameResourceArray.Add(const Item: TGameResource);
begin
  FItems.Add(Item);
end;

procedure TGameResourceArray.Add(const Item: string);
var
  m: Double;
  S: string;
begin
  S := JMC_Parts.ReadPart(Item, 1, ',');
  if SysUtils.UpperCase(S) = 'INFINITE' then
    m := -1.0
  else
    try
      m := SysUtils.StrToFloat(S);
    except
      m := 0.0;
    end;
  Add(JMC_Parts.ReadPart(Item, 2, ','), m);
end;

procedure TGameResourceArray.Add(const Description: string; const Quantity: Double);
var
  R: TGameResource;
begin
  R := TGameResource.Create;
  R.Description := Description;
  R.Quantity := Quantity;
  Add(R);
end;

procedure TGameResourceArray.AddMultiple(const Items: string);
var
  i: Integer;
  n: Integer;
begin
  n := JMC_Parts.CountParts(Items, '|');
  for i := 1 to n do
    Add(JMC_Parts.ReadPart(Items, i, '|'));
end;

procedure TGameResourceArray.Clear;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    Items[i].Free;
  FItems.Clear;
end;

constructor TGameResourceArray.Create;
begin
  FItems := Classes.TList.Create;
end;

destructor TGameResourceArray.Destroy;
begin
  Clear;
  FItems.Free;
  inherited;
end;

function TGameResourceArray.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TGameResourceArray.GetItem(const Index: Integer): TGameResource;
begin
  Result := FItems[Index];
end;

function TGameResourceArray.IndexOf(const Description: string): Integer;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    if Items[i].Description = Description then
    begin
      Result := i;
      Exit;
    end;
  Result := -1;
end;

{ TGameBuildingDefinition }

constructor TGameBuildingDefinition.Create(const Owner: TGameBuildingDefinitionArray);
begin
  FOwner := Owner;
  FConstruct := TGameResourceArray.Create;
  FRecycle := TGameResourceArray.Create;
  FProductionRate := TGameResourceArray.Create;
  FConsumptionRate := TGameResourceArray.Create;
  FCapacity := TGameResourceArray.Create;
  FRequires := TGameBuildingArray.Create(Owner);
end;

destructor TGameBuildingDefinition.Destroy;
begin
  FConstruct.Free;
  FRecycle.Free;
  FProductionRate.Free;
  FConsumptionRate.Free;
  FCapacity.Free;
  FRequires.Free;
  inherited;
end;

{ TGameBuildingDefinitionArray }

procedure TGameBuildingDefinitionArray.Add(const Item: TGameBuildingDefinition);
begin
  FItems.Add(Item);
end;

procedure TGameBuildingDefinitionArray.Add(const Definitions: JMC_Strings.TStoredIniFile; const Description: string);
var
  S: string;
  B: TGameBuildingDefinition;
begin
  B := TGameBuildingDefinition.Create(Self);
  B.Description := Description;
  B.Construct.AddMultiple(Definitions.ReadValue(Description, 'Construct'));
  B.Recycle.AddMultiple(Definitions.ReadValue(Description, 'Recycle'));
  B.ProductionRate.AddMultiple(Definitions.ReadValue(Description, 'ProductionRate'));
  B.ConsumptionRate.AddMultiple(Definitions.ReadValue(Description, 'ConsumptionRate'));
  B.Capacity.AddMultiple(Definitions.ReadValue(Description, 'Capacity'));
  B.Requires.AddMultiple(Definitions.ReadValue(Description, 'Requires'));
  S := Definitions.ReadValue(Description, 'Availability');
  if SysUtils.UpperCase(S) = 'INFINITE' then
    B.Availability := -1
  else
    try
      B.Availability := SysUtils.StrToInt(S);
    except
      B.Availability := 0;
    end;
  B.RecyclePermitted := SysUtils.UpperCase(Definitions.ReadValue(Description, 'RecyclePermitted')) = 'YES';
  Add(B);
end;

procedure TGameBuildingDefinitionArray.Clear;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    Items[i].Free;
  FItems.Clear;
end;

constructor TGameBuildingDefinitionArray.Create(const Owner: TGame);
begin
  FItems := Classes.TList.Create;
  FOwner := Owner;
end;

destructor TGameBuildingDefinitionArray.Destroy;
begin
  Clear;
  FItems.Free;
  inherited;
end;

function TGameBuildingDefinitionArray.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TGameBuildingDefinitionArray.GetItem(const Index: Integer): TGameBuildingDefinition;
begin
  Result := FItems[Index];
end;

function TGameBuildingDefinitionArray.IndexOf(const Description: string): Integer;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    if Items[i].Description = Description then
    begin
      Result := i;
      Exit;
    end;
  Result := -1;
end;

{ TGameBuilding }

constructor TGameBuilding.Create;
begin
  FStore := TGameResourceArray.Create;
end;

destructor TGameBuilding.Destroy;
begin
  FStore.Free;
  inherited;
end;

{ TGameBuildingArray }

procedure TGameBuildingArray.Add(const Item: TGameBuilding);
begin
  FItems.Add(Item);
end;

procedure TGameBuildingArray.Add(const Item: string);
var
  B: TGameBuilding;
  i: Integer;
begin
  B := TGameBuilding.Create;
  i := FDefinitions.IndexOf(JMC_Parts.ReadPart(Item, 2, ','));
  if i < 0 then
    B.Definition := nil
  else
    B.Definition := FDefinitions[i];
  try
    B.Quantity := SysUtils.StrToInt(JMC_Parts.ReadPart(Item, 1, ','));
  except
    B.Quantity := 0;
  end;
  if B.Definition <> nil then
    Add(B)
  else
    B.Free;
end;

procedure TGameBuildingArray.AddMultiple(const Items: string);
var
  i: Integer;
  n: Integer;
begin
  n := JMC_Parts.CountParts(Items, '|');
  for i := 1 to n do
    Add(JMC_Parts.ReadPart(Items, i, '|'));
end;

procedure TGameBuildingArray.AddResource(const Item: string);
var
  Desc: string;
  Qty: Double;
  Cap: Double;
  i: Integer;
  j1: Integer;
  j2: Integer;
  c: Double;
  x: Double;
begin
  Desc := JMC_Parts.ReadPart(Item, 2, ',');
  try
    Qty := SysUtils.StrToFloat(JMC_Parts.ReadPart(Item, 1, ','));
  except
    Qty := 0.0;
  end;
  Cap := Capacity(Desc);
  if Qty > Cap then
    Qty := Cap;
  for i := 0 to Count - 1 do
  begin
    if Qty <= 0.0 then
      Break;
    j1 := Items[i].Definition.Capacity.IndexOf(Desc);
    if j1 < 0 then
      Continue;
    j2 := Items[i].Store.IndexOf(Desc);
    if j2 < 0 then
    begin
      Items[i].Store.Add(Desc, 0.0);
      j2 := Items[i].Store.Count - 1;
    end;
    x := Items[i].Definition.Capacity[j1].Quantity * Items[i].Quantity;
    c := x - Items[i].Store[j2].Quantity;
    if Qty >= c then
    begin
      Items[i].Store[j2].Quantity := x;
      Qty := Qty - c;
    end
    else
    begin
      Items[i].Store[j2].Quantity := Items[i].Store[j2].Quantity + Qty;
      Qty := 0.0;
    end;
  end;
end;

function TGameBuildingArray.Capacity(const Resource: string): Double;
var
  i: Integer;
  j: Integer;
  n: Integer;
begin
  Result := 0.0;
  for i := 0 to Count - 1 do
  begin
    n := Items[i].Quantity;
    j := Items[i].Definition.Capacity.IndexOf(Resource);
    if j >= 0 then
      Result := Result + n * Items[i].Definition.Capacity[j].Quantity;
  end;
end;

procedure TGameBuildingArray.Clear;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    Items[i].Free;
  FItems.Clear;
end;

constructor TGameBuildingArray.Create(const Definitions: TGameBuildingDefinitionArray);
begin
  FItems := Classes.TList.Create;
  FDefinitions := Definitions;
end;

destructor TGameBuildingArray.Destroy;
begin
  Clear;
  FItems.Free;
  inherited;
end;

function TGameBuildingArray.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TGameBuildingArray.GetItem(const Index: Integer): TGameBuilding;
begin
  Result := FItems[Index];
end;

procedure TGameBuildingArray.Increment;
begin

end;

function TGameBuildingArray.IndexOf(const Description: string): Integer;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    if Items[i].Definition.Description = Description then
    begin
      Result := i;
      Exit;
    end;
  Result := -1;
end;

function TGameBuildingArray.Quantity(const Resource: string): Double;
var
  i: Integer;
  j: Integer;
begin
  Result := 0.0;
  for i := 0 to Count - 1 do
  begin
    j := Items[i].Store.IndexOf(Resource);
    if j >= 0 then
      Result := Result + Items[i].Store[j].Quantity;
  end;
end;

procedure TGameBuildingArray.Tick;
var
  i: Integer;
  j: Integer;
  k: Integer;
  x: Integer;
  y: Integer;
  S: string;
  c: Double;
  q: Double;
  m: Double;
  qq: Double;
  cc: Double;
  d: Double;
begin
  for i := 0 to Count - 1 do
    for j := 0 to Items[i].Definition.ProductionRate.Count - 1 do
    begin
      S := Items[i].Definition.ProductionRate[j].Description;
      c := Capacity(S);
      q := Quantity(S);
      m := Items[i].Definition.ProductionRate[j].Quantity * Items[i].Quantity * Items[i].Definition.Owner.Owner.Interval / 60000;
      if (q + m) > c then
        Continue;
      for k := 0 to Count - 1 do
      begin
        x := Items[k].Store.IndexOf(S);
        y := Items[k].Definition.Capacity.IndexOf(S);
        if y < 0 then
          Continue;
        if x < 0 then
        begin
          Items[k].Store.Add(S, 0.0);
          x := Items[k].Store.Count - 1;
        end;
        qq := Items[k].Store[x].Quantity;
        cc := Items[k].Definition.Capacity[y].Quantity * Items[k].Quantity;
        d := cc - qq;
        if m > d then
        begin
          Items[k].Store[x].Quantity := cc;
          m := m - d;
        end
        else
        begin
          Items[k].Store[x].Quantity := Items[k].Store[x].Quantity + m;
          Break;
        end;
      end;
    end;
end;

{ TGamePlayer }

constructor TGamePlayer.Create(const Definitions: TGameBuildingDefinitionArray);
begin
  FBuildings := TGameBuildingArray.Create(Definitions);
  FDefinitions := Definitions;
end;

destructor TGamePlayer.Destroy;
begin
  FBuildings.Free;
  inherited;
end;

{ TGamePlayerArray }

procedure TGamePlayerArray.Add(const Item: TGamePlayer);
begin
  FItems.Add(Item);
end;

procedure TGamePlayerArray.Clear;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    Items[i].Free;
  FItems.Clear;
end;

constructor TGamePlayerArray.Create;
begin
  FItems := Classes.TList.Create;
end;

destructor TGamePlayerArray.Destroy;
begin
  Clear;
  FItems.Free;
  inherited;
end;

function TGamePlayerArray.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TGamePlayerArray.GetItem(const Index: Integer): TGamePlayer;
begin
  Result := FItems[Index];
end;

{ TGame }

constructor TGame.Create;
begin
  FBuildingDefinitions := TGameBuildingDefinitionArray.Create(Self);
  FPlayers := TGamePlayerArray.Create;
end;

destructor TGame.Destroy;
begin
  FPlayers.Free;
  FBuildingDefinitions.Free;
  inherited;
end;

function TGame.LoadBuildingDefinitions(const FileName: string): Boolean;
var
  Data: JMC_Strings.TStoredIniFile;
  Sections: JMC_Strings.TStringArray;
  i: Integer;
begin
  Result := False;
  if not SysUtils.FileExists(FileName) then
    Exit;
  Data := JMC_Strings.TStoredIniFile.Create;
  Sections := JMC_Strings.TStringArray.Create;
  try
    if not Data.LoadFromFile(FileName) then
      Exit;
    Data.ReadSections(Sections);
    for i := 0 to Sections.Count - 1 do
      FBuildingDefinitions.Add(Data, Sections[i]);
    Result := True;
  finally
    Sections.Free;
    Data.Free;
  end;
end;

function TGame.LoadPlayerDefaults(const FileName: string): Boolean;
var
  Data: JMC_Strings.TStoredIniFile;
  Keys: JMC_Strings.TStringArray;
  P: TGamePlayer;
  i: Integer;
begin
  Result := False;
  if not SysUtils.FileExists(FileName) then
    Exit;
  Data := JMC_Strings.TStoredIniFile.Create;
  Keys := JMC_Strings.TStringArray.Create;
  try
    if not Data.LoadFromFile(FileName) then
      Exit;
    P := TGamePlayer.Create(FBuildingDefinitions);
    P.Name := 'Default';
    Data.ReadKeys('Buildings', Keys);
    for i := 0 to Keys.Count - 1 do
      P.Buildings.Add(Data.ReadValue('Buildings', Keys[i]) + ',' + Keys[i]);
    Data.ReadKeys('Resources', Keys);
    for i := 0 to Keys.Count - 1 do
      P.Buildings.AddResource(Data.ReadValue('Resources', Keys[i]) + ',' + Keys[i]);
    FPlayers.Add(P);
    Result := True;
  finally
    Keys.Free;
    Data.Free;
  end;
end;

procedure TGame.Tick;
var
  i: Integer;
begin
  for i := 0 to FPlayers.Count - 1 do
    FPlayers[i].Buildings.Tick;
end;

end.