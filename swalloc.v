
module switch_allocator #(
    parameter integer PORTS = 5,
    parameter integer SEL_W = (PORTS > 1) ? $clog2(PORTS) : 1
)(
    input  logic clk,
    input  logic rst_n,

    // Shared permission to send through the crossbar
    input  logic credits,

    // Indicates which input FIFOs contain valid flits
    input  logic [PORTS-1:0] in_valid,

    // request[input][output]
    input  logic request [0:PORTS-1][0:PORTS-1],

    output logic [PORTS*SEL_W-1:0] xbar_sel,
    output logic [PORTS-1:0] out_fire,
    output logic [PORTS-1:0] in_pop,
    output logic [PORTS-1:0] drop
);

    logic [SEL_W-1:0] rr_current    [0:PORTS-1];
    logic [SEL_W-1:0] rr_next_state [0:PORTS-1];

    integer i, j, offset, candidate, request_count;
    logic found;

    // Request checking and round-robin selection
    always @* begin
        xbar_sel = '0;
        out_fire = '0;
        in_pop   = '0;
        drop     = '0;

        found         = 1'b0;
        candidate     = 0;
        request_count = 0;
        offset        = 0;

        if (rst_n) begin

            // Check how many outputs each input requests
            for (i = 0; i < PORTS; i = i + 1) begin
                request_count = 0;

                for (j = 0; j < PORTS; j = j + 1)
                    if (request[i][j])
                        request_count = request_count + 1;

                // Invalid request: discard this input's flit
                if (in_valid[i] && request_count > 1) begin
                    drop[i]   = 1'b1;
                    in_pop[i] = 1'b1;
                end
            end

            // Only allow crossbar transfers when credits exist
            if (credits) begin

                for (j = 0; j < PORTS; j = j + 1) begin
                    found = 1'b0;

                    // Search inputs in this output's priority order
                    for (offset = 0; offset < PORTS;
                         offset = offset + 1) begin

                        candidate = int'(rr_current[j]) + offset;

                        if (candidate >= PORTS)
                            candidate = candidate - PORTS;

                        if (!found &&
                            in_valid[candidate] &&
                            !drop[candidate] &&
                            request[candidate][j]) begin

                            xbar_sel[j*SEL_W +: SEL_W] =
                                candidate[SEL_W-1:0];

                            out_fire[j]       = 1'b1;
                            in_pop[candidate] = 1'b1;
                            found             = 1'b1;
                        end
                    end
                end
            end
        end
    end

    //next-state logic
    integer p_next;

    always @* begin
        for (p_next = 0; p_next < PORTS; p_next = p_next + 1) begin
            if (out_fire[p_next]) begin

                if (int'(xbar_sel[p_next*SEL_W +: SEL_W]) == PORTS-1)
                    rr_next_state[p_next] = '0;
                else
                    rr_next_state[p_next] =
                        xbar_sel[p_next*SEL_W +: SEL_W] + 1'b1;

            end
            else begin
                rr_next_state[p_next] = rr_current[p_next];
            end
        end
    end

    //sequential state update
    integer p_seq;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (p_seq = 0; p_seq < PORTS; p_seq = p_seq + 1)
                rr_current[p_seq] <= '0;
        end
        else begin
            for (p_seq = 0; p_seq < PORTS; p_seq = p_seq + 1)
                rr_current[p_seq] <= rr_next_state[p_seq];
        end
    end

endmodule
