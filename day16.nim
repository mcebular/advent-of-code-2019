import strutils
import sequtils
import strformat
import strutils

###
### The program
###

proc charToInt(c: char): int =
    return (c&"").parseInt

proc extend(pattern: seq[int], repeat: int, length: int): seq[int] =
    var res: seq[int] = @[]
    while res.len < length+1:
        for n in pattern:
            for i in 0..repeat:
                res.add(n)

    return res[1..length]

proc FFT(signal: seq[int], basePattern: seq[int], phases: int): seq[int] =
    var output = signal
    for i in 0..<phases:
        let input = output
        for i in 0..<input.len:
            let pattern = basePattern.extend(i, signal.len)
            output[i] = foldl(zip(input, pattern), a + (b.a * b.b), 0)
        output = map(output, proc(x: int): int = (let xs = &"{x}"; return xs[xs.len-1].charToInt))
    return output

proc toString(signal: seq[int]): string =
    return foldl(signal, &"{a}{b}", "")

let input = map(readFile("input/day16.txt"), proc(x: char): int = (x&"").parseInt)

let basePattern = @[0, 1, 0, -1]

echo input.FFT(basePattern, 100).toString[0..<8] # Part 1

#
# The idea in Part 2 is that we only compute the FFT of the second half of the signal.
# Conveniently, the pattern for the 2nd part of the signal is a matrix that looks like:
#
# 1 1 1 1
# 0 1 1 1
# 0 0 1 1
# 0 0 0 1
#
# That's an upper triangual matrix, consisting of only ones!
# If we have half-a-signal of length 4:
# [A, B, C, D]
#
# we can quickly calculate the FFT
# D = 0 * A + 0 * B + 0 * C + 1 * D
# C = 0 * A + 0 * B + 1 * C + 1 * D
# B = 0 * A + 1 * B + 1 * C + 1 * D
# A = 1 * A + 1 * B + 1 * C + 1 * D
#
# Of course, we can do that due to the fact that the position of the actual message
# (the puzzle answer) is positioned somewhere in the 2nd half of the signal.
#

var messagePosition = input[0..<7].toString.parseInt
var signal: seq[int] = @[]
for i in 0..<10_000:
    signal.add(input)

# echo "Signal length: ", signal.len
# echo "Message position: ", messagePosition

messagePosition = messagePosition - int(signal.len / 2)
signal = signal[int(signal.len / 2)..<signal.len]

# echo "Half signal length: ", signal.len
# echo "New message position: ", messagePosition

for i in 0..<100:
    var stepSum = 0
    for j in countdown(signal.len - 1, 0):
        stepSum = (stepSum + signal[j]) mod 10
        signal[j] = stepSum

echo signal[messagePosition..messagePosition+7].toString