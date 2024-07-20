module yarp_execute import yarp_pkg::*; (
  // Source operands
  input   logic [31:0] opr_a_i,
  input   logic [31:0] opr_b_i,

  // ALU Operation
  input   logic [3:0]  op_sel_i,

  // ALU output
  output  logic [31:0] alu_res_o
);

  // --------------------------------------------------------
  // Internal wire and regs
  // --------------------------------------------------------
  logic [31:0] twos_compl_a;
  logic [31:0] twos_compl_b;

  logic [31:0] alu_res;

  assign twos_compl_a = opr_a_i[31] ? ~opr_a_i + 32'h1 : opr_a_i;
  assign twos_compl_b = opr_b_i[31] ? ~opr_b_i + 32'h1 : opr_b_i;

  always_comb begin
    case (op_sel_i)
      OP_ADD  : alu_res = opr_a_i + opr_b_i;
      OP_SUB  : alu_res = opr_a_i - opr_b_i;
      OP_SLL  : alu_res = opr_a_i << opr_b_i[4:0];
      OP_SRL  : alu_res = opr_a_i >> opr_b_i[4:0];
      OP_SRA  : alu_res = $signed(opr_a_i) >>> opr_b_i[4:0];
      // (opr_a_i >> opr_b_i[4:0]) | ({32{opr_a_i[31]}} & ~(32'hFFFFFFFF>>opr_b_i[4:0]));
      OP_OR   : alu_res = opr_a_i | opr_b_i;
      OP_AND  : alu_res = opr_a_i & opr_b_i;
      OP_XOR  : alu_res = opr_a_i ^ opr_b_i;
      OP_SLTU : alu_res = {31'h0, opr_a_i < opr_b_i};
      OP_SLT  : alu_res = {31'h0, twos_compl_a < twos_compl_b};
      default : alu_res = 32'h0;
    endcase
  end

  assign alu_res_o = alu_res;

endmodule
