from strutils import parseInt, split
import strformat

###
### Type definitions
###

const 
    width = 25
    height = 6
    imageSize = 25 * 6
    Black = 0
    White = 1
    Trnsp = 2 

###
### Type procedures
###

###
### Utility procedures
###

proc countDigits(layer: string): (int, int, int) =
    var
        d0 = 0
        d1 = 0
        d2 = 0
    for c in layer:
        case c
        of '0': 
            d0 += 1
        of '1': 
            d1 += 1
        of '2':
            d2 += 1
        else:
            discard 

    return (d0, d1, d2)

proc draw[S](image: array[S, int]) =
    for i, a in image:
        case a
        of Black: stdout.write("█")
        of White: stdout.write(" ")
        of Trnsp: stdout.write("░")
        else: discard

        if i mod width == width-1:
            stdout.write("\n")

###
### The program
###

let input = readFile("input/day8.txt")

let layerCount = int(input.len / imageSize)

var layers: seq[string] = @[]

for i in 0..<layerCount:
    let j = i * imageSize
    layers.add(input.substr(j, j + imageSize - 1))


var fewestZerosIndex = 0
var fewestZeros = imageSize
for index, layer in layers:
    let (d0, _, _) = layer.countDigits
    if d0 < fewestZeros:
        fewestZeros = d0
        fewestZerosIndex = index

let (_, d1, d2) = layers[fewestZerosIndex].countDigits
echo d1 * d2 # Part 1

var image: array[imageSize, int]
for i, a in image: # initialize image with transparent pixels
    image[i] = Trnsp

for li in 0..<layerCount:
    let layer = layers[li]
    for i, a in image:
        case a
        of Black: discard
        of White: discard
        of Trnsp: image[i] = (&"{layer[i]}").parseInt # overwrite with value of layer above
        else: discard

image.draw # Part 2