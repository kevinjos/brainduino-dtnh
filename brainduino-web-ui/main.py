<<<<<<< HEAD
import asyncio
=======
import argparse
import asyncio
import os
import random
import time

import serial
import websockets


class MockBrainduino:

    def __init__(self, tty='/dev/null', baudrate=256000):
        self.tty = tty
        self.baud = baudrate
        self.data_stream_gen = self._data_stream_gen()

    def __enter__(self):
        return self

    def __exit__(self, *args):
        self.data_stream_gen.close()
        return

    def read(self, nbytes):
        s = ''
        for i in range(nbytes):
            s += next(self.data_stream_gen)
        return s

    def flush(self):
        return None

    def _data_stream_gen(self):
        """
        Mock brainduino output:
        DEADBE\tEF0123\n
        DEADBE\tEF0123\n
        DEADBE\tEF0123\n
        """
        hex_ctr = 0
        s = ''
        while 1:
            if hex_ctr == 6:
                s = '\t'
                hex_ctr += 1
            elif hex_ctr == 13:
                s = '\n'
                hex_ctr = 0
                time.sleep(0.004)
            else:
                s = random.choice('0123456789ABCDEF')
                hex_ctr += 1
            yield s
>>>>>>> commiting

import serial
import websockets

def offsetBinaryToInt(hexstr, offset):
    if len(hexstr) != 6:
        return -1
    not_encoded = int(hexstr, 16)  # Make a python integer out of the hex string
    if not_encoded & 1 << offset:  # Test if the most significant bit is on == this is a positive number
        encoded = not_encoded & ~(1 << offset)
    else:
        encoded = not_encoded - 2**offset
    return encoded

<<<<<<< HEAD
def adc2volts(i):
    return i * 5 / 2**23

=======

def adc2volts(i):
    return i * 5 / 2**23


def findPath():
    if args.path:
        return args.path
    basepath = "/dev/rfcomm"
    for i in range(5):
        testpath = basepath + str(i)
        if os.path.exists(testpath):
            return testpath


>>>>>>> commiting
async def brains(websocket, path):
    """
    Example Brainduino serial stream:

    F80F19\t7801F4\rF80F19\t7801F4\rF80F19\t7801F4\r
    """
<<<<<<< HEAD
    s = serial.Serial("/dev/rfcomm0", baudrate=230400)
=======
    brainduino_path = findPath()
    # s = serial.Serial(brainduino_path, baudrate=230400)
    s = MockBrainduino(brainduino_path, baudrate=230400)
>>>>>>> commiting
    s.flush()
    channels = (bytearray(6), bytearray(6))
    hex_ctr = 0
    while True:
        bs = s.read(64)
        for b in bs:
            if b == ord('\r'):
                try:
                    c1, c2 = offsetBinaryToInt(channels[0], 23), offsetBinaryToInt(channels[1], 23)
                    c1, c2 = adc2volts(c1), adc2volts(c2)
                    await websocket.send("%s %s" % (c1, c2))
                except Exception:
                    await websocket.send("%s %s" % channels)
                hex_ctr = 0
            elif b == ord('\t'):
                continue
            elif hex_ctr < 6:
                channels[0][hex_ctr] = b
            elif hex_ctr > 6:
                channels[1][hex_ctr % 6] = b
            hex_ctr += 1

<<<<<<< HEAD
start_server = websockets.serve(brains, '127.0.0.1', 5678)

asyncio.get_event_loop().run_until_complete(start_server)
asyncio.get_event_loop().run_forever()
=======

def main():
    start_server = websockets.serve(brains, '127.0.0.1', 5678)

    asyncio.get_event_loop().run_until_complete(start_server)
    asyncio.get_event_loop().run_forever()


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("--path", help="path to the brainduino device")
    args = parser.parse_args()
    main()
>>>>>>> commiting
