//==============================================================================
// Control Unit for PUnC LC3 Processor
//==============================================================================

`include "Defines.v"

module PUnCControl(
	// External Inputs
	input  wire        clk,            // Clock
	input  wire        rst,            // Reset
	
	// Memory Controls 
	output reg  [1:0]  mem_r_addr_sel,
	output reg mem_rw_en,
	output reg [1:0] mem_rf_mux_en,
	output reg [1:0] mem_raddr_mux_en,


	// Register File Controls
	//....
	output reg reg_rw_en,

	// Instruction Register Controls
	//...
	input [15:0] ir,
	input pc_br_en,
	output reg ir_ld,
	output reg br_state,


	// Program Counter Controls
	output reg pc_clr,
	output reg pc_ld,
	output reg [1:0] pc_mux_en,
	output reg pc_inc,
	

	// Add more ports here
	
	// ALU Controls
	output reg [1:0] alu_mux_1_en,
	output reg[2:0] alu_mux_2_en,
	output reg alu_s0_en,
	output reg alu_s1_en,
	
	output reg set_cc_en,
	output reg reg_dr_sr_en,
	output reg state_ld,
	
	output reg st_state,
	output reg jsrr_state


);

	// FSM States
	// Add your FSM State values as localparams here
	// localparam STATE_FETCH     = X'd0;
	reg [3:0] state;
    reg [3:0] next_state;

	// State, Next State
	// reg [X:0] state, next_state;
	
	localparam [2:0] INIT           = 3'd0;
	localparam [2:0] FETCH          = 3'd1;
	localparam [2:0] DECODE         = 3'd2;
	localparam [2:0] EXECUTE_1      = 3'd3;
	localparam [2:0] EXECUTE_2      = 3'd4;
	localparam [2:0] HALT           = 3'd5;
	
	/*localparam[4:0] INIT = 5'd0;
	localparam[4:0] FETCH = 5'd1;
	localparam[4:0] DECODE = 5'd2;
	localparam [4:0] ADD          = 5'd3;
    localparam [4:0] AND            = 5'd4;
    localparam [4:0] BR             = 5'd5;
    localparam [4:0] JMP            = 5'd6;
    localparam [4:0] JSR            = 5'd7;
    localparam [4:0] LD             = 5'd8;
    localparam [4:0] LDI_1            = 5'd9;
    localparam[4:0] LDI_2 =         5'd10;
    localparam [4:0] LDR            = 5'd11;
    localparam [4:0] LEA            = 5'd12;
    localparam [4:0] NOT            = 5'd13;
    localparam [4:0] ST             = 5'd14;
    localparam [4:0] STI            = 5'd15;
    localparam [4:0] STR            = 5'd16;
    localparam [4:0] HLT            = 5'd17;*/
    

	// Output Combinational Logic
	always @( * ) begin
		// Set default values for outputs here (prevents implicit latching)
		mem_r_addr_sel = 2'b00;
		mem_rw_en = 2'b00;
		mem_rf_mux_en = 2'b00;
		mem_raddr_mux_en = 0;
		
		pc_clr = 0;
		pc_ld = 0;
		pc_mux_en = 2'b00;
		
		//alu_mux_1_en = 2'b00;
		//alu_mux_2_en = 3'b000;
		alu_s0_en = 0;
		alu_s1_en = 0;
		
		set_cc_en = 0;
		reg_dr_sr_en = 0;
		reg_rw_en = 0;
		ir_ld = 0;
		
		st_state = 0;
		jsrr_state = 0;

		// Add your output logic here
		//case (state)
		//	STATE_FETCH: begin
		//
		//	end
		//endcase
		
		case(state)
		  INIT: begin
		      pc_clr = 1'd1;
		  end
		  FETCH: begin
		      ir_ld = 1;
		      mem_raddr_mux_en = 2'b10;
		      //pc_ld = 1;
		      //pc_inc = 1;
		      pc_inc = 0;
		      
		  end
		  
		  DECODE: begin
		      //pc_ld = 1;
		      mem_raddr_mux_en = 2'b10;
		      ir_ld = 0;
		      pc_inc = 0;
		  end
		  
		  EXECUTE_1: begin
		      //pc_inc = 0;
		      mem_raddr_mux_en = 2'b10;
		      pc_mux_en = 2'b00;
		      case(ir[`OC])
                  `OC_ADD: begin
                      pc_inc = 1;
                      //pc_ld = 1;
                      //pc_mux_en = 2'b00;
                      alu_mux_1_en = 2'b01;
                      alu_s1_en = 0;
                      alu_s0_en = 1;
                      mem_rf_mux_en = 2'b00;
                      set_cc_en = 1;
                      reg_dr_sr_en = 1;
                      reg_rw_en = 1;
                      if(ir[5]) begin
                          alu_mux_2_en = 3'b010;
                      end 
                      else begin
                          alu_mux_2_en = 3'b001;
                      end 
                  end 
                  
                  `OC_AND: begin
                      pc_inc = 1;
                      //pc_ld = 1;
                      //pc_mux_en = 2'b00;
                      alu_mux_1_en = 2'b01;
                      if(ir[5]) begin
                          alu_mux_2_en = 3'b010;
                      end 
                      else begin
                          alu_mux_2_en = 3'b001;
                      end
                      alu_s0_en = 0;
                      alu_s1_en = 1;
                      mem_rf_mux_en = 2'b00;
                      set_cc_en = 1;
                      reg_dr_sr_en = 1;
                      reg_rw_en = 1;
                  end
                  
                  `OC_BR: begin
                      pc_inc = 1;
                      br_state = 1;
                      //pc_ld = 1;
                      alu_mux_1_en = 2'b10;
                      alu_mux_2_en = 3'b011;
                      if(pc_br_en) begin
                        pc_ld = 1;
                        pc_mux_en = 2'b01;
                      end
                      alu_s0_en = 1;
                      alu_s1_en = 0;
                      reg_rw_en = 0;
                  end
                  
                  `OC_JMP: begin
                      //pc_inc = 1;
                      //pc_ld = 1;
                      //pc_mux_en = 2'b10;
                      pc_ld = 1;
                      pc_inc = 0;
                      reg_rw_en = 0;
                      reg_dr_sr_en = 1;
                      pc_mux_en = 2'b10;
                  end
		  
                  `OC_JSR: begin 
                      pc_inc = 0;
                      reg_rw_en = 1;
                      mem_rf_mux_en = 2'b10;
                      jsrr_state = 1;
                      /*if(ir[11]) begin
                          jsrr_state = 1;
                          reg_rw_en = 1;
                          mem_rf_mux_en = 2'b10;
                      end 
                      else begin
                          pc_ld = 1;
                          pc_inc = 0;
                          reg_rw_en = 0;
                          reg_dr_sr_en = 1;
                          pc_mux_en = 2'b10;
                      end*/
                  end
		  
                  `OC_LD: begin
                      pc_inc = 1;
                      //pc_ld = 1;
                      //pc_mux_en = 2'b00;
                      alu_mux_1_en = 2'b10;
                      alu_mux_2_en = 3'b011;
                      alu_s1_en = 0;
                      alu_s0_en = 1;
                      mem_raddr_mux_en = 2'b00;
                      set_cc_en = 1;
                      reg_rw_en = 1;
                      mem_rw_en = 0;
                      mem_rf_mux_en = 2'b01;
                      state_ld = 1;
                     
                  end
		  
                  `OC_LDI: begin
                      //pc_ld = 1;
                      //pc_mux_en = 2'b00;
                      pc_inc = 1;
                      alu_mux_1_en = 2'b10;
                      alu_mux_2_en = 3'b011;
                      alu_s1_en = 0;
                      alu_s0_en = 1;
                      mem_raddr_mux_en = 2'b00;
                      mem_rw_en = 0;
                      reg_rw_en = 0;
                  end
		  
                  `OC_LDR: begin
                      //pc_ld = 1;
                      //pc_mux_en = 2'b00;
                      pc_inc = 1;
                      alu_mux_1_en = 2'b11;
                      alu_mux_2_en = 3'b101;
                      alu_s0_en = 1;
                      alu_s1_en = 0;
                      mem_raddr_mux_en = 2'b00;
                      set_cc_en = 1;
                      reg_rw_en = 1;
                      mem_rw_en = 0;
                      mem_rf_mux_en = 2'b01;
                      reg_dr_sr_en = 1;
                  end
		  
                  `OC_LEA: begin
                      //pc_ld = 1;
                      //pc_mux_en = 2'b10;
                      pc_inc = 1;
                      alu_mux_1_en = 2'b10;
                      alu_mux_2_en = 3'b011;
                      alu_s0_en = 1;
                      alu_s1_en = 0;
                      mem_rf_mux_en = 2'b00;
                      set_cc_en = 1;
                      reg_rw_en = 1;
                  end
		  
                  `OC_NOT: begin
                      pc_inc = 1;
                      //pc_ld = 1;
                      //pc_mux_en = 2'b01;
                      alu_mux_1_en = 2'b01;
                      alu_s0_en = 1;
                      alu_s1_en = 1;
                      mem_rf_mux_en = 2'b00;
                      set_cc_en = 1;
                      reg_rw_en = 1;
                      reg_dr_sr_en = 1;
                  end
		  
                  `OC_ST: begin
                      //pc_ld = 1;
                      pc_inc = 1;
                      st_state = 1;
                      //pc_mux_en = 2'b00;
                      alu_mux_1_en = 2'b10;
                      alu_mux_2_en = 3'b011;
                      alu_s0_en = 1;
                      alu_s1_en = 0;
                      mem_rw_en = 1;
                      mem_raddr_mux_en = 2'b00;
                      reg_rw_en = 0;
                      reg_dr_sr_en = 0;
                  end
		  
                  `OC_STI: begin
                      //pc_ld = 1;
                      pc_inc = 1;
                      st_state = 1;
                      //pc_mux_en = 2'b00;
                      alu_mux_1_en = 2'b10;
                      alu_mux_2_en = 3'b011;
                      alu_s0_en = 1;
                      alu_s1_en = 0;
                      mem_rw_en = 0;
                      mem_raddr_mux_en = 2'b00;
                      reg_rw_en = 0;
                  end
		  
                  `OC_STR: begin
                      //pc_ld = 1;
                      //pc_mux_en = 2'b00;
                      st_state = 1;
                      pc_inc = 1;
                      alu_mux_1_en = 2'b11;
                      alu_mux_2_en = 3'b101;
                      alu_s0_en = 1;
                      alu_s1_en = 0;
                      mem_rw_en = 1;
                      mem_raddr_mux_en = 2'b00;
                      reg_rw_en = 0;
                      reg_dr_sr_en = 1;
                  end
		  
                  `OC_HLT: begin
                      mem_r_addr_sel = 2'b00;
                      mem_rw_en = 2'b00;
                      mem_rf_mux_en = 2'b00;
                      mem_raddr_mux_en = 2'b00;
                      
                      pc_clr = 0;
                      //pc_ld = 0;
                      pc_mux_en = 2'b00;
                       
                      alu_mux_1_en= 2'b00;
                      alu_mux_2_en = 3'b000;
                      alu_s0_en = 0;
                      alu_s1_en = 0;
                        
                      set_cc_en = 0;
                      reg_dr_sr_en = 0;
                      reg_rw_en = 0;
                  end
                  
		      endcase
		    end
		    
		    EXECUTE_2: begin
                case(ir[`OC])
                   `OC_LDI: begin
                        mem_raddr_mux_en = 2'b01;
                        mem_rw_en = 0;
                        mem_rf_mux_en = 2'b01; 
                        reg_rw_en = 1;
                        reg_dr_sr_en = 0;
                        set_cc_en = 1;
                        pc_inc = 0;
                    end
                    `OC_STI: begin
                        mem_raddr_mux_en = 2'b01;
                        mem_rw_en = 1;
                        mem_rf_mux_en = 2'b01;
                        reg_rw_en = 0;
                        set_cc_en = 0;
                        reg_dr_sr_en = 0;
                        
                    end
                    `OC_JSR: begin
                        if(ir[11]) begin
                          pc_ld = 1;
                            pc_mux_en = 2'b01;
                            alu_mux_1_en = 2'b10;
                            alu_mux_2_en = 3'b100;
                            alu_s0_en = 1;
                            alu_s1_en = 0;
                            reg_rw_en = 0;
                            jsrr_state = 1;
                      end 
                      else begin
                          pc_ld = 1;
                          pc_inc = 0;
                          reg_rw_en = 0;
                          reg_dr_sr_en = 1;
                          pc_mux_en = 2'b10;
                    end
                    end
                endcase
           end      
           HALT: begin
                  
           end
		    
	   endcase
	end

	// Next State Combinational Logic
	always @( * ) begin
		// Set default value for next state here
		// next_state = state;

		// Add your next-state logic here
		//case (state)
		//	STATE_FETCH: begin
		//
		//	end
		//endcase
		
		next_state = state;
		case (state)
		  INIT: begin
		      next_state = FETCH;
		  end
		  FETCH: begin
		      next_state = DECODE;
		  end
		  
		  DECODE: begin
		     next_state = EXECUTE_1;
		  end
		  EXECUTE_1: begin
		      if(ir[`OC] == `OC_LDI) begin
		              next_state = EXECUTE_2;
		      end
		      else if (ir[`OC] == `OC_STI) begin
		          next_state = EXECUTE_2;
		      end
		      else if(ir[`OC] === `OC_JSR) begin
		          next_state = EXECUTE_2;
		      end
		      else begin
		          next_state = FETCH;
		      end
		  end
		  EXECUTE_2: begin
		      next_state = FETCH;
		  end
		endcase
	end

	// State Update Sequential Logic
	always @(posedge clk) begin
		if (rst) begin
			// Add your initial state here
			//state <= ßSTATE_FETCH;
			state <= INIT;
		end
		else begin
			// Add your next state here
			//state <= next_state;
			state <= next_state;
		end
	end

endmodule
