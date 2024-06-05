program TestCasesExample;

{$MODE OBJFPC} // directive to be used for creating classes
{$M+} // directive that allows class constructors and destructors

uses
  SysUtils;

type
  ExprC = class
  end;

type
  Value = class(ExprC)
    function ToString: string; virtual; abstract;
  end;

type
   argz = array of ExprC;

type
   lamArgz = array of string;

type
  idC = class(ExprC)
  private
    id: string;
  public
    constructor Create(s: string);
    procedure SetId(s: string);
    function GetId: string;
  end;

type
  appC = class(ExprC)
  private
    exp: ExprC;
    args: argz;
  public
    constructor Create(ex: ExprC; arguments: argz);
    procedure SetExp(ex: ExprC);
    function GetExp: ExprC;
    procedure SetArgs(arguments: argz);
    function GetArgs: argz;
  end;

type
   lamC = class(ExprC)
   private
      args: lamArgz;
      body: ExprC;
   public
      constructor Create(lamArgs: lamArgz; lamBody: ExprC);
      procedure SetBody(lamBody: ExprC);
      function GetBody: ExprC;
      procedure SetArgs(lamArgs: lamArgz);
      function GetArgs: lamArgz;
end;

type
   ifC = class(ExprC)
   private
      g: ExprC;
      t: ExprC;
      e: ExprC;
   public  
      constructor Create(ifG: ExprC; ifT: ExprC; ifE: ExprC);
end;

type
   libfunC = class(ExprC)
   private
      id: string;
      args: argz;
   public
      constructor Create(libId: string; libArgs: argz);
end;

// values
type
  numV = class(Value)
  private
    num: real;
  public
    constructor Create(n: real);
    procedure SetNum(n: real);
    function GetNum: real;
    function ToString: string; override;
  end;

type
  boolV = class(Value)
  private
    b: boolean;
  public
    constructor Create(val: boolean);
    procedure SetBool(val: boolean);
    function GetBool: boolean;
    function ToString: string; override;
  end;

type
  primV = class(Value)
  private
    op: string; // Pascal uses string instead of Symbol
  public
    constructor Create(val: string);
    procedure SetOp(val: string);
    function GetOp: string;
    function ToString: string; override;
  end;

// numV operations
constructor numV.Create(n: real);
begin
  num := n;
end;

procedure numV.SetNum(n: real);
begin
  num := n;
end;

function numV.GetNum: real;
begin
  Result := num;
end;

function numV.ToString: string;
begin
  Result := 'numV: ' + FloatToStr(num);
end;

// boolV operations
constructor boolV.Create(val: boolean);
begin
  b := val;
end;

procedure boolV.SetBool(val: boolean);
begin
  b := val;
end;

function boolV.GetBool: boolean;
begin
  Result := b;
end;

function boolV.ToString: string;
begin
  if b then
    Result := 'boolV: true'
  else
    Result := 'boolV: false';
end;

// primV operations
constructor primV.Create(val: string);
begin
  op := val;
end;

procedure primV.SetOp(val: string);
begin
  op := val;
end;

function primV.GetOp: string;
begin
  Result := op;
end;

function primV.ToString: string;
begin
  Result := 'primV: ' + op;
end;

// idC operations
constructor idC.Create(s: string);
begin
  id := s;
end;

procedure idC.SetId(s: string);
begin
  id := s;
end;

function idC.GetId: string;
begin
  Result := id;
end;

// appC operations
constructor appC.Create(ex: ExprC; arguments: argz);
begin
  exp := ex;
  args := arguments;
end;

procedure appC.SetExp(ex: ExprC);
begin
  exp := ex;
end;

function appC.GetExp: ExprC;
begin
  Result := exp;
end;

procedure appC.SetArgs(arguments: argz);
begin
  args := arguments;
end;

function appC.GetArgs: argz;
begin
  Result := args;
end;

constructor lamC.Create(lamArgs: lamArgz; lamBody: ExprC);
begin
   args := lamArgs;
   body := lamBody;
end;

procedure lamC.SetArgs(lamArgs: lamArgz);
begin
   args := lamArgs;
end;

function lamC.GetArgs: lamArgz;
begin
   Result := args;
end;

procedure lamC.SetBody(lamBody: ExprC);
begin
   body := lamBody;
end;

function lamC.GetBody: ExprC;
begin
   Result := body;
end;

constructor ifC.Create(ifG: ExprC; ifT: ExprC; ifE: ExprC);
begin
   g := ifG;
   t := ifT;
   e := ifE;
end;

constructor libfunC.Create(libId: string; libArgs: argz);
begin
   id := libId;
   args := libArgs;
end;

function IsRealNumber(const S: string): Boolean;
var
  R: Double;
begin
  Result := TryStrToFloat(S, R);
end;

function parse(Sexp: array of string): ExprC;
var s: string;
begin
   if length(Sexp) = 0 then
      raise Exception.Create('ZODE: parse: empty Sexp!')
   else
      s := Sexp[0];
      if IsRealNumber(s) then
         Result := numV.Create(StrToFloat(s))
      else
         raise Exception.Create('ZODE: parse: unrecognized Sexp!');
end;

// Test cases
procedure TestNumV;
var
  n: numV;
begin
  n := numV.Create(42.0);
  assert(n.GetNum = 42.0, 'TestNumV failed');
  assert(n.ToString = 'numV: 42', 'TestNumV ToString failed');
  writeln('TestNumV passed');
end;

procedure TestBoolV;
var
  b: boolV;
begin
  b := boolV.Create(true);
  assert(b.GetBool = true, 'TestBoolV failed');
  assert(b.ToString = 'boolV: true', 'TestBoolV ToString failed');
  writeln('TestBoolV passed');
end;

procedure TestPrimV;
var
  p: primV;
begin
  p := primV.Create('+');
  assert(p.GetOp = '+', 'TestPrimV failed');
  assert(p.ToString = 'primV: +', 'TestPrimV ToString failed');
  writeln('TestPrimV passed');
end;

procedure RunTests;
begin
  TestNumV;
  TestBoolV;
  TestPrimV;
end;

var
  n1: numV;
  b1: boolV;
  p1: primV;

begin
  n1 := numV.Create(1.0);
  b1 := boolV.Create(true);
  p1 := primV.Create('+');
  writeln(n1.ToString);
  writeln(b1.ToString);
  writeln(p1.ToString);
  RunTests;
end.
