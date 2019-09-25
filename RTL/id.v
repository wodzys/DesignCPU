`include "defines.v"

module id (
    input wire rst,
    input wire [`InstAddrBus] pc_i,
    input wire [`InstBus] inst_i,

    // regfile interface
    output reg reg1_read_o,
    output reg [`RegAddrBus] reg1_addr_o,
    input wire [`RegBus] reg1_data_i,

    output reg reg2_read_o,
    output reg [`RegAddrBus] reg2_addr_o,
    input wire [`RegBus] reg2_data_i,

    // 送到执行阶段的信息
    output reg [`AluOpBus] aluop_o,
    output reg [`AluSelBus] alusel_o,
    output reg [`RegBus] reg1_o,
    output reg [`RegBus] reg2_o,
    output reg [`RegAddrBus] wd_o,      // 译码阶段的指令要写入的目的寄存器地址
    output reg wreg_o                   // 译码阶段的指令是否有要写入的目的寄存器

);

    // 取得指令的功能码， 功能码
    // 对于ori指令只需要通过判断第 26-31 bit 的值，即可判断是否是 ori 指令
    wire [5:0] op = inst_i[31:26];
    wire [4:0] op2 = inst_i[10:6];
    wire [5:0] op3 = inst_i[5:0];
    wire [4:0] op4 = inst_i[20:16];

    // 保存指令执行需要的立即数
    reg [`RegBus] imm;

    // 指示指令是否有效
    reg instvalid;

    //--------------------1. 对指令进行译码--------------------//
    always @ (*)
    begin
        if(rst == `RstEnable) begin
            aluop_o <= `EXE_NOP_OP;
            alusel_o <= `EXE_RES_NOP;
            wd_o <= `NOPRegAddr;
            wreg_o <= `WriteDisable;
			instvalid <= `InstValid;
			reg1_read_o <= 1'b0;
			reg2_read_o <= 1'b0;
			reg1_addr_o <= `NOPRegAddr;
			reg2_addr_o <= `NOPRegAddr;
			imm <= 32'h0;	
        end
    end

endmodule