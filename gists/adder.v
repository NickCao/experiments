module adder (
input [3 : 0] a, 
input [3 : 0] b, 
input c0,
output [3 : 0] f, 
output c4
);
seq_adder s1(a, b, c0, f, c4);
endmodule

module seq_adder(
input [3 : 0] a, 
input [3 : 0] b, 
input c0, 
output [3 : 0] f, 
output c4
);
wire [4 : 0] c;
assign c[0] = c0;
assign c4 = c[4];
full_adder fa1(a[0], b[0], c[0], f[0], c[1]);
full_adder fa2(a[1], b[1], c[1], f[1], c[2]);
full_adder fa3(a[2], b[2], c[2], f[2], c[3]);
full_adder fa4(a[3], b[3], c[3], f[3], c[4]);
endmodule

module fast_adder (
input [3 : 0] a, 
input [3 : 0] b,
input c0, 
output [3 : 0] f,
output c4
);
wire [4 : 0] c;
wire [3 : 0] p;
wire [3 : 0] g;
assign c4 = c[4];
assign g[0] = a[0] & b[0];
assign g[1] = a[1] & b[1];
assign g[2] = a[2] & b[2];
assign g[3] = a[3] & b[3];
assign p[0] = a[0] | b[0];
assign p[1] = a[1] | b[1];
assign p[2] = a[2] | b[2];
assign p[3] = a[3] | b[3];
assign c[0] = c0;
assign c[1] = g[0] | (p[0] & c[0]);
assign c[2] = g[1] | (p[1] & c[1]);
assign c[3] = g[2] | (p[2] & c[2]);
assign c[4] = g[3] | (p[3] & c[3]);
full_adder fa1(a[0], b[0], c[0], f[0]);
full_adder fa2(a[1], b[1], c[1], f[1]);
full_adder fa3(a[2], b[2], c[2], f[2]);
full_adder fa4(a[3], b[3], c[3], f[3]);
endmodule

module half_adder (
input a, 
input b, 
output f, 
output c
);
assign f = a ^ b;
assign c = a & b;
endmodule

module full_adder (
input a, 
input b, 
input c0, 
output f, 
output c
);
wire f0;
wire cx;
wire cy;
half_adder ha1(a, b, f0, cx);
half_adder ha2(f0, c0, f, cy);
assign c = cx | cy;
endmodule
