import asyncio

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

def adc2volts(i):
    return i * 5 / 2**23

async def brains(websocket, path):
    """
    Example Brainduino serial stream:

    F80F19\t7801F4\rF80F19\t7801F4\rF80F19\t7801F4\r
    """
    s = serial.Serial("/dev/rfcomm0", baudrate=230400)
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

start_server = websockets.serve(brains, '127.0.0.1', 5678)

asyncio.get_event_loop().run_until_complete(start_server)
asyncio.get_event_loop().run_forever()
