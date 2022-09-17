//800x600 @ 40MHz


module hcounter(input t_clk, output reg h_blank, output reg h_sync, output reg h528, output [9:0] hcount);
  reg[9:0] hcount;  // 10-Bit Counter
  wire h528;

  always@(posedge t_clk) 
  begin
    hcount <= hcount + 1;
    if(hcount == 400) begin
      h400 <= 1'b1;
      h420 <= 1'b0;
      h484 <= 1'b0;
      h528 <= 1'b0;
      h_blank <= 1'b1;
      hcount <= hcount + 1; 
    end
    else if(hcount == 420) begin
      h400 <= 1'b0;
      h420 <= 1'b1;
      h484 <= 1'b0;
      h528 <= 1'b0;
      h_sync <= 1'b1;
      hcount <= hcount + 1; 
    end
    else if(hcount == 484) begin
      h400 <= 1'b0;
      h420 <= 1'b0;
      h484 <= 1'b1;
      h528 <= 1'b0;
      h_sync <= 1'b0;
      hcount <= hcount + 1;
    end 
    else if(hcount == 528) begin      
      h400 <= 1'b0;
      h420 <= 1'b0;
      h484 <= 1'b0;
      h528 <= 1'b1;
      h_blank <= 1'b0;
      hcount <= 0;
    end 

  end

  
endmodule

module vcounter(input vclk, output reg v_blank, output reg v_sync, output [9:0] vcount);
  reg[9:0] vcount;  // 10-Bit Counter


  always@(posedge vclk) 
  begin
    vcount <= vcount + 1;
    if(vcount == 600) begin
      v600 <= 1'b1;
      v601 <= 1'b0;
      v605 <= 1'b0;
      v628 <= 1'b0;
      v_blank <= 1'b1;
      vcount <= vcount + 1; 
    end
    else if(vcount == 601) begin
      v600 <= 1'b0;
      v601 <= 1'b1;
      v605 <= 1'b0;
      v628 <= 1'b0;
      v_sync <= 1'b1;
      vcount <= vcount + 1; 
    end
    else if(vcount == 605) begin
      v600 <= 1'b0;
      v601 <= 1'b0;
      v605 <= 1'b1;
      v628 <= 1'b0;
      v_sync <= 1'b0;
      vcount <= vcount + 1;
    end 
    else if(vcount == 628) begin      
      v600 <= 1'b0;
      v601 <= 1'b0;
      v605 <= 1'b0;
      v628 <= 1'b1;
      v_blank <= 1'b0;
      vcount <= 0;
    end 
  end

endmodule 
/*
module rom_using_file (
  address , // Address input
  data    , // Data output
  read_en , // Read Enable 
);
  input [16:0] address;
  output [7:0] data; 
  input read_en; 
           
  reg [7:0] mem [0:25000] ;  
      
  assign data = (read_en) ? mem[address] : 8'b0;

  initial begin
    $readmemh("lena2.hex", mem); 
  end

endmodule
*/
module implicit_bram(input wire clk, input wire rd_en, input wire wr_en, input wire [15:0] rd_addr, input wire [15:0] wr_addr, input wire [7:0] data_in, output reg [7:0] data_out, output reg valid_out);

   reg [7:0] memory [0:13000];
   //integer i;

   initial begin
      //for(i = 0; i <= 500000; i=i+1) begin
        // memory[i] = 16'b001;
      //end
      // data_out = 0; //should not exist if we want bram to be inferred
      $readmemh("finch2.hex", memory); 
      valid_out = 0;
   end

   always @(posedge clk)
   begin
      // default
      valid_out <= 0;

      if(wr_en) begin
         memory[wr_addr] <= data_in;
      end
      if (rd_en) begin
         data_out <= memory[rd_addr];
         valid_out <= 1;
      end
   end
endmodule

module top(input clkin, output reg hs, output reg vs, output r0, output g0, output b0, output r1, output g1, output b1, output nvb, output nhb, output vhb);

  wire clkout, hb, hs, vb, vs, hreset, vhb, nvb, nhb, rd, wr, valid_out;
  reg[9:0] hc;  // 10-Bit Counter
  reg[9:0] vc;  // 10-Bit Counter
  reg[15:0] address;
  reg[7:0] data;

  assign rd = 1'b1;
  assign wr = 1'b0;
  assign nhb = ~hb;
  assign nvb = ~vb;
  nand (vhb, nvb, nhb);

SB_PLL40_PAD #(
		.FEEDBACK_PATH("SIMPLE"),
		.DIVR(4'b0000),		// DIVR =  0
		.DIVF(7'b0110100),	// DIVF = 52
		.DIVQ(3'b101),		// DIVQ =  5
		.FILTER_RANGE(3'b001)	// FILTER_RANGE = 1
	) uut (
		.LOCK(locked),
		.RESETB(1'b1),
		.BYPASS(1'b0),
		.PACKAGEPIN(clkin),
		.PLLOUTCORE(clkout)
		);
 
  hcounter hsync      (.t_clk(clkout), .h_blank(hb), .h_sync(hs), .h528(hreset), .hcount(hc));     
  vcounter vsync      (.vclk(hreset), .v_blank(vb), .v_sync(vs), .vcount(vc));
  //rom_using_file rom (.address(address), .data(data), .read_en(~vhb));
  implicit_bram rom (.clk(clkout), .rd_en(rd), .wr_en(wr), .rd_addr(address), .wr_addr(address), .data_in(data), .data_out(data), .valid_out(valid_out));


  always @(posedge clkout)
  begin
    
    address[8:0] <= hc[9:1];
    address[15:9] <= vc[9:2];
    //address[14] <= 1'b0;
      
    r0 <= data[4];
    r1 <= data[5];
    g0 <= data[2];
    g1 <= data[3];
    b0 <= data[0];
    b1 <= data[1];

  end

endmodule

