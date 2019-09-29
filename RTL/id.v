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
			imm <= `ZeroWord;
        end
        else begin
            aluop_o <= `EXE_NOP_OP;
            alusel_o <= `EXE_RES_NOP;
            wd_o <= inst_i[15:11];          // 通常情况下默认保存到 rd 寄存器
            wreg_o <= `WriteDisable;
			instvalid <= `InstInValid;
			reg1_read_o <= 1'b0;
			reg2_read_o <= 1'b0;
			reg1_addr_o <= inst_i[25:21];   // 默认通过 regfile 读端口 1 的寄存器地址
			reg2_addr_o <= inst_i[20:16];   // 默认通过 regfile 读端口 2 的寄存器地址
			imm <= `ZeroWord;
        end

        case (op)
            `EXE_ORI : begin                // 依据 op 的值判断是否是 ori 指令
                wreg_o <= `WriteEnable;     // ori 指令需要将结果写入目的寄存器
                wd_o <= inst_i[20:16];      // 指令执行要写的目的寄存器地址
                aluop_o <= `EXE_OR_OP;      // 运算的子类型是逻辑“或”运算
                alusel_o <= `EXE_RES_LOGIC; // 运算类型是逻辑运算
                reg1_read_o <= 1'b1;        // 需要通过 Regfile 的读端口 1 读取寄存器
                reg2_read_o <= 1'b0;        // 不需要通过 Regfile 的读端口 2 读取寄存器
                imm <= {16'h0000, inst_i[15:0]};    // 指令执行需要的立即数
                instvalid <= `InstValid;    // ori 指令是有效指令
            end
            default: begin
            end
        endcase
    end
//--------------------------第二阶段：确定进行运算的源操作数 1 -----------------------------------//
    always @ (*)
    begin
        if(rst == `RstEnable) begin
            reg1_o <= `ZeroWord;
        end
        else if(reg1_read_o == 1'b1) begin
            reg1_o <= reg1_data_i;          // Regfile 读端口 1 的输出值
        end
        else if(reg1_read_o == 1'b0) begin
            reg1_o <= imm;                  // 立即数
        end
        else begin
            reg1_o <= `ZeroWord;
        end
    end
//--------------------------第三阶段：确定进行运算的源操作数 2 -----------------------------------//
    always @ (*)
    begin
        if(rst == `RstEnable) begin
            reg2_o <= `ZeroWord;
        end
        else if(reg2_read_o == 1'b1) begin
            reg2_o <= reg2_data_i;          // Regfile 读端口 1 的输出值
        end
        else if(reg2_read_o == 1'b0) begin
            reg2_o <= imm;                  // 立即数
        end
        else begin
            reg2_o <= `ZeroWord;
        end
    end

endmodule