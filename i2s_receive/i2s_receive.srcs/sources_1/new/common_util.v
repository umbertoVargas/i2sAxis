`ifndef COMMON_UTIL_V
 `define COMMON_UTIL_V
// This section holds things that may only be defined once (like defines)

// This is here for those synthesis tools which do not define the SYNTHESIS macro.
`ifndef SYNTHESIS
`define SYNTHESIS
// synthesis translate_off
`undef SYNTHESIS
// synthesis translate_on
`endif

`endif

// This section holds things that need to be defined for each module (like local functions).
function integer log2;
  input [31:0] value;
  integer result;
  begin
    value = value-1;
    for (result=0; value>0; result=result+1)
      value = value>>1;
    log2 = result;
  end
endfunction

function integer count_to;
  input [31:0] value;
  integer result;
  begin
    for (result=0; value>0; result=result+1)
      value = value>>1;
    count_to = result;
  end
endfunction

function integer max;
  input [31:0] a;
  input [31:0] b; 
  begin
    if (a>b)
      max = a;
    else
      max = b;
  end
endfunction

function integer min;
  input [31:0] a;
  input [31:0] b; 
  begin
    if (a<b)
      min = a;
    else
      min = b;
  end
endfunction

`ifndef SYNTHESIS
// This function helps to evaluate Perl expressions in Verilog. 
// When we have expressions from the include file, they haven't
// been evaluated like in the documentation so we need to  evaluate
// them in Verilog. It helps if we have some Perl functions around.
function integer real_to_int;
  input real x;
  begin
    real_to_int = x;
  end
endfunction

function real fixed_to_real;
  input integer frac;
  input signed [63:0] a;
  real r;
  begin
    while (a[0] == 0 && frac >1)
      begin
	a = (a >> 1)|{a[63],63'b0};
	frac = frac-1;
      end
    r = a;
    if (2**frac == 0)
      fixed_to_real = 'bx;
    else
      fixed_to_real = r/(2**frac);
  end
endfunction

function real ufixed_to_real;
  input integer frac;
  input [63:0] a;
  real r;
  begin
    while (a[0] == 0 && frac >1)
      begin
	a = (a >> 1);
	frac = frac-1;
      end
    r = a;
    if (2**frac == 0)
      ufixed_to_real = 'bx;
    else
      ufixed_to_real = r/(2**frac);
  end
endfunction

function signed [63:0] real_to_fixed;
  input integer frac;
  input real a;
  begin
    a = a * (2**frac);
    real_to_fixed = a;
  end
endfunction

function fixed_representable;
  input integer int_bits;
  input real value;
  begin
    fixed_representable = (-(1<<(int_bits-1)) <= value) && ((1<<(int_bits-1)) > value);
  end
endfunction
`endif //  `ifndef SYNTHESIS