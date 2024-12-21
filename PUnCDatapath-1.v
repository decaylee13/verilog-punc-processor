//==============================================================================
// Datapath for PUnC LC3 Processor
//==============================================================================

`include "Defines.v"

// SEXT Module
module Sext #(
    parameter INPUT_WIDTH = 6 // default input width
)(
    input wire [INPUT_WIDTH-1:0] data_in, // 6 bit input number
    output wire [15:0] data_out // 16 bit sign extended output
);
    assign data_out = {{(16-INPUT_WIDTH){data_in[INPUT_WIDTH-1]}}, data_in};
endmodule

module PUnCDatapath(
	// External Inputs
	input  wire        clk,            // Clock
	input  wire        rst,            // Reset
	input ir_ld,
	
	input alu_s1_en, // ALU enable 1 (significant bit)
	input alu_s0_en, // ALU enable 0 (least significant bit)
	input [1:0] alu_mux_1_en, // ALU mux enable 1
	input [2:0] alu_mux_2_en, // ALU mux enable 2
	input [1:0] mem_rf_mux_en, // memory and reg file enable
	input [1:0] mem_raddr_mux_en, // memory and read address enable
	input mem_rw_en, // memory read/write enable
	input reg_dr_sr_en, //register dr/sr enable
	input [1:0] pc_mux_en, //pc mux enable
	input pc_clr, //pc clr enable
	input pc_ld, //pc load enable
	input set_cc_en, //comparator enable
	input reg_rw_en, //register read/write enable
	
	input pc_inc,
	input st_state, // tells us that we are in the st state
	input jsrr_state,
	input br_state,
	
	input state_ld,

	// DEBUG Signals
	input  wire [15:0] mem_debug_addr,
	input  wire [2:0]  rf_debug_addr,
	output wire [15:0] mem_debug_data,
	output wire [15:0] rf_debug_data,
	output wire [15:0] pc_debug_data,
    
	// Add more ports here
	output reg [15:0] ir,
	output reg pc_br_en
);

	// Local Registers
	reg  [15:0] pc;
	reg [15:0] mem_pcoffset9_data; // stores the mem[PC+Offset9]
	reg [2:0] DR;

	// Declare other local wires and registers here
	
	// 128x16 memory variables
	reg[15:0] mem_r_addr_0;
	reg[15:0] mem_w_addr_0;
	wire[15:0] mem_r_data_0;
	reg[15:0] mem_rf_mux_output;
	reg[15:0] mem_w_data;
	
	//8 x 16 register file variables
	reg[2:0] reg_r_addr_0;
	reg[2:0] reg_r_addr_1;
	wire[15:0] reg_r_data_0;
	wire[15:0] reg_r_data_1;
	reg[2:0] reg_w_addr;
    reg[15:0] reg_w_data;
    
    // SEXT variables
    wire[15:0] imm5;
    wire[15:0] PCOffset9;
    wire[15:0] PCOffset11;
    wire[15:0] offset6;
    
    // ALU variables
    reg[15:0] alu_input_1;
    reg[15:0] alu_input_2;
    reg[15:0] alu_output;
    
    //PC Variables
    reg[15:0] pc_ld_value;
    
    //Comparator variables
    reg N;
    reg Z;
    reg P;

	// Assign PC debug net
	assign pc_debug_data = pc;
	
	//----------------------------------------------------------------------
	// Instruction Register
	//----------------------------------------------------------------------
	always @(posedge clk) begin
      if (rst) begin
         ir <= 16'd0;
      end
      else if (ir_ld) begin
         ir <= mem_r_data_0;
      end
   end
	
	
	//----------------------------------------------------------------------
	// Memory Module
	//----------------------------------------------------------------------
	
	always @(posedge clk or posedge rst) begin
	   if(rst) begin
	       pc <= 16'h0000;
	   end
	   else if(pc_clr) begin
	       pc <= 16'h0000;
	   end
	   	   else if (pc_inc) begin
	       pc <= pc + 1;
	   end
	   if(pc_ld) begin
           pc <= pc_ld_value;
	   end 

	end

    //----------------------------------------------------------------------
	// Comparator Modules
	//----------------------------------------------------------------------
    
    always @(*) begin 
        if (set_cc_en) begin 
            N = $signed(reg_w_data) < 0 ? 1'b1:1'b0;
            Z = $signed(reg_w_data) == 0 ? 1'b1:1'b0;
            P = $signed(reg_w_data) > 0 ? 1'b1:1'b0;
        end
    end

    //----------------------------------------------------------------------
	// MUX Module
	//----------------------------------------------------------------------
    
    Sext #(.INPUT_WIDTH(5))Sext_imm5(
        .data_in(ir[4:0]),
        .data_out(imm5)
    );
    Sext #(.INPUT_WIDTH(9))Sext_PCOffset9(
        .data_in(ir[8:0]),
        .data_out(PCOffset9)
    );
    Sext #(.INPUT_WIDTH(11))Sext_PCOffset11(
        .data_in(ir[10:0]),
        .data_out(PCOffset11)
    );
    Sext #(.INPUT_WIDTH(6))Sext_offset6(
        .data_in(ir[5:0]),
        .data_out(offset6)
    );
    
    always @(*) begin
    DR = ir[11:9];
        // register file read/write
        if(reg_rw_en) begin
            if(jsrr_state) begin
                reg_w_addr = 3'b111;
                //reg_w_data = pc + 1;
            end
            else begin 
                reg_w_addr = DR;
                reg_w_data = mem_rf_mux_output; 
            end
        end
        else if(~reg_rw_en) begin
            reg_r_addr_1 = ir[2:0];
            //reg_r_data_0 = rf[reg_r_addr_0];
            //reg_r_data_1 = reg_r_addr_1;
            // if we are in the st states, then reg_r_addr_1 will be ir[11:9]
            if(st_state) begin
                reg_r_addr_1 = ir[11:9];
            end
        end
        
        //pc mux
        if(pc_mux_en == 2'b10) begin
            pc_ld_value = reg_r_data_0;
        end
        else if (pc_mux_en == 2'b01) begin
            pc_ld_value = alu_output;
        end
        
        
        // register read address mux
        if(reg_dr_sr_en) begin
            reg_r_addr_0 = ir[8:6];
        end
        else if(~reg_dr_sr_en) begin
            reg_r_addr_0 = ir[11:9];
        end
        
        // memory read address mux
        if(mem_raddr_mux_en == 2'b00) begin
            if(mem_rw_en) begin
                mem_w_addr_0 = alu_output;
                mem_w_data = reg_r_data_1;
            end else if (~mem_rw_en) begin 
                mem_r_addr_0 = alu_output;
                mem_pcoffset9_data = mem_r_data_0;
            end
        end
        else if(mem_raddr_mux_en == 2'b01) begin 
            //mem_r_addr_0 = mem_r_data_0;
            //mem_w_addr_0 = mem_r_data_0;
            if(mem_rw_en) begin
                //mem_w_addr_0 = mem_r_data_0;
                mem_w_addr_0 = mem_pcoffset9_data;
                mem_w_data = reg_r_data_0;
            end else if (~mem_rw_en) begin
                // add a condition that will only set this during ldi, otherwirse, mem_r_addr_0 = mem_r_data_0;
                mem_r_addr_0 = mem_pcoffset9_data;
                //mem_r_addr_0 = mem_r_data_0;
            end
        end
        else if(mem_raddr_mux_en == 2'b10) begin
            mem_r_addr_0 = pc;
        end
        
        // memory and register file mux
        if(mem_rf_mux_en == 2'b00) begin
            mem_rf_mux_output = alu_output;
            reg_w_data = mem_rf_mux_output;
        end
        else if(mem_rf_mux_en == 2'b01) begin

            mem_rf_mux_output = mem_r_data_0;
            reg_w_data = mem_rf_mux_output;
        end
        else if(mem_rf_mux_en == 2'b10) begin
            mem_rf_mux_output = pc + 1;
            reg_w_data = mem_rf_mux_output;
        end
        
        // alu mux 1
        if(alu_mux_1_en == 2'b01) begin
            alu_input_1 = reg_r_data_0;
        end
        else if(alu_mux_1_en == 2'b10) begin
            alu_input_1 = pc + 1;
        end
        else if(alu_mux_1_en == 2'b11) begin
            //alu_input_1 = ir[8:6];
            alu_input_1 = reg_r_data_0;
        end
        
        // alu mux 2
        if(alu_mux_2_en == 3'b001) begin
            alu_input_2 = reg_r_data_1;
        end
        else if(alu_mux_2_en == 3'b010) begin
            alu_input_2 = imm5;
        end
        else if(alu_mux_2_en == 3'b011) begin
            alu_input_2 = PCOffset9;
        end
        else if(alu_mux_2_en == 3'b100) begin
            alu_input_2 = PCOffset11;
        end
        else if(alu_mux_2_en == 3'b101) begin
            alu_input_2 = offset6;
        end
    end
    
    //----------------------------------------------------------------------
	// ALU Module
	//----------------------------------------------------------------------
    
    always @(*) begin
        if(~alu_s1_en && ~alu_s0_en) begin
            alu_output = alu_input_1; // CONFUSED???
        end
        else if(~alu_s1_en && alu_s0_en) begin
            alu_output = alu_input_1 + alu_input_2;
        end
        else if(alu_s1_en && ~alu_s0_en) begin
            alu_output = alu_input_1 & alu_input_2;
        end
        else if (alu_s1_en && alu_s0_en) begin
            alu_output = ~alu_input_1;
        end
    end
    
    always @(*) begin
        pc_br_en = ir[11] && N || ir[10] && Z || ir[9] && P;
    end
    
	//----------------------------------------------------------------------
	// Memory Module
	//----------------------------------------------------------------------

	// 1024-entry 16-bit memory (connect other ports)
	Memory mem(
		.clk      (clk),
		.rst      (rst),
		.r_addr_0 (mem_r_addr_0),
		.r_addr_1 (mem_debug_addr),
		.w_addr   (mem_w_addr_0),
		.w_data   (mem_w_data),
		.w_en     (mem_rw_en),
		.r_data_0 (mem_r_data_0),
		.r_data_1 (mem_debug_data)
	);

	//----------------------------------------------------------------------
	// Register File Module
	//----------------------------------------------------------------------

	// 8-entry 16-bit register file (connect other ports)
	RegisterFile rfile(
		.clk      (clk),
		.rst      (rst),
		.r_addr_0 (reg_r_addr_0),
		.r_addr_1 (reg_r_addr_1),
		.r_addr_2 (rf_debug_addr),
		.w_addr   (reg_w_addr),
		.w_data   (reg_w_data),
		.w_en     (reg_rw_en),
		.r_data_0 (reg_r_data_0),
		.r_data_1 (reg_r_data_1),
		.r_data_2 (rf_debug_data)
	);

	//----------------------------------------------------------------------
	// Add all other datapath logic here
	//----------------------------------------------------------------------

endmodule
