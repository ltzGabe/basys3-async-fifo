# Async FIFO with clock domain crossing

Dual-clock FIFO written in SystemVerilog, targeting the Basys3 (Artix-7). I made it to learn how to pass data safely between two clock domains. It's 32 entries x 16 bits, with separate write and read clocks and resets.

This repo is the FIFO and its testbench (simulation only). I've since used it on the board in my [ESP32 sensor pipeline](https://github.com/ltzGabe/basys3-esp32-ultrasensor-pipeline).

## How it works

- Read and write pointers are 6 bits: 5 address bits plus a wrap bit. The extra bit is what lets you tell full from empty when the addresses are equal.
- Before a pointer crosses to the other domain it's converted to Gray code, so only one bit changes per increment. If the synchroniser samples it mid-change you get the old or new value, never something random.
- It then goes through two flip-flops in the other clock domain and gets converted back to binary.
- Full: write address equals the synced read address and the wrap bits are different.
- Empty: read address equals the synced write address and the wrap bits are the same.
- almost_full is set at 30+ entries and almost_empty at 3 or fewer.

Since each side only sees a slightly old copy of the other pointer, full and empty can stay set for a couple of cycles longer than they need to. That's fine, it just means it can never overflow or read past the data.

## Testbench

`fifo_tb.sv` uses a 14 ns write clock and a 26 ns read clock so the two domains drift relative to each other. It runs four tests back to back:

1. Write 66 values (more than it holds), then read 66, to check full and empty both assert.
2. Write 66 and start reading halfway through, so both sides are active at once.
3. Write a few values, then reset with data still in the FIFO.
4. Start reading while it's empty, then start writing partway through.

Results are printed with `$display` and I checked them against the waveforms in the Vivado simulator. It isn't self-checking yet, so a pass means I went through the output, not that the testbench flags errors itself.

<!-- add a waveform screenshot here -->

## Bugs I fixed along the way

- The first version didn't synthesise because of an assignment placed before the reset check in an `always_ff` block.
- almost_full was asserting too late. Found it after improving the testbench.
- The full check had a timing bug from a non-blocking assignment, so it was a cycle behind. Spotted it in the waveform. Writes are now gated by the combinational full signal rather than the registered `full` output.

## Known issues / todo

- `empty` resets to 0 here when it should be 1. I found this one on hardware in the sensor pipeline and fixed it there, but haven't copied the fix back to this repo yet.
- Depth, width and the almost full/empty thresholds are hardcoded rather than parameters.
- The synchroniser flops don't have the ASYNC_REG attribute set.
- No assertions or scoreboard in the testbench.

## Running it

Open `FPGACDC/FPGACDC.xpr` in Vivado (made with 2026.1), set `fifo_tb` as the simulation top and run behavioural simulation. The testbench calls `$finish` once all four tests are done.

- `FPGACDC/FPGACDC.srcs/sources_1/new/FIFO.sv` - the FIFO
- `FPGACDC/FPGACDC.srcs/sim_1/new/fifo_tb.sv` - testbench
