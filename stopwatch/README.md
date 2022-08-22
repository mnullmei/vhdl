# VHDL stopwatch

A simple stopwatch in VHDL for the BASYS 3 educational FPGA board.

## Description

The board's 4-digit 7-segment row displays up to one minute in seconds, followed by a two-digit decimal fraction (resolution of one-hundredth of a second). The right button "BTNR" starts/continues the stopwatch, and the left button "BTNL" resets the time, provided that the stopwatch is not running.

The VHDL code may be of course further refactored using VDHL 'for' loops.

## Getting Started

Create a new project in Vivado and insert these source files. Straightforward examples for this are included in Digilent's on-line documentation.

### Dependencies

* Xilinx Vivado, tested with 2022/01
* BASYS 3 FPGA board from Digilent

## Version History

* 0.1
    * Initial Release

## License

This project is licensed under the MIT License.

## Acknowledgments

Loosely inspired by ideas from
* [NANDLAND](https://nandland.com)
* [FPGA4student](https://www.fpga4student.com)

