

module hcounter(input t_clk, output reg h_blank, output reg h_sync, output reg h264, output [8:0] hcount);
  reg[8:0] hcount;  // 9-Bit Counter
  wire h264;

  always@(posedge t_clk) 
  begin
    hcount <= hcount + 1;
    if(hcount == 200) begin
      h200 <= 1'b1;
      h210 <= 1'b0;
      h242 <= 1'b0;
      h264 <= 1'b0;
      h_blank <= 1'b1;
      hcount <= hcount + 1; 
    end
    else if(hcount == 210) begin
      h200 <= 1'b0;
      h210 <= 1'b1;
      h242 <= 1'b0;
      h264 <= 1'b0;
      h_sync <= 1'b1;
      hcount <= hcount + 1; 
    end
    else if(hcount == 242) begin
      h200 <= 1'b0;
      h210 <= 1'b0;
      h242 <= 1'b1;
      h264 <= 1'b0;
      h_sync <= 1'b0;
      hcount <= hcount + 1;
    end 
    else if(hcount == 264) begin      
      h200 <= 1'b0;
      h210 <= 1'b0;
      h242 <= 1'b0;
      h264 <= 1'b1;
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

module rom_using_file (
  address , // Address input
  data    , // Data output
  read_en , // Read Enable 
);
  input [14:0] address;
  output [7:0] data; 
  input read_en; 
           
  reg [7:0] mem [0:18000] ;  
      
  assign data = (read_en) ? mem[address] : 8'b0;

  initial begin
    $readmemh("lena2.hex", mem); 
  end

endmodule

module top(input clkin, output reg hs, output reg vs, output r0, output g0, output b0, output r1, output g1, output b1, output nvb, output nhb, output vhb);

  wire hb, hs, vb, vs, hreset, vhb, nvb, nhb;
  reg[8:0] hc;  // 9-Bit Counter
  reg[9:0] vc;  // 10-Bit Counter
  reg[14:0] address;
  reg[7:0] data;

  assign nhb = ~hb;
  assign nvb = ~vb;
  nand (vhb, nvb, nhb);
 
  hcounter hsync      (.t_clk(clkin), .h_blank(hb), .h_sync(hs), .h264(hreset), .hcount(hc));     
  vcounter vsync      (.vclk(hreset), .v_blank(vb), .v_sync(vs), .vcount(vc));
  rom_using_file rom (.address(address), .data(data), .read_en(~vhb));


  always @(posedge clkin)
  begin
    
    address[6:0] <= hc[7:1];
    address[13:7] <= vc[9:3];
    address[14] <= 1'b0;
      
    r0 <= data[4];
    r1 <= data[5];
    g0 <= data[2];
    g1 <= data[3];
    b0 <= data[0];
    b1 <= data[1];

  end

endmodule