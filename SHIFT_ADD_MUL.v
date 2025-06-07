module SHIFT_ADD_MUL(in1,in2,clk,rst,go,out,done);
input [3:0] in1,in2;
input clk,rst,go;
output [7:0] out;
output done;
wire lda,ldb,ldp,op_en,eq3;
DATAPATH D1(in1,in2,clk,rst,lda,ldb,ldp,op_en,set_count,out,eq3);
CONTROLPATH C1(clk,rst,go,eq3,lda,ldb,ldp,set_count,op_en,done);
endmodule

module DATAPATH(in1,in2,clk,rst,lda,ldb,ldp,op_en,set_count,out,eq3);
input [3:0] in1,in2;
input clk,rst,lda,ldb,ldp,op_en,set_count;
output [7:0] out;
output eq3;
wire [3:0] a_reg_out,b_reg_out;
wire [7:0] shift_in,shift_out,p_reg_in,p_reg_out;
wire [1:0] count;
REGISTER4 Ra(in1,clk,rst,lda,a_reg_out);
REGISTER4 Rb(in2,clk,rst,ldb,b_reg_out);
COUNTER Cntr(clk,rst,count,set_count);
MUX M1(a_reg_out,0,b_reg_out[count],shift_in);
SHIFT S1(shift_in,shift_out,count);
REGISTER8 Rp(p_reg_in,clk,rst,ldp,p_reg_out);
ADDER A1(shift_out,p_reg_out,p_reg_in);
REGISTER8 Ro(p_reg_out,clk,rst,op_en,out);
COMPARE Comp(count,eq3);
endmodule

module MUX(in1,in2,sel,out);
input [3:0] in1;
input [3:0] in2;
input sel;
output [7:0] out;
assign out=sel?in1:in2;
endmodule

module SHIFT(in,out,n);
input [7:0] in;
input [1:0]n;
output[7:0] out;
assign out=in<<n;
endmodule

module COUNTER(clk,rst,count,set_count);
input clk,rst,set_count;
output reg [1:0] count;
always @(posedge clk)
begin
    if(rst)
        count<=0; ///
    else if(set_count)
        count<=0;
    else
        count<=count+1;
end
endmodule

module REGISTER4(in,clk,rst,ld,out);
input [3:0] in;
input clk,rst,ld;
output reg [3:0] out;
always @(posedge clk)
begin
    if(rst)
        out<=0;
    else if(ld)
        out<=in;
    else
        out<=out;
end
endmodule

module REGISTER8(in,clk,rst,ld,out);
input [7:0] in;
input clk,rst,ld;
output reg [7:0] out;
always @(posedge clk)
begin
    if(rst)
        out<=0;
    else if(ld)
        out<=in;
    else
        out<=out;
end
endmodule

module COMPARE(in,out);
input [1:0] in;
output reg out;
always @(*)
begin
    if(in==3)
        out=1;
    else
        out=0;
end
endmodule

module ADDER(in1,in2,out);
input [7:0] in1,in2;
output [7:0] out;
assign out=in1+in2;
endmodule

module CONTROLPATH(clk,rst,go,eq3,lda,ldb,ldp,set_count,op_en,done);
input clk,rst,go,eq3;
output reg lda,ldb,ldp,op_en,done,set_count;
reg [1:0] PS,NS;
parameter   s0=2'b00,
            s1=2'b01,
            s2=2'b10,
            s3=2'b11;
always @(posedge clk)
begin
    if(rst)
        PS<=s0;
    else
        PS<=NS;
end
always @(PS,go,eq3)
begin
    case(PS)
        s0: begin
                lda<=0;
                ldb<=0;
                ldp<=0;
                op_en<=0;
                done<=0;
                set_count<=1;
                if(go)
                    NS<=s1;
                else
                    NS<=s0;
            end
        s1: begin
                lda<=1;
                ldb<=1;
                ldp<=1;
                op_en<=0;
                done<=0;
                set_count<=1;
                NS<=s2;
            end
        s2: begin
                lda<=0;
                ldb<=0;
                ldp<=1;
                op_en<=0;
                done<=0;
                set_count<=0;
                if(eq3)
                    NS<=s3;
                else
                    NS<=s2;
            end
        s3: begin
                lda<=0;
                ldb<=0;
                ldp<=0;
                op_en<=1;
                done<=1;
                set_count<=1;
            end
    endcase
end
endmodule