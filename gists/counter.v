module dflipflop (
input clk,
input reset,
output reg q,
output qrev
);
assign qrev = ~q;
always @(posedge clk, posedge reset)
begin
if (reset)
	q <= 0;
else
	q <= qrev;
end
endmodule

module sevenseg(
   input clk,
	input [3:0] bcd,
	output reg [6:0] seg
);
always @(posedge clk)
begin
   case (bcd)
      0: seg <= 'b0111111;
      1: seg <= 'b0000110;
      2 : seg <= 'b1011011;
      3 : seg <= 'b1001111;
      4 : seg <= 'b1100110;
      5 : seg <= 'b1101101;
      6 : seg <= 'b1111101;
      7 : seg <= 'b0000111;
      8 : seg <= 'b1111111;
      9 : seg <= 'b1100111;
      10 : seg <= 'b1110111;
      11 : seg <= 'b1111100;
      12 : seg <= 'b0111001;
      13 : seg <= 'b1011110;
      14 : seg <= 'b1111001;
      15 : seg <= 'b1110001;
      default: seg <= 'b0000000;
	endcase
end
endmodule

module bin2bcd(
    input [5:0] bin,
    output reg [3:0] hi,
	 output reg [3:0] lo
    );
    integer i;   
    always @(bin)
        begin
            hi = 4'd0;
				lo = 4'd0;
            for (i = 5; i >= 0; i = i-1)
            begin
                if(hi >= 5) 
                    hi = hi + 4'd3;
                if(lo >= 5)
                    lo = lo + 4'd3;
				hi = hi << 1;
				hi[0] = lo[3];
				lo = lo << 1;
				lo[0] = bin[i];
				end
        end            
endmodule

module counter(
input clk,
input pause,
input reset,
output [6 : 0] hi,
output [6 : 0] lo
);
reg rst;
reg run;
always @(posedge pause)
begin
run <= ~run;
end

always @(posedge clk, posedge reset)
begin
rst <= reset | q >= 20;
end

reg [19 : 0] clk_cnt;
reg cs;

always @(posedge clk) begin
if (run)
begin
clk_cnt <= clk_cnt + 1;
if (clk_cnt >= 500000)
begin
	clk_cnt <= 0;
	cs <= ~cs;
end
end
end
wire [5:0] q;
wire w0;
dflipflop dff0(.clk(cs), .reset(rst), .q(q[0]), .qrev(w0));
wire w1;
dflipflop dff1(.clk(w0), .reset(rst), .q(q[1]), .qrev(w1));
wire w2;
dflipflop dff2(.clk(w1), .reset(rst), .q(q[2]), .qrev(w2));
wire w3;
dflipflop dff3(.clk(w2), .reset(rst), .q(q[3]), .qrev(w3));
wire w4;
dflipflop dff4(.clk(w3), .reset(rst), .q(q[4]), .qrev(w4));
wire w5;
dflipflop dff5(.clk(w4), .reset(rst), .q(q[5]), .qrev(w5));
wire [7:0] bcd;
bin2bcd bb0(q, bcd[7:4], bcd[3:0]);
sevenseg seg0(clk, bcd[7:4], hi);
sevenseg seg1(clk, bcd[3:0], lo);
endmodule