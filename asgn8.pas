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
  published
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
  public
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
  published
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
  published
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
  published
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

type
  stringC = class(Value)
  private
    str: string;
  public
    constructor Create(s: string);
    procedure SetStr(s: string);
    function GetStr: string;
  published
    function ToString: string; override;
  end;

// stringC operations
constructor stringC.Create(s: string);
begin
  str := s;
end;

procedure stringC.SetStr(s: string);
begin
  str := s;
end;

function stringC.GetStr: string;
begin
  Result := str;
end;

function stringC.ToString: string;
begin
  Result := 'stringC: "' + str + '"';
end;

function IsRealNumber(const S: string): Boolean;
var
  R: Double;
begin
  Result := TryStrToFloat(S, R);
end;

function IsRealBool(const S: string): Boolean;
begin
  Result := (S = 'true') or (S = 'false');
end;

function IsRealString(const S: string): Boolean;
begin
  Result := (Length(S) >= 2) and (S[1] = '"') and (S[Length(S)] = '"');
end;

function IsSymbol(const S: string): Boolean;
begin
  Result := (Length(S) > 0) and (not IsRealNumber(S)) and (not IsRealBool(S)) and (not IsRealString(S));
end;

function StrToStr(const S: string): string;
begin
  Result := Copy(S, 2, Length(S) - 2);
end;

function StrToIdc(const S: string): string;
begin
  Result := S;
end;

function parse(Sexp: array of string): ExprC;
var
  s: string;
  guard, thenExpr, elseExpr: ExprC;
  elseExprs: array of string;
  i: integer;
begin
  if Length(Sexp) = 0 then
    raise Exception.Create('ZODE: parse: empty Sexp!')
  else
  begin
    s := Sexp[0];
    if IsRealNumber(s) then
      Result := numV.Create(StrToFloat(s))
    else if IsRealBool(s) then
      Result := boolV.Create(s = 'true')
    else if IsRealString(s) then
      Result := stringC.Create(StrToStr(s))
    else if IsSymbol(s) then
      Result := idC.Create(StrToIdc(s))
    else if (Length(Sexp) >= 6) and (Sexp[0] = 'if') and (Sexp[1] = ':') and (Sexp[3] = ':') and (Sexp[5] = ':') then
    begin
      guard := parse([Sexp[2]]);
      thenExpr := parse([Sexp[4]]);
      SetLength(elseExprs, Length(Sexp) - 5);
      for i := 6 to Length(Sexp) - 1 do
        elseExprs[i - 6] := Sexp[i];
      elseExpr := parse(elseExprs);
      Result := ifC.Create(guard, thenExpr, elseExpr);
    end
    else
      raise Exception.Create('ZODE: parse: unrecognized Sexp!');
  end;
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
  writeln('TestBoolV passed!');

  b := boolV.Create(false);
  assert(b.GetBool = false, 'TestBoolV failed');
  assert(b.ToString = 'boolV: false', 'TestBoolV ToString failed');
  writeln('TestBoolV passed!!');
end;

procedure TestStringC;
var
  s: stringC;
begin
  s := stringC.Create('Hello, World!');
  assert(s.GetStr = 'Hello, World!', 'TestStringC failed');
  assert(s.ToString = 'stringC: "Hello, World!"', 'TestStringC ToString failed');
  writeln('TestStringC passed!!');

  s := stringC.Create('');
  assert(s.GetStr = '', 'TestStringC failed');
  assert(s.ToString = 'stringC: ""', 'TestStringC ToString failed');
  writeln('TestStringC passed!!');
end;

procedure TestSymbolC;
var
  sym: idC;
begin
  sym := idC.Create('mySymbol');
  assert(sym.GetId = 'mySymbol', 'TestSymbolC failed');
  writeln('TestSymbolC passed');

  sym := idC.Create('another-symbol');
  assert(sym.GetId = 'another-symbol', 'TestSymbolC failed');
  writeln('TestSymbolC passed!!');
end;

procedure TestIfC;
var
  ifExpr: ifC;
  guardExpr, thenExpr, elseExpr: ExprC;
begin
  guardExpr := boolV.Create(true);
  thenExpr := numV.Create(42);
  elseExpr := numV.Create(0);
  ifExpr := ifC.Create(guardExpr, thenExpr, elseExpr);
  assert(ifExpr.g = guardExpr, 'TestIfC failed');
  assert(ifExpr.t = thenExpr, 'TestIfC failed');
  assert(ifExpr.e = elseExpr, 'TestIfC failed');
  writeln('TestIfC passed');

  guardExpr := boolV.Create(false);
  thenExpr := stringC.Create('true branch');
  elseExpr := stringC.Create('false branch');
  ifExpr := ifC.Create(guardExpr, thenExpr, elseExpr);
  assert(ifExpr.g = guardExpr, 'TestIfC failed');
  assert(ifExpr.t = thenExpr, 'TestIfC failed');
  assert(ifExpr.e = elseExpr, 'TestIfC failed');
  writeln('TestIfC passed');
end;

procedure TestParse;
var
  exprNum, exprBool, exprStr, exprSym, exprIf: ExprC;
begin
  exprNum := parse(['42']);
  assert(exprNum is numV, 'TestParse failed for numV');
  assert(numV(exprNum).GetNum = 42.0, 'TestParse failed for numV value');
  writeln('TestParse passed for numV');

  exprBool := parse(['true']);
  assert(exprBool is boolV, 'TestParse failed for boolV');
  assert(boolV(exprBool).GetBool = true, 'TestParse failed for boolV value');
  writeln('TestParse passed for boolV');

  exprStr := parse(['"Hello"']);
  assert(exprStr is stringC, 'TestParse failed for stringC');
  assert(stringC(exprStr).GetStr = 'Hello', 'TestParse failed for stringC value');
  writeln('TestParse passed for stringC');

  exprSym := parse(['mySymbol']);
  assert(exprSym is idC, 'TestParse failed for idC');
  assert(idC(exprSym).GetId = 'mySymbol', 'TestParse failed for idC value');
  writeln('TestParse passed for idC');

  exprIf := parse(['if', ':', 'true', ':', '42', ':', '0']);
  assert(exprIf is ifC, 'TestParse failed for ifC');
  assert(ifC(exprIf).g is boolV, 'TestParse failed for ifC guard');
  assert(ifC(exprIf).t is numV, 'TestParse failed for ifC then branch');
  assert(ifC(exprIf).e is numV, 'TestParse failed for ifC else branch');
  writeln('TestParse passed for ifC');
end;

procedure RunTests;
begin
  TestNumV;
  TestBoolV;
  TestStringC;
  TestSymbolC;
  TestIfC;
  TestParse;
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