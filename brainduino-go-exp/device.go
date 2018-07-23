package main

import (
	"fmt"
	"math/rand"
	"time"
)

var hexbytes [16]byte = [16]byte{'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'}

type MockBrainduino struct {
	mockDataStream chan byte
}

func (mb *MockBrainduino) Read(b []byte) (n int, err error) {
	for idx, _ := range b {
		b[idx] = <-mb.mockDataStream
	}
	return 1, nil
}

func (mb *MockBrainduino) Write(b []byte) (n int, err error) {
	return len(b), nil
}

func (mb *MockBrainduino) Close() (err error) {
	return nil
}

func mockData(stream chan byte) {
	hex_ctr := 0
	var b byte
	for {
		switch hex_ctr {
		default:
			b = hexbytes[rand.Intn(16)]
			hex_ctr++
		case 6:
			b = '\t'
			hex_ctr++
		case 13:
			b = '\n'
			hex_ctr = 0
			time.Sleep(4 * time.Millisecond)
		}
		stream <- b
	}
}

func main() {
	mds := make(chan byte)
	go mockData(mds)
	mbd := &MockBrainduino{
		mockDataStream: mds,
	}
	b := make([]byte, 14*16)
	for {
		mbd.Read(b)
		fmt.Printf("%s", b)
	}
}
