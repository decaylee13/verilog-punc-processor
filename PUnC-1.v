//==============================================================================
// Module for PUnC LC3 Processor
//==============================================================================

module PUnC(
	// External Inputs
	input  wire        clk,            // Clock
	input  wire        rst,            // Reset

	// Debug Signals
	input  wire [15:0] mem_debug_addr,
	input  wire [2:0]  rf_debug_addr,
	output wire [15:0] mem_debug_data,
	output wire [15:0] rf_debug_data,
	output wire [15:0] pc_debug_data
);

	//----------------------------------------------------------------------
	// Interconnect Wires
	//----------------------------------------------------------------------

	// Declare your wires for connecting the datapath to the controller here
	wire mem_rw_en;
	wire [1:0] mem_rf_mux_en;
	wire [1:0] mem_raddr_mux_en;
	wire pc_clr;
	wire pc_ld;
	wire [1:0] pc_mux_en;
	wire [1:0] alu_mux_1_en;
	wire [2:0] alu_mux_2_en;
	wire alu_s0_en;
	wire alu_s1_en;
	wire set_cc_en;
	wire reg_dr_sr_en;
	wire reg_rw_en;
	wire ir_ld;
	wire [15:0] ir;
	wire state_ld;
	wire pc_inc;
	wire st_state;
	wire jsrr_state;
	wire br_state;
	wire pc_br_en;

	//----------------------------------------------------------------------
	// Control Module
	//----------------------------------------------------------------------
	PUnCControl ctrl(
		.clk             (clk),
		.rst             (rst),

		// Add more ports here
		.mem_rw_en(mem_rw_en),
	    .mem_rf_mux_en(mem_rf_mux_en),
	    .mem_raddr_mux_en(mem_raddr_mux_en),
	    .pc_clr(pc_clr),
	    .pc_ld(pc_ld),
	    .pc_mux_en(pc_mux_en),
	    .alu_mux_1_en(alu_mux_1_en),
	    .alu_mux_2_en(alu_mux_2_en),
	    .alu_s0_en(alu_s0_en),
	    .alu_s1_en(alu_s1_en),
	    .set_cc_en(set_cc_en),
	    .reg_dr_sr_en(reg_dr_sr_en),
	    .reg_rw_en(reg_rw_en),
	    .ir_ld(ir_ld),
	    .ir(ir),
	    .state_ld (state_ld),
	    .pc_inc(pc_inc),
	    .st_state(st_state),
	    .jsrr_state(jsrr_state),
	    .br_state(br_state),
	    .pc_br_en(pc_br_en)
	);

	//----------------------------------------------------------------------
	// Datapath Module
	//----------------------------------------------------------------------
	PUnCDatapath dpath(
		.clk             (clk),
		.rst             (rst),

		.mem_debug_addr   (mem_debug_addr),
		.rf_debug_addr    (rf_debug_addr),
		.mem_debug_data   (mem_debug_data),
		.rf_debug_data    (rf_debug_data),
		.pc_debug_data    (pc_debug_data),

		// Add more ports here
		.alu_s1_en(alu_s1_en), 
        .alu_s0_en(alu_s0_en), 
        .alu_mux_1_en(alu_mux_1_en), 
        .alu_mux_2_en(alu_mux_2_en),
        .mem_rf_mux_en(mem_rf_mux_en), 
        .mem_raddr_mux_en(mem_raddr_mux_en), 
        .mem_rw_en(mem_rw_en), 
        .reg_dr_sr_en(reg_dr_sr_en), 
        .pc_mux_en(pc_mux_en), 
        .pc_clr(pc_clr), 
        .pc_ld(pc_ld), 
        .set_cc_en(set_cc_en),
        .reg_rw_en(reg_rw_en),
        .ir_ld(ir_ld),
        .ir(ir),
        .state_ld (state_ld),
        .pc_inc(pc_inc),
        .st_state(st_state),
        .jsrr_state(jsrr_state),
        .br_state(br_state),
        .pc_br_en(pc_br_en)

	);

endmodule
