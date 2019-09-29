`include "defines.v"

module openmips (
    input wire clk,
    input wire rst,
    
    input wire [`RegBus] rom_data_i,
    output wire [`RegBus] rom_addr_o,
    output wire rom_ce_o
);

    // 连接 IF/ID 模块与译码阶段 ID 模块的信号
	wire [`InstAddrBus] pc;
	wire [`InstAddrBus] id_pc_i;
	wire [`InstBus] id_inst_i;
	
	//连接译码阶段ID模块的输出与ID/EX模块的输入
	wire [`AluOpBus] id_aluop_o;
	wire [`AluSelBus] id_alusel_o;
	wire [`RegBus] id_reg1_o;
	wire [`RegBus] id_reg2_o;
	wire id_wreg_o;
	wire [`RegAddrBus] id_wd_o;
	
	//连接ID/EX模块的输出与执行阶段EX模块的输入
	wire [`AluOpBus] ex_aluop_i;
	wire [`AluSelBus] ex_alusel_i;
	wire [`RegBus] ex_reg1_i;
	wire [`RegBus] ex_reg2_i;
	wire ex_wreg_i;
	wire [`RegAddrBus] ex_wd_i;
	
	//连接执行阶段EX模块的输出与EX/MEM模块的输入
	wire ex_wreg_o;
	wire [`RegAddrBus] ex_wd_o;
	wire [`RegBus] ex_wdata_o;

	//连接EX/MEM模块的输出与访存阶段MEM模块的输入
	wire mem_wreg_i;
	wire [`RegAddrBus] mem_wd_i;
	wire [`RegBus] mem_wdata_i;

	//连接访存阶段MEM模块的输出与MEM/WB模块的输入
	wire mem_wreg_o;
	wire [`RegAddrBus] mem_wd_o;
	wire [`RegBus] mem_wdata_o;
	
	//连接MEM/WB模块的输出与回写阶段的输入	
	wire wb_wreg_i;
	wire [`RegAddrBus] wb_wd_i;
	wire [`RegBus] wb_wdata_i;
	
	//连接译码阶段ID模块与通用寄存器Regfile模块
    wire reg1_read;
    wire reg2_read;
    wire [`RegBus] reg1_data;
    wire [`RegBus] reg2_data;
    wire [`RegAddrBus] reg1_addr;
    wire [`RegAddrBus] reg2_addr;

    pc_reg u_pc_reg (
        .clk    (clk),
        .rst    (rst),
        .pc     (pc),
        .ce     (rom_ce_o)
    );

    assign rom_addr_o = pc;

    if_id u_if_id (
        .clk        (clk),
        .rst        (rst),
        // 来自取指令阶段的信号，其中宏定义 InstBus 表示指令宽度，为32
        .if_pc      (pc),
        .if_inst    (rom_data_i),
        // 对应译码阶段的信号
        .id_pc      (id_pc_i),
        .id_inst    (id_inst_i)
    );

    id u_id (
        .rst            (rst),
        .pc_i           (id_pc_i),
        .inst_i         (id_inst_i),
        // regfile interface
        .reg1_read_o    (reg1_read),
        .reg1_addr_o    (reg1_addr),
        .reg1_data_i    (reg1_data),
        .reg2_read_o    (reg2_read),
        .reg2_addr_o    (reg2_addr),
        .reg2_data_i    (reg2_data),
        // 送到执行阶段的信息
        .aluop_o        (id_aluop_o),
        .alusel_o       (id_alusel_o),
        .reg1_o         (id_reg1_o),
        .reg2_o         (id_reg2_o),
        // 译码阶段的指令要写入的目的寄存器地址
        .wd_o           (id_wd_o),
        // 译码阶段的指令是否有要写入的目的寄存器
        .wreg_o         (id_wreg_o)
    );

    regfile u_regfile (
        .clk       (clk),
        .rst       (rst),
        // 写端口
        .we        (wb_wreg_i),
        .waddr     (wb_wd_i),
        .wdata     (wb_wdata_i),
        // 读端口1
        .re1       (reg1_read),
        .raddr1    (reg1_addr),
        .rdata1    (reg1_data),
        // 读端口2
        .re2       (reg2_read),
        .raddr2    (reg2_addr),
        .rdata2    (reg2_data)
    );

    id_ex u_id_ex (
        .clk          (clk),
        .rst          (rst),
        // 从译码阶段传递过来的信息
        .id_aluop     (id_aluop_o),
        .id_alusel    (id_alusel_o),
        .id_reg1      (id_reg1_o),
        .id_reg2      (id_reg2_o),
        .id_wd        (id_wd_o),
        .id_wreg      (id_wreg_o),
        // 传递到执行阶段
        .ex_aluop     (ex_aluop_i),
        .ex_alusel    (ex_alusel_i),
        .ex_reg1      (ex_reg1_i),
        .ex_reg2      (ex_reg2_i),
        .ex_wd        (ex_wd_i),
        .ex_wreg      (ex_wreg_i)
    );

    ex u_ex (
        .rst         (rst),
        // 译码阶段送到执行阶段的信息
        .aluop_i     (ex_aluop_i),
        .alusel_i    (ex_alusel_i),
        .reg1_i      (ex_reg1_i),
        .reg2_i      (ex_reg2_i),
        .wd_i        (ex_wd_i),
        .wreg_i      (ex_wreg_i),
        // 执行的结果
        .wd_o        (ex_wd_o),
        .wreg_o      (ex_wreg_o),
        .wdata_o     (ex_wdata_o)
    );

    ex_mem u_ex_mem (
        .clk          (clk),
        .rst          (rst),
        // 来自执行阶段的信息
        .ex_wd        (ex_wd_o),
        .ex_wreg      (ex_wreg_o),
        .ex_wdata     (ex_wdata_o),
        // 送到访存阶段的信息
        .mem_wd       (mem_wd_i),
        .mem_wreg     (mem_wreg_i),
        .mem_wdata    (mem_wdata_i)
    );

    mem u_mem (
        .rst          (rst),
        .wd_i         (mem_wd_i),
        .wreg_i       (mem_wreg_i),
        .wdata_i      (mem_wdata_i),

        .wd_o         (mem_wd_o),
        .wreg_o       (mem_wreg_o),
        .wdata_o      (mem_wdata_o)
    );

    mem_wb u_mem_wb (
        .clk          (clk),
        .rst          (rst),
        // 访存阶段的结果
        .mem_wd       (mem_wd_o),
        .mem_wreg     (mem_wreg_o),
        .mem_wdata    (mem_wdata_o),
        // 送到回写阶段的信息
        .wb_wd        (wb_wd_i),
        .wb_wreg      (wb_wreg_i),
        .wb_wdata     (wb_wdata_i)
    );
    
endmodule