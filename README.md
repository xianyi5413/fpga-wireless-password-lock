# FPGA-Based Wireless Digital Password Lock

This repository contains a Verilog implementation of a wireless digital password lock with Bluetooth input support and keypad arbitration.

## Overview

The design targets a Xilinx Vivado FPGA workflow and includes:

- Password entry and verification logic
- Key debounce handling
- Keypad and Bluetooth input arbitration
- Seven-segment display output
- LED and RGB status indication
- Alarm and buzzer control
- Integration testbenches

## Project Structure

```text
02源代码/
  BLUETOOTH_INTERFANCE.v
  BLUETOOTH_INTERFACE_TB.v
  CTRL.v
  CTRL_INTEGRATION_TB.v
  CTRL_INTEGRATION_TB_behav.wcfg
  DISPLAY.v
  Elock.xpr
  KEY_JITTER.v
  RGB.v
  TOP.v
  TOP_INTEGRATION_TB.v
  Top.xdc
```

## Toolchain

- Vivado 2023.2
- Target part: `xc7a100tcsg324-1`

Open `02源代码/Elock.xpr` in Vivado to inspect, simulate, synthesize, and implement the design.

## Privacy Note

Personal reports, course reference materials, and files containing personal identifiers are intentionally excluded from this repository.
