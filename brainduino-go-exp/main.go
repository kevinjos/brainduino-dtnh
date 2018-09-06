package main

import (
	"fmt"
	"bytes"
)

const highbit24 = 1 << 23

func offsetBinaryToInt(hexstr []byte) (int, error) {
	var x int

	buf := bytes.NewBuffer(hexstr)
	_, err := fmt.Fscanf(buf, "%x", &x)
	if err != nil {
		return 0, err
	}

	if (x & highbit24 == 0) {
		x -= highbit24
	} else {
		x = x & ^highbit24
	}

	return x, nil
}

func main() {
	foo, _ := offsetBinaryToInt([]byte("ffffff"))
	fmt.Printf("%d\n", foo) // 8388607
	foo, _ = offsetBinaryToInt([]byte("000000"))
	fmt.Printf("%d\n", foo) // -8388608
	foo, _ = offsetBinaryToInt([]byte("800001"))
	fmt.Printf("%d\n", foo) // 1
	foo, _ = offsetBinaryToInt([]byte("7fffff"))
	fmt.Printf("%d\n", foo) // -1
}
