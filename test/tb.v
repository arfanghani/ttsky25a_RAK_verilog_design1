`default_nettype none
`timescale 1ns / 1ps

module tb ();

  // Dump signals for waveform viewing with GTKWave
  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);
  end

  // Declare signals
  reg clk;
  reg rst_n;
  reg ena;
  wire [7:0] ui_in;
  wire [7:0] uio_in;
  reg  [7:0] ui_in_reg;
  reg  [7:0] uio_in_reg;
  wire [7:0] uo_out;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;
  
  // Declare state variable for FSM state monitoring
  reg [3:0] state;

  // Gate-level power pins
`ifdef GL_TEST
  wire VPWR = 1'b1;
  wire VGND = 1'b0;
`endif

  // Instantiate the DUT (Device Under Test)
  tt_um_alu_fsm user_project (
`ifdef GL_TEST
    .VPWR(VPWR),
    .VGND(VGND),
`endif
    .ui_in(ui_in),
    .uo_out(uo_out),
    .uio_in(uio_in),
    .uio_out(uio_out),
    .uio_oe(uio_oe),
    .ena(ena),
    .clk(clk),
    .rst_n(rst_n)
  );

  // Drive wires from regs
  assign ui_in   = ui_in_reg;
  assign uio_in  = uio_in_reg;

  // Clock generation (50 MHz, 20 ns period)
  initial begin
    clk = 0;
    forever #10 clk = ~clk;  // Adjusted for 50 MHz (20 ns period)
  end

  // Test stimulus
  initial begin
    rst_n = 0;
    ena = 1;
    ui_in_reg = 8'b00000000;
    uio_in_reg = 8'b00000000;
    #20;  // Wait 20 ns for reset
    rst_n = 1;

    // Example input program stimulus (your FSM input sequence)
    ui_in_reg = 8'h41;
    #20;  // Wait 20 ns for 50 MHz
    ui_in_reg = 8'h42;
    #20;
    ui_in_reg = 8'h81;
    #20;
    ui_in_reg = 8'h82;
    #20;
    ui_in_reg = 8'hC0;
    #20;
    ui_in_reg = 8'h44;
    #20;
    ui_in_reg = 8'h83;
    #20;
    ui_in_reg = 8'hC0;
    #20;
    ui_in_reg = 8'h00;
    #20;
    ui_in_reg = 8'h00;
    #20;  // Wait extra cycles to allow simulator to finish

    // Monitor FSM state and output
    $display("Simulation finished. Final uo_out: %02x", uo_out);
  end

  // Output monitoring
  initial begin
    $monitor("Time=%0t | ui_in=%02x | uo_out=%02x | uio_out=%02x | uio_oe=%02x | state=%0d",
             $time, ui_in, uo_out, uio_out, uio_oe, state);
  end

  // FSM state tracking for monitoring purposes
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state <= 4'd0; // Reset state
    end else if (ena) begin
      // FSM state machine monitoring for debug
      case (state)
        4'd0: state <= (ui_in != 8'd0) ? 4'd1 : 4'd0; // IDLE -> LOAD
        4'd1: state <= 4'd2; // LOAD -> ADD
        4'd2: state <= 4'd3; // ADD -> STORE
        4'd3: state <= 4'd4; // STORE -> DONE
        4'd4: state <= 4'd0; // DONE -> IDLE (to reset FSM)
        default: state <= 4'd0;
      endcase
    end
  end

endmodule
