module yarp_top import yarp_pkg::*; #(
  parameter RESET_PC = 32'h1000
)(
  input   logic          clk,
  input   logic          reset_n,

  // Instruction memory interface
  output  logic          instr_mem_req_o,
  output  logic [31:0]   instr_mem_addr_o,
  input   logic [31:0]   instr_mem_rd_data_i,

  // Data memory interface
  output  logic          data_mem_req_o,
  output  logic [31:0]   data_mem_addr_o,
  output  logic [1:0]    data_mem_byte_en_o,
  output  logic          data_mem_wr_o,
  output  logic [31:0]   data_mem_wr_data_o,
  input   logic [31:0]   data_mem_rd_data_i

);

  // --------------------------------------------------------
  // Internal signals
  // --------------------------------------------------------
  logic [31:0]  imem_dec_instr;
  logic [4:0]   dec_rf_rs1;
  logic [4:0]   dec_rf_rs2;
  logic [4:0]   dec_rf_rd;
  logic [31:0]  rf_rs1_data;
  logic [31:0]  rf_rs2_data;
  logic [31:0]  rf_wr_data;
  logic [31:0]  alu_opr_a;
  logic [31:0]  alu_opr_b;
  logic [31:0]  data_mem_rd_data;
  logic [31:0]  nxt_seq_pc;
  logic [31:0]  nxt_pc;
  logic [31:0]  pc_q;
  logic [6:0]   dec_ctl_opcode;
  logic [2:0]   dec_ctl_funct3;
  logic [6:0]   dec_ctl_funct7;
  logic         r_type_instr;
  logic         i_type_instr;
  logic         s_type_instr;
  logic         b_type_instr;
  logic         u_type_instr;
  logic         j_type_instr;
  logic [31:0]  dec_instr_imm;
  logic [3:0]   ctl_alu_func;
  logic [31:0]  ex_alu_res;
  logic         ctl_pc_sel;
  logic         ctl_op1sel;
  logic         ctl_op2sel;
  logic         ctl_data_req;
  logic         ctl_data_wr;
  logic [1:0]   ctl_data_byte;
  logic [1:0]   ctl_rf_wr_data;
  logic         ctl_rf_wr_en;
  logic         ctl_zero_extnd;
  logic         branch_taken;
  logic         reset_seen_q;

  `ifdef YARP_VAL
    logic [31:0] [31:0] regfile;
    assign regfile = u_yarp_regfile.regfile;
  `endif

  // --------------------------------------------------------
  // Main logic
  // --------------------------------------------------------
  // Capture the first cycle out of reset
  always_ff @ (posedge clk or negedge reset_n) begin
    if (!reset_n) begin
      reset_seen_q <= 1'b0;
    end else begin
      reset_seen_q <= 1'b1;
    end
  end

  // Program Counter logic
  assign nxt_seq_pc = pc_q + 32'h4;
  assign nxt_pc = (branch_taken | ctl_pc_sel) ? {ex_alu_res[31:1], 1'b0} :
                                                nxt_seq_pc;

  always_ff @ (posedge clk or negedge reset_n) begin
    if (!reset_n) begin
      pc_q <= RESET_PC;
    end else if (reset_seen_q) begin
      pc_q <= nxt_pc;
    end
  end

  // --------------------------------------------------------
  // Instruction Memory
  // --------------------------------------------------------
  yarp_instr_mem u_yarp_instr_mem (
    .clk                      (clk),
    .reset_n                  (reset_n),
    .instr_mem_pc_i           (pc_q),
    .instr_mem_req_o          (instr_mem_req_o),
    .instr_mem_addr_o         (instr_mem_addr_o),
    .mem_rd_data_i            (instr_mem_rd_data_i),
    .instr_mem_instr_o        (imem_dec_instr)
  );

  // --------------------------------------------------------
  // Instruction Decode
  // --------------------------------------------------------
  yarp_decode u_yarp_decode (
    .instr_i                  (imem_dec_instr),
    .rs1_o                    (dec_rf_rs1),
    .rs2_o                    (dec_rf_rs2),
    .rd_o                     (dec_rf_rd),
    .op_o                     (dec_ctl_opcode),
    .funct3_o                 (dec_ctl_funct3),
    .funct7_o                 (dec_ctl_funct7),
    .r_type_instr_o           (r_type_instr),
    .i_type_instr_o           (i_type_instr),
    .s_type_instr_o           (s_type_instr),
    .b_type_instr_o           (b_type_instr),
    .u_type_instr_o           (u_type_instr),
    .j_type_instr_o           (j_type_instr),
    .instr_imm_o              (dec_instr_imm)
  );

  // --------------------------------------------------------
  // Register File
  // --------------------------------------------------------
  // Register File write data
  assign rf_wr_data = (ctl_rf_wr_data == ALU) ? ex_alu_res :
                      (ctl_rf_wr_data == MEM) ? data_mem_rd_data :
                      (ctl_rf_wr_data == IMM) ? dec_instr_imm :
                                                nxt_seq_pc;
  yarp_regfile u_yarp_regfile (
    .clk                      (clk),
    .reset_n                  (reset_n),
    .rs1_addr_i               (dec_rf_rs1),
    .rs2_addr_i               (dec_rf_rs2),
    .rd_addr_i                (dec_rf_rd),
    .wr_en_i                  (ctl_rf_wr_en),
    .wr_data_i                (rf_wr_data),
    .rs1_data_o               (rf_rs1_data),
    .rs2_data_o               (rf_rs2_data)
  );

  // --------------------------------------------------------
  // Control Unit
  // --------------------------------------------------------
  yarp_control u_yarp_control (
    .instr_funct3_i           (dec_ctl_funct3),
    .instr_funct7_bit5_i      (dec_ctl_funct7[5]),
    .instr_opcode_i           (dec_ctl_opcode),
    .is_r_type_i              (r_type_instr),
    .is_i_type_i              (i_type_instr),
    .is_s_type_i              (s_type_instr),
    .is_b_type_i              (b_type_instr),
    .is_u_type_i              (u_type_instr),
    .is_j_type_i              (j_type_instr),
    .pc_sel_o                 (ctl_pc_sel),
    .op1sel_o                 (ctl_op1sel),
    .op2sel_o                 (ctl_op2sel),
    .data_req_o               (ctl_data_req),
    .data_wr_o                (ctl_data_wr),
    .data_byte_o              (ctl_data_byte),
    .zero_extnd_o             (ctl_zero_extnd),
    .rf_wr_en_o               (ctl_rf_wr_en),
    .rf_wr_data_o             (ctl_rf_wr_data),
    .alu_func_o               (ctl_alu_func)
  );

  // --------------------------------------------------------
  // Branch Control
  // --------------------------------------------------------
  yarp_branch_control u_yarp_branch_control (
    .opr_a_i                  (rf_rs1_data),
    .opr_b_i                  (rf_rs2_data),
    .is_b_type_ctl_i          (b_type_instr),
    .instr_func3_ctl_i        (dec_ctl_funct3),
    .branch_taken_o           (branch_taken)
  );

  // --------------------------------------------------------
  // Execute Unit
  // --------------------------------------------------------
  // ALU operand mux
  assign alu_opr_a = ctl_op1sel ? pc_q : rf_rs1_data;
  assign alu_opr_b = ctl_op2sel ? dec_instr_imm : rf_rs2_data;

  yarp_execute u_yarp_execute (
    .opr_a_i                  (alu_opr_a),
    .opr_b_i                  (alu_opr_b),
    .op_sel_i                 (ctl_alu_func),
    .alu_res_o                (ex_alu_res)
  );

  // --------------------------------------------------------
  // Data Memory
  // --------------------------------------------------------
  yarp_data_mem u_yarp_data_mem (
    .clk                      (clk),
    .reset_n                  (reset_n),
    .data_req_i               (ctl_data_req),
    .data_addr_i              (ex_alu_res),
    .data_byte_en_i           (ctl_data_byte),
    .data_wr_i                (ctl_data_wr),
    .data_wr_data_i           (rf_rs2_data),
    .data_zero_extnd_i        (ctl_zero_extnd),
    .data_mem_req_o           (data_mem_req_o),
    .data_mem_addr_o          (data_mem_addr_o),
    .data_mem_byte_en_o       (data_mem_byte_en_o),
    .data_mem_wr_o            (data_mem_wr_o),
    .data_mem_wr_data_o       (data_mem_wr_data_o),
    .mem_rd_data_i            (data_mem_rd_data_i),
    .data_mem_rd_data_o       (data_mem_rd_data)
  );

endmodule