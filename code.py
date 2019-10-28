from adafruit_ble.uart import UARTServer
import time
import board
from digitalio import DigitalInOut, Direction, Pull

uart = UARTServer()

FWD_PIN = DigitalInOut(board.P0_15)
REV_PIN = DigitalInOut(board.P0_17)
SLOW_PIN = DigitalInOut(board.P0_20)
FAST_PIN = DigitalInOut(board.P0_22)
FSTEP_PIN = DigitalInOut(board.P0_24)
RSTEP_PIN = DigitalInOut(board.P1_00)

Rled = DigitalInOut(board.LED2_R)
Gled = DigitalInOut(board.LED2_G)

FWD_PIN.direction = Direction.OUTPUT
REV_PIN.direction = Direction.OUTPUT
SLOW_PIN.direction = Direction.OUTPUT
FAST_PIN.direction = Direction.OUTPUT
FSTEP_PIN.direction = Direction.OUTPUT
RSTEP_PIN.direction = Direction.OUTPUT

Rled.direction = Direction.OUTPUT
Gled.direction = Direction.OUTPUT

fwd_cmd = str.encode("f")
rev_cmd = str.encode("r")
fast_cmd = str.encode("h")
slow_cmd = str.encode("l")
fstep_cmd = str.encode("u")
rstep_cmd = str.encode("d")
x_cmd = str.encode("x")

flag = True
while True:
    uart.start_advertising()

    # Wait for a connection
    while not uart.connected:
        Gled.value = True
        Rled.value = False

        FWD_PIN.value = False
        REV_PIN.value = False
        SLOW_PIN.value = False
        FAST_PIN.value = False
        FSTEP_PIN.value = False
        RSTEP_PIN.value = False
        pass

    while uart.connected:
        one_byte = uart.read(1)
        print(one_byte)

        if one_byte:
            Gled.value = False
            Rled.value = True

            print(one_byte)
            if one_byte == fwd_cmd:
                FWD_PIN.value = True
                REV_PIN.value = False
                SLOW_PIN.value = False
                FAST_PIN.value = False
                FSTEP_PIN.value = False
                RSTEP_PIN.value = False
                print("fwd command")
            elif one_byte == rev_cmd:
                FWD_PIN.value = False
                REV_PIN.value = True
                SLOW_PIN.value = False
                FAST_PIN.value = False
                FSTEP_PIN.value = False
                RSTEP_PIN.value = False
                print("rev command")
            elif one_byte == slow_cmd:
                FWD_PIN.value = False
                REV_PIN.value = False
                SLOW_PIN.value = True
                FAST_PIN.value = False
                FSTEP_PIN.value = False
                RSTEP_PIN.value = False
                print("slow command")
            elif one_byte == fast_cmd:
                FWD_PIN.value = False
                REV_PIN.value = False
                SLOW_PIN.value = False
                FAST_PIN.value = True
                FSTEP_PIN.value = False
                RSTEP_PIN.value = False
                print("fast command")
            elif one_byte == fstep_cmd:
                FWD_PIN.value = False
                REV_PIN.value = False
                SLOW_PIN.value = False
                FAST_PIN.value = False
                FSTEP_PIN.value = True
                RSTEP_PIN.value = False
                print("fstep command")
            elif one_byte == rstep_cmd:
                FWD_PIN.value = False
                REV_PIN.value = False
                SLOW_PIN.value = False
                FAST_PIN.value = False
                FSTEP_PIN.value = False
                RSTEP_PIN.value = True
                print("rstep command")

            uart.write(one_byte)

    # When disconnected, arrive here. Go back to the top
    # and start advertising again.