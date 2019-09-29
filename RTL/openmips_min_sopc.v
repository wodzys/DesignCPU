`include "defines.v"

module openmips_min_sopc (
    input wire clk,
    input wire rst
);

    wire [`InstAddrBus] inst_addr;
    wire [`InstBus] inst;
    wire rom_ce;

    openmips u_openmips (
        .clk           (clk),
        .rst           (rst),
        .rom_data_i    (inst),
        .rom_addr_o    (inst_addr),
        .rom_ce_o      (rom_ce)
    );

    inst_rom u_inst_rom (
        .ce      (rom_ce),
        .addr    (inst_addr),
        .inst    (inst)
    );
    
endmodule