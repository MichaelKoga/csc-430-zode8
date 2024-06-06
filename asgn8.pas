program asgn8;

{$MODE OBJFPC} // directive to be used for creating classes
{$M+} // directive that allows class constructors and destructors
{$APPTYPE CONSOLE} // directive to force console application

uses
  SysUtils;

// ExprC type
type
  ExprC = class
  end;

// Value type
type
  Value = class(ExprC)
    function ToString: string; virtual; abstract;
  end;

type
   argz = array of ExprC;

type
   lamArgz = array of string;

// idC definition
type
  idC = class(ExprC)
  public
    id: string;
    constructor Create(s: string);
  end;

// appC definition
type
  appC = class(ExprC)
  public
    exp: ExprC;
    args: argz;
    constructor Create(ex: ExprC; arguments: argz);
  end;

// lamC definition
type
   lamC = class(ExprC)
   public
      args: lamArgz;
      body: ExprC;
      constructor Create(lamArgs: lamArgz; lamBody: ExprC);
   end;

// numC definition
type
   numC = class(ExprC)
   public
      num: Real;
      constructor Create(n : real);
      function ToString: string;
   end;

// stringC definition
type
   stringC = class(ExprC)
   public
      str : string;
      constructor Create(s: string);
      function ToString: string;
   end;

// ifC definition
type
   ifC = class(ExprC)
   public
      g: ExprC;
      t: ExprC;
      e: ExprC;
      constructor Create(ifG: ExprC; ifT: ExprC; ifE: ExprC);
end;

type
   libfunC = class(ExprC)
   public
      id: string;
      args: argz;
      constructor Create(libId: string; libArgs: argz);
end;

// numV value
type
  numV = class(Value)
  public
    num: real;
    constructor Create(n: real);
    function ToString: string; override;
  end;

// boolV value
type
  boolV = class(Value)
  public
    b: boolean;
    constructor Create(val: boolean);
    function ToString: string; override;
  end;

// primV value
type
  primV = class(Value)
  public
    op: string; // Pascal uses string instead of Symbol
    constructor Create(val: string);
    function ToString: string; override;
  end;

// numV operations
constructor numV.Create(n: real);
begin
  num := n;
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

function primV.ToString: string;
begin
  Result := 'primV: ' + op;
end;

// idC operations
constructor idC.Create(s: string);
begin
  id := s;
end;

// appC operations
constructor appC.Create(ex: ExprC; arguments: argz);
begin
  exp := ex;
  args := arguments;
end;

// lamC operations
constructor lamC.Create(lamArgs: lamArgz; lamBody: ExprC);
begin
   args := lamArgs;
   body := lamBody;
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

// stringC operations
constructor stringC.Create(s : string);
begin
  str := s;
end;

function stringC.ToString: string;
begin
  Result := 'stringC: ' + str;
end;

// numC operations
constructor numC.Create(n : real);
begin
  num := n;
end;

function numC.ToString: string;
begin
  Result := 'numC: ' + FloatToStr(num);
end;

// Prohibited keywords
var
  keywords: array[0..8] of string = ('''true', '''false', '''lamb', '''locals',
  '''if', ''':', '''{', '''}', ''':=');
  primOps: array of string = ('+', '-', '*', '/', '<=');

function IsPrimOp(const op: string) : Boolean;
var
  i: Integer;
begin
  Result := false; // Initialize Result to false
  for i := Low(primOps) to High(primOps) do
  begin
    if primOps[i] = op then
    begin
      Result := true; // Set Result to true if operator is found
      Exit;
    end;
  end;
end;

function IsKeyword(const S: string) : Boolean;
var
  i: Integer;
begin
  Result := false; // Initialize Result to false
  for i := Low(keywords) to High(keywords) do
  begin
    if keywords[i] = S then
    begin
      Result := true; // Set Result to true if keyword is found
      Exit;
    end;
  end;
end;


// Check type
function IsRealNumber(const S: string): Boolean;
var
  R: Double;
begin
  Result := false; // Initialize Result to false
  Result := TryStrToFloat(S, R);
end;

function IsRealString(const S: string): Boolean;
begin
  Result := (Length(S) >= 2) and (S[1] = '"') and (S[Length(S)] = '"');
end;

function IsBool(const S: string) : Boolean;
begin
  Result := false; // Initialize Result to false
  Result := (S = 'true') or (S = 'false');
end;

function IsSymbol(const S: string) : Boolean;
begin
  Result := false; // Initialize Result to false
  Result := (Length(S) > 0) and (S[0] = '''') and IsKeyword(s);
end;

function parse(Sexp: array of string): ExprC;
var
  s: string;
  appCArgs: array of ExprC;
  i: integer;
begin
  if Length(Sexp) = 0 then
    raise Exception.Create('ZODE: parse: empty Sexp!')
  else
  begin
    s := Sexp[0];
    if IsRealNumber(s) then
    begin
      Result := numV.Create(StrToFloat(s));
      Exit;
    end
    else if IsBool(s) then
    begin
      if s = 'true' then
        Result := boolV.Create(true)
      else
        Result := boolV.Create(false);
      Exit;
    end
    else if IsRealString(s) then
    begin
      Result := stringC.Create(Copy(s, 2, Length(s) - 2));
      Exit;
    end
    else if IsSymbol(s) then
    begin
      Result := idC.Create(s);
      Exit;
    end
    else if (Length(Sexp) = 3) and IsPrimOp(Sexp[0]) then
    begin
      SetLength(appCArgs, 2);
      appCArgs[0] := parse([Sexp[1]]);
      appCArgs[1] := parse([Sexp[2]]);
      Result := appC.Create(idC.Create(Sexp[0]), appCArgs);
      Exit;
    end
    else if (Length(Sexp) > 5) and (Sexp[0] = 'if') and (Sexp[1] = ':') and (Sexp[3] = ':') and (Sexp[5] = ':') then
    begin
      Result := ifC.Create(parse([Sexp[2]]), parse([Sexp[4]]), parse([Sexp[6]]));
      Exit;
    end
    else
    begin
      writeln('unrecognized: ');
      for i := 0 to High(Sexp) do
      begin
        writeln(Sexp[i]);
      end;
      raise Exception.Create('ZODE: parse: unrecognized Sexp!');
    end;
  end;
end;



// Test cases
procedure TestNumV;
var
  n: numV;
begin
  n := numV.Create(42.0);
  assert(n.num = 42.0, 'TestNumV failed');
  assert(n.ToString = 'numV: 42', 'TestNumV ToString failed');
  writeln('TestNumV passed');
end;

procedure TestBoolV;
var
  b: boolV;
begin
  b := boolV.Create(true);
  assert(b.b = true, 'TestBoolV failed');
  assert(b.ToString = 'boolV: true', 'TestBoolV ToString failed');
  writeln('TestBoolV passed');
end;

procedure TestPrimV;
var
  p: primV;
begin
  p := primV.Create('+');
  assert(p.op = '+', 'TestPrimV failed');
  assert(p.ToString = 'primV: +', 'TestPrimV ToString failed');
  writeln('TestPrimV passed');
end;


procedure TestParse;
var
  numArr: array of string = ('1');
  strArr: array of string = ('"cow"');
  symArr: array of string = ('''cow');
  boolTArr: array of string = ('true');
  boolFArr: array of string = ('false');
  keywordCheckArr: array of string = ('''true');
  ifArr: array of string = ('if', ':', 'true', ':', '1', ':', '0');
  primOpArr: array of string = ('+', '1', '2');
  parsedExpr: ExprC;
  expectedExpr: appC;
  expectedArgs: argz;
begin
  // Test parsing a number
  writeln('testing parse on just numV');
  assert(parse(numArr) is numV, 'Test Parse failed: numArr');

  // Test parsing a string
  writeln('testing parse on stringC');
  assert(parse(strArr) is stringC, 'Test Parse failed: strArr');

  // Test parsing a symbol
  writeln('testing parse on idC');
  assert(parse(symArr) is idC, 'Test Parse failed: symArr');

  // Test parsing a boolean true
  writeln('testing parse on boolV (true)');
  assert(parse(boolTArr) is boolV, 'Test Parse failed: boolTArr');

  // Test parsing a boolean false
  writeln('testing parse on boolV (false)');
  assert(parse(boolFArr) is boolV, 'Test Parse failed: boolFArr');

  // Test parsing a primitive operation
  writeln('testing parse on appC');
  parsedExpr := parse(primOpArr);
  assert(parsedExpr is appC, 'Test Parse failed: primOpArr is not appC');

  // Create the expected appC object
  SetLength(expectedArgs, 2);
  expectedArgs[0] := numC.Create(1);
  expectedArgs[1] := numC.Create(2);
  expectedExpr := appC.Create(idC.Create('+'), expectedArgs);
  assert(parsedExpr = expectedExpr, 'Test Parse failed: unexpected appC');
  writeln('Test Parse passed');
end;

procedure RunTests;
begin
  TestNumV;
  TestBoolV;
  TestPrimV;
  TestParse;
end;

var
  n1: numV;
  b1: boolV;
  p1: primV;

begin
  writeln('Hello world');
  n1 := numV.Create(1.0);
  b1 := boolV.Create(true);
  p1 := primV.Create('+');
  writeln(n1.ToString);
  writeln(b1.ToString);
  writeln(p1.ToString);
  RunTests;
  writeln('Press ENTER to exit');
  readln();
end.