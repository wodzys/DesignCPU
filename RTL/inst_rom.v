`include "defines.v"

module inst_rom(
    input wire ce,
    input wire [`InstAddrBus] addr,
    output reg [`InstBus] inst
);

    reg [`InstBus] inst_mem[0:`InstMemNum-1];

    initial $readmemh ("../RTL/rom.data", inst_mem);

    always @ (*)
    begin
        if(ce == `ChipDisable) begin
            inst <= 32'h0;
        end
        else begin
            inst <= inst_mem[addr[`InstMemNumLog2+1:2]];
        end
    end

endmodule