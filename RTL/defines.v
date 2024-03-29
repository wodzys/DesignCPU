//***************全局的宏定义***************//
`define RstEnable       1'b1                // 复位信号有效
`define RstDisable      1'b0                // 复位信号无效
`define ZeroWord        32'h0000_0000        // 32位的数值0
`define WriteEnable     1'b1                // 使能写
`define WriteDisable    1'b0
`define ReadEnable      1'b1
`define ReadDisable     1'b0
`define AluOpBus        7:0                 // 译码阶段的指令要进行的运算的子类型
`define AluSelBus       2:0                 // 译码阶段的指令要警醒的运算的类型
`define InstValid       1'b0
`define InstInValid     1'b1
`define True_v          1'b1
`define False_v         1'b0
`define ChipEnable      1'b1
`define ChipDisable     1'b0                //表示指令存储器禁用

//***************************** 与具体指令有关的宏定义 *****************************//
`define EXE_ORI         6'b00_1101           // 指令 ori 的指令码
`define EXE_NOP         6'b00_0000           //

// AluOp
`define EXE_OR_OP       8'b0010_0101
`define EXE_NOP_OP      8'b0000_0000

// AluSel
`define EXE_RES_LOGIC   3'b001
`define EXE_RES_NOP     3'b000

//***************************** 与指令存储器 ROM 有关的宏定义 *****************************//
`define InstAddrBus     31:0                // ROM 地址总线宽度
`define InstBus         31:0                // ROM 数据总线宽度
`define InstMemNum      4                   // ROM 的实际大小为 128KB   // Here may be a problem
`define InstMemNumLog2  2                  // ROM 实际使用的地址线宽度

//***************************** 与通用寄存器 Regfile 有关的宏定义 *****************************//
`define RegAddrBus      4:0                 // Regfile 模块的地址线宽度
`define RegBus          31:0                // Regfile 模块的数据线宽度
`define RegWidth        32                  // 通用寄存器的宽度
`define DoubleRegWidth  64                  // 两倍的通用寄存器的宽度
`define DoubleRegBus    63:0                // 两倍的通用寄存器的数据线宽度
`define RegNum          32                  // 通用寄存器的数量
`define RegNumLog2      5                   // 寻址通用寄存器使用的地址位数
`define NOPRegAddr      5'b00000
