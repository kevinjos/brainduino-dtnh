package main

import (
	"bytes"
	"fmt"
	"io"
	"time"

	"github.com/jacobsa/go-serial/serial"
)

type Device interface {
	io.ReadWriteCloser
	RegisterListener(string, chan Sample)
}

type Sample struct {
	Channels       []float64
	Timestamp      time.Time
	SequenceNumber uint
}

type Brainduino struct {
	io.ReadWriteCloser
	offsethighbit int
	numchan       int
	wordsize      int
	readchan      chan Sample
	listeners     map[string]chan Sample
}

func (b *Brainduino) adcnorm(raw int) float64 {
	return float64(raw) * 5.0 / float64(b.offsethighbit)
}

func (b *Brainduino) offsetBinaryToInt(hexstr []byte) int {
	var x int

	buf := bytes.NewBuffer(hexstr)
	_, err := fmt.Fscanf(buf, "%x", &x)
	if err != nil {
		fmt.Printf("Error scanning buffer in offsetBinaryToInt: %s\n", err)
		return int(b.offsethighbit)
	}

	if x&b.offsethighbit == 0 {
		x -= b.offsethighbit
	} else {
		x = x & ^b.offsethighbit
	}

	return x
}

func (b *Brainduino) readloop() {
	buf := make([]byte, 42)
	chan0 := make([]byte, b.wordsize)
	chan1 := make([]byte, b.wordsize)

	firsthalf := true
	ctr := 0

	ts := time.Now()
	var seqnum uint
	var chan0raw int
	var chan1raw int
	for {
		n, err := b.Read(buf)
		ts = time.Now()
		if err != nil {
			fmt.Printf("Failed to read brainduino: %s\n", err)
			continue
		}
		for _, val := range buf[:n] {
			if val == '\r' {
				sample := Sample{
					Channels:       make([]float64, 0),
					Timestamp:      ts,
					SequenceNumber: seqnum,
				}
				chan0raw = b.offsetBinaryToInt(chan0)
				chan1raw = b.offsetBinaryToInt(chan1)
				sample.Channels = append(sample.Channels, b.adcnorm(chan0raw))
				sample.Channels = append(sample.Channels, b.adcnorm(chan1raw))
				b.readchan <- sample
				seqnum++
				chan0 = []byte{'\x00', '\x00', '\x00', '\x00', '\x00', '\x00'}
				chan1 = []byte{'\x00', '\x00', '\x00', '\x00', '\x00', '\x00'}
				ctr = 0
				firsthalf = true
			} else if val == '\t' {
				firsthalf = false
				ctr = 0
			} else if firsthalf {
				chan0[ctr] = val
				ctr++
			} else {
				chan1[ctr] = val
				ctr++
			}
		}
	}

}

func (b *Brainduino) broadcast() {
	for {
		sample := <-b.readchan
		for name, listener := range b.listeners {
			select {
			case listener <- sample:
				continue
			default:
				fmt.Printf("Listener stuck: %s\n", name)
			}
		}
	}
}

func (b Brainduino) RegisterListener(name string, listener chan Sample) {
	b.listeners[name] = listener
}

func NewBrainduino(path string) (Device, error) {
	device, err := serial.Open(serial.OpenOptions{
		PortName:              path,
		BaudRate:              230400,
		InterCharacterTimeout: 100, // In milliseconds
		MinimumReadSize:       14,  // In bytes
	})
	c := make(chan Sample)
	brainduino := Brainduino{
		ReadWriteCloser: device,
		offsethighbit:   1 << 23,
		wordsize:        6,
		numchan:         2,
		readchan:        c,
	}
	go brainduino.readloop()
	go brainduino.broadcast()
	return brainduino, err
}

func newMockBrainduino(datastream chan byte) (*Brainduino, error) {
	c := make(chan Sample)
	brainduino := &Brainduino{
		ReadWriteCloser: mockDevice{
			datastream: datastream,
		},
		offsethighbit: 1 << 23,
		wordsize:      6,
		numchan:       2,
		readchan:      c,
		listeners:     make(map[string]chan Sample),
	}
	go brainduino.readloop()
	go brainduino.broadcast()
	return brainduino, nil
}

type mockDevice struct {
	datastream chan byte
}

func (md mockDevice) Read(buf []byte) (int, error) {
	n := 0
	for buf[n] = range md.datastream {
		n++
	}
	return n, nil
}

func (md mockDevice) Write(buf []byte) (int, error) {
	return 0, nil
}

func (md mockDevice) Close() error {
	close(md.datastream)
	return nil
}
