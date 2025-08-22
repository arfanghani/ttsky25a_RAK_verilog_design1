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

  // Gate-level power pins
`ifdef GL_TEST
  wire VPWR = 1'b1;
  wire VGND = 1'b0;
`endif

  // Instantiate the DUT (Device Under Test)
  tt_um_mac user_project (
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

  // Clock generation (100 MHz)
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Test stimulus
  initial begin
    rst_n = 0;
    ena = 1;
    ui_in_reg = 8'b00000000;
    uio_in_reg = 8'b00000000;
    #10;
    rst_n = 1;

    // Example input program stimulus (your FSM input sequence)
    ui_in_reg = 8'h41;
    #10;
    ui_in_reg = 8'h42;
    #10;
    ui_in_reg = 8'h81;
    #10;
    ui_in_reg = 8'h82;
    #10;
    ui_in_reg = 8'hC0;
    #10;
    ui_in_reg = 8'h44;
    #10;
    ui_in_reg = 8'h83;
    #10;
    ui_in_reg = 8'hC0;
    #10;
    ui_in_reg = 8'h00;
    #10;
    ui_in_reg = 8'h00;
    #20;  // Wait extra cycles to allow simulator to finish

    //$display("Simulation finished. Final uo_out: %02x", uo_out);
    $stop;
  end

  // Output monitoring
  initial begin
    $monitor("Time=%0t | ui_in=%02x | uo_out=%02x | uio_out=%02x | uio_oe=%02x",
             $time, ui_in, uo_out, uio_out, uio_oe);
  end

endmodule
