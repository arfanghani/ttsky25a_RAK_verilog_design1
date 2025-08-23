module tt_um_alu_fsm (
  input wire clk,
  input wire rst_n,
  input wire ena,
  input wire [7:0] ui_in,
  input wire [7:0] uio_in,
  output reg [7:0] uo_out,
  output wire [7:0] uio_out,
  output wire [7:0] uio_oe
);

  // Internal registers
  reg [7:0] acc;
  reg [3:0] state;

  // Dummy wire to mark uio_in as used (prevents verilator UNUSEDSIGNAL warning)
  wire [7:0] unused_uio_in = uio_in;

  // Simple example FSM states
  localparam IDLE  = 4'd0;
  localparam LOAD  = 4'd1;
  localparam ADD   = 4'd2;
  localparam STORE = 4'd3;
  localparam DONE  = 4'd4;

  // For this example, uio_out and uio_oe are driven to 0 (you can modify as needed)
  assign uio_out = 8'd0;
  assign uio_oe  = 8'd0;

  // Simple FSM example logic, modify according to your real design
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      acc <= 8'd0;
      state <= IDLE;
      uo_out <= 8'd0;
    end else if (ena) begin
      case(state)
        IDLE: begin
          acc <= 8'd0;
          uo_out <= 8'd0;
          if (ui_in != 8'd0)
            state <= LOAD;
        end

        LOAD: begin
          acc <= ui_in;      // Load input into acc
          uo_out <= acc;
          state <= ADD;
        end

        ADD: begin
          acc <= acc + 8'h08; // Add constant 0x08 for demo
          uo_out <= acc;
          state <= STORE;
        end

        STORE: begin
          uo_out <= acc;     // Output acc value
          state <= DONE;
        end

        DONE: begin
          // Hold acc value and output latched
          uo_out <= acc;
          // Transition to IDLE automatically to reset for the next test cycle
          state <= IDLE;
        end

        default: state <= IDLE;
      endcase
    end
  end

endmodule
