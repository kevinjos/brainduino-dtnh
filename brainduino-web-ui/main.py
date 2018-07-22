import random
import time

from flask import Flask, render_template
from flask_socketio import SocketIO, send


app = Flask(__name__)
app.config['SECRET_KEY'] = 'secret!'
socketio = SocketIO(app)


class MockBrainduino:

    def __init__(self, tty='/dev/null', baud=256000):
        self.tty = tty
        self.baud = baud
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
                socketio.sleep(0.004)
            else:
                s = random.choice('0123456789ABCDEF')
                hex_ctr += 1
            yield s


def offsetBinaryToInt(hexstr, offset):
    # Perhaps we should test that the offset makes sense give the length of the hex string?
    if len(hexstr) != 6:
        return -1
    not_encoded = int(hexstr, 16)  # Make a python integer out of the hex string
    if not_encoded & 1 << offset:  # Test if the most significant bit is on == this is a positive number
        encoded = not_encoded & ~(1 << offset)
    else:
        encoded = not_encoded - 2**offset
    return encoded


b = MockBrainduino()


@socketio.on('connect')
def test_connect():
    socketio.send('connected')

    def send_data():
        while 1:
            s = b.read(14)
            s = s.strip()
            d = s.split('\t')
            d = [offsetBinaryToInt(x, 23) * 5 / 2**23 for x in d]
            socketio.send(d)
    socketio.start_background_task(send_data)


@app.route('/')
def hello():
    return render_template('main.html')


if __name__ == '__main__':
    socketio.run(app)
