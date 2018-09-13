package main

import (
	"bytes"
	"fmt"
	"github.com/kataras/iris"
	"github.com/kataras/iris/websocket"
	"github.com/tarm/serial"
	"time"
)

const highbit24 = 1 << 23
const url = "0.0.0.0:8080"
const indexfile = "./static/webxr1.html"
const brainduinopath = "/dev/rfcomm0"

func offsetBinaryToInt(hexstr []byte) int {
	/*
		foo, _ := offsetBinaryToInt([]byte("ffffff"))
		fmt.Printf("%d\n", foo) // 8388607
		foo, _ = offsetBinaryToInt([]byte("000000"))
		fmt.Printf("%d\n", foo) // -8388608
		foo, _ = offsetBinaryToInt([]byte("800001"))
		fmt.Printf("%d\n", foo) // 1
		foo, _ = offsetBinaryToInt([]byte("7fffff"))
		fmt.Printf("%d\n", foo) // -1
	*/

	var x int

	buf := bytes.NewBuffer(hexstr)
	_, err := fmt.Fscanf(buf, "%x", &x)
	if err != nil {
		return 42
	}

	if x&highbit24 == 0 {
		x -= highbit24
	} else {
		x = x & ^highbit24
	}

	return x
}

func rootHandler(ctx iris.Context) {
	// hmmmm.... maybe not this relative path
	ctx.ServeFile(indexfile, false)
}

func wsHandler(c websocket.Connection) {
	fmt.Printf("websocket connection established with identifier: %s\n", c.ID())
}

func readloop(brainduino *serial.Port, websocket *websocket.Server) {
	buf := make([]byte, 16)
	chan0 := make([]byte, 6)
	chan1 := make([]byte, 6)
	firsthalf := true
	n := 0
	for {
		b, err := brainduino.Read(buf)
		if err != nil {
			fmt.Errorf("Failed to read brainduino: %s\n", err)
		}
		// fmt.Printf("Read %d bytes from brainduino\n", b)
		// fmt.Printf("%q\n", buf)
		for _, val := range buf[:b] {
			if val == '\r' {
				// fmt.Printf("Chan0=[%d], Chan1=[%d]\n", offsetBinaryToInt(chan0), offsetBinaryToInt(chan1))
				msg := fmt.Sprintf("Chan0=[%d], Chan1=[%d]\n", offsetBinaryToInt(chan0), offsetBinaryToInt(chan1))
				cxns := websocket.GetConnections()
				for _, cxn := range cxns {
					err = cxn.EmitMessage([]byte(msg))
					if err != nil {
						fmt.Printf("Error sending message on websocket: %s\n", err)
					}
				}
				chan0 = []byte{'\x00', '\x00', '\x00', '\x00', '\x00', '\x00'}
				chan1 = []byte{'\x00', '\x00', '\x00', '\x00', '\x00', '\x00'}
				n = 0
				firsthalf = true
			} else if val == '\t' {
				firsthalf = false
				n = 0
			} else if firsthalf {
				chan0[n] = val
				n++
			} else {
				chan1[n] = val
				n++
			}
		}
	}
}

func main() {
	app := iris.New()

	// set up http routes
	app.Get("/", rootHandler)

	// set up web-socket routes
	ws := websocket.New(websocket.Config{
		ReadBufferSize:  1024,
		WriteBufferSize: 1024,
	})
	ws.OnConnection(wsHandler)
	app.Get("/ws", ws.Handler())

	// init brainduino
	c := &serial.Config{
		Name:        brainduinopath,
		Baud:        230400,
		ReadTimeout: time.Second * 10,
	}
	s, err := serial.OpenPort(c)
	if err != nil {
		fmt.Errorf("Failed to open brainduino: %s\n", err)
	}

	go readloop(s, ws)

	app.Run(iris.Addr(url))
}
