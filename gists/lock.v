module lock(
  input clk,
  input rst,
  input [3 : 0] code,
  input [1 : 0] mode,
  output reg unlock,
  output reg err,
  output reg alarm,
  output [3:0] curr
);
  reg user_valid;
  reg admin_valid;
  reg valid;
  integer user = 0;
  integer state = 0;
  integer num_err = 0;
  integer pass [3:0];
  integer admin [3:0];
  integer trans [8:0];
  initial
  begin
    admin[3] <= 2;
	 admin[2] <= 15;
	 admin[1] <= 2;
	 admin[0] <= 15;
	 trans[1] <= 2;
	 trans[2] <= 3;
	 trans[3] <= 4;
	 trans[4] <= 0;
	 trans[5] <= 6;
	 trans[6] <= 7;
	 trans[7] <= 8;
	 trans[8] <= 0;
  end
  assign curr = state;
  always @(posedge clk, posedge rst)
  begin
    if (rst)
    begin
	   if(mode == 0 && unlock) begin
        state <= 1;
		end else if(mode == 1) begin
		  state <= 5;
		end
		err <= 0;
		unlock <= 0;
		user <= 0;
    end else if (clk)
    begin
      case(state)
        1, 2, 3, 4: begin
          pass[4 - state] <= code;
          state <= trans[state];
        end
        5, 6, 7, 8: begin 
		    if(pass[8 - state] == code && ~alarm && admin[8 - state] == code) begin
			    user <= 0;
				 valid = 1;
			 end else if (pass[8 - state] == code && ~alarm && (user == 0 || user == 1)) begin
			    user <= 1;
				 valid = 1;
			 end else if (admin[8 - state] == code && (user == 0 || user == 2)) begin
			    user <= 2;
				 valid = 1;
			 end else begin
			    user <= 0;
			    valid = 0;
			 end
          if(valid) begin
            state <= trans[state];
				if(state == 8) begin
				  unlock <= 1;
				  alarm <= 0;
				  num_err <= 0;
				end
          end else begin
            state <= 0;
				err <= 1;
				num_err <= num_err + 1;
				if(num_err >= 3) begin
				  alarm <= 1;
				end
          end
        end
      endcase
    end
  end
endmodule
