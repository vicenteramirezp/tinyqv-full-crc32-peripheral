<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

The peripheral index is the number TinyQV will use to select your peripheral.  You will pick a free
slot when raising the pull request against the main TinyQV repository, and can fill this in then.  You
also need to set this value as the PERIPHERAL_NUM in your test script.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

# CRC32 Peripheral

Author: Vicente Ramirez

Peripheral index: nn

## What it does

The peripheral is a configurable CRC engine designed to handle byte-oriented data streams. It receives incoming bytes, stores them in an internal FIFO buffer, and applies a Cyclic Redundancy Check (CRC) algorithm to the complete sequence.

The module supports configuration of the polynomial, reflection (RefIn/RefOut), and XOR output parameters, allowing compatibility with multiple CRC standards and paradigms. This flexibility makes it suitable for a wide range of protocols and validation schemes.

## Register map

Document the registers that are used to interact with your peripheral

| Address | Name             | Access | Description                                                         |
|---------|------------------|--------|---------------------------------------------------------------------|
| 0x00    | Enable register  | R/W    | When its value is 32'd 1 it signals that following bytes written in the data\_in register should be taken in account for the current crc conversion, when it falls it signals the end of conversion and that the peripheral should write in the data\_out register
| 0x04    | Config register  | W    | If Config[0] is high Refin and RefOut are True, if its Low they are False. If Config[1] is high the resulting value of the CRC algorithm has an Xor operation with 32'hFFFF_FFFF, otherwise its made with 32'h0000_0000.If  Config[2] is high the Initial value of the CRC Register is set to  32'hFFFF_FFFF, else its 32'h0000_0000|
| 0x0C   | Output_data  | R    | Output data register, it stores the current finished value of the CRC.|
| 0x10   | Poly  | R/W    | Generator polynomial, its default value is 32'h04C11DB7 (Asociated with ISO-HDLC)|



## How to test

The standard way to verify a CRC implementation is to use the reference input string "123456789". This sequence is widely adopted as the canonical test vector for CRC algorithms. Simply feed this string to your peripheral and compare the computed CRC value against the expected result (e.g., from a trusted CRC calculator or reference implementation).

## External hardware

There is no external Hardware necesary
