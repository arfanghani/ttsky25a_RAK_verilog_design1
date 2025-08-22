`default_nettype none
`timescale 1ns / 1ps

module tt_um_mac (
  input wire clk,
  input wire rst_n,
  input wire ena,
  input wire [7:0] ui_in,
  input wire [7:0] uio_in,
  output reg [7:0] uo_out,
  output reg [7:0] uio_out,
  output reg [7:0] uio_oe,

  // Debug outputs for observability
  output reg [7:0] acc_debug,
  output reg [3:0] state_debug
);

  // Internal registers
  reg [7:0] acc;
  reg [3:0] state;

  // Simple example FSM states
  localparam IDLE  = 4'd0;
  localparam LOAD  = 4'd1;
  localparam ADD   = 4'd2;
  localparam STORE = 4'd3;
  localparam DONE  = 4'd4;

  // Simple FSM example logic, modify according to your real design
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      acc <= 8'd0;
      state <= IDLE;
      uo_out <= 8'd0;
      uio_out <= 8'd0;
      uio_oe <= 8'd0;
    end else if (ena) begin
      case(state)
        IDLE: begin
          acc <= 8'd0;
          uo_out <= 8'd0;
          uio_out <= 8'd0;  // Default value
          uio_oe <= 8'd0;   // Disable output
          if (ui_in != 8'd0)
            state <= LOAD;
        end

        LOAD: begin
          acc <= ui_in;      // Load input into acc
          uo_out <= acc;
          uio_out <= acc;    // Set uio_out to the acc value
          uio_oe <= 8'd1;    // Enable output
          state <= ADD;
        end

        ADD: begin
          acc <= acc + 8'h08; // Add constant 0x08 for demo
          uo_out <= acc;
          uio_out <= acc;    // Update uio_out to the new acc value
          uio_oe <= 8'd1;    // Enable output
          state <= STORE;
        end

        STORE: begin
          uo_out <= acc;     // Output acc value
          uio_out <= acc;    // Update uio_out
          uio_oe <= 8'd1;    // Enable output
          state <= DONE;
        end

        DONE: begin
          // Hold acc value and output latched
          uo_out <= acc;
          uio_out <= acc;    // Maintain the final output value
          uio_oe <= 8'd0;    // Disable output once done
          // Optional: transition back to IDLE or other state after some condition
          if (acc == 8'h00) state <= IDLE;  // Transition to IDLE after done
        end

        default: state <= IDLE;
      endcase
    end
  end

  // Drive debug outputs
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      acc_debug <= 8'd0;
      state_debug <= 4'd0;
    end else begin
      acc_debug <= acc;
      state_debug <= state;
    end
  end

endmodule
