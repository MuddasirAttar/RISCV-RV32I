module yarp_decode import yarp_pkg::*; (
  input   logic [31:0]  instr_i ,
  output  logic [4:0]   rs1_o,
  output  logic [4:0]   rs2_o,
  output  logic [4:0]   rd_o,
  output  logic [6:0]   op_o,
  output  logic [2:0]   funct3_o,
  output  logic [6:0]   funct7_o,
  output  logic         r_type_instr_o,
  output  logic         i_type_instr_o,
  output  logic         s_type_instr_o,
  output  logic         b_type_instr_o,
  output  logic         u_type_instr_o,
  output  logic         j_type_instr_o,
  output  logic [31:0]  instr_imm_o
);

  // --------------------------------------------------------
  // Internal wire and regs
  // --------------------------------------------------------
  logic[4:0]   rs1;
  logic[4:0]   rs2;
  logic[4:0]   rd;
  logic[6:0]   op;
  logic[2:0]   funct3;
  logic[6:0]   funct7;
  logic        r_type;
  logic        i_type;
  logic        s_type;
  logic        b_type;
  logic        u_type;
  logic        j_type;
  logic[31:0]  instr_imm;
  logic[31:0]  i_type_imm;
  logic[31:0]  s_type_imm;
  logic[31:0]  b_type_imm;
  logic[31:0]  u_type_imm;
  logic[31:0]  j_type_imm;

  assign rd     = instr_i[11:7];
  assign rs1    = instr_i[19:15];
  assign rs2    = instr_i[24:20];
  assign op     = instr_i[6:0];
  assign funct3 = instr_i[14:12];
  assign funct7 = instr_i[31:25];

  assign i_type_imm = {{20{instr_i[31]}}, instr_i[31:20]};
  assign s_type_imm = {{21{instr_i[31]}}, instr_i[30:25], instr_i[11:7]};
  assign b_type_imm = {{20{instr_i[31]}}, instr_i[7],
                       instr_i[30:25], instr_i[11:8], 1'b0};
  assign u_type_imm = {instr_i[31:12], 12'b0};
  assign j_type_imm = {{12{instr_i[31]}}, instr_i[19:12],
                       instr_i[20], instr_i[30:21], 1'b0};

  assign instr_imm = r_type ? 32'h0      :
                     i_type ? i_type_imm :
                     s_type ? s_type_imm :
                     b_type ? b_type_imm :
                     u_type ? u_type_imm :
                              j_type_imm;

  always_comb begin
    r_type = 1'b0;
    i_type = 1'b0;
    s_type = 1'b0;
    b_type = 1'b0;
    u_type = 1'b0;
    j_type = 1'b0;
    case (op)
      R_TYPE :    r_type = 1'b1;
      I_TYPE_0,
      I_TYPE_1,
      I_TYPE_2 :  i_type = 1'b1;
      S_TYPE :    s_type = 1'b1;
      B_TYPE :    b_type = 1'b1;
      U_TYPE_0,
      U_TYPE_1 :  u_type = 1'b1;
      J_TYPE :    j_type = 1'b1;
      default;
    endcase
  end

  // -------------------------------------------------------
  // Output assignments
  // --------------------------------------------------------
  assign rs1_o            = rs1;
  assign rs2_o            = rs2;
  assign rd_o             = rd;
  assign op_o             = op;
  assign funct3_o         = funct3;
  assign funct7_o         = funct7;
  assign r_type_instr_o   = r_type;
  assign i_type_instr_o   = i_type;
  assign s_type_instr_o   = s_type;
  assign b_type_instr_o   = b_type;
  assign u_type_instr_o   = u_type;
  assign j_type_instr_o   = j_type;
  assign instr_imm_o      = instr_imm;

endmodule
