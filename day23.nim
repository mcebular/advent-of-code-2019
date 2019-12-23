import strutils
import intcode
import strformat
import tables

###
### Type definitions and procedures
###

type Packet = tuple[x, y: int]

proc totalPackets(pq: Table[int, seq[Packet]]): int =
    var count = 0
    for a, q in pq.pairs:
        if a == 255: continue
        count += q.len
    return count

###
### The program
###

let input = readFile("input/day23.txt")

var program: seq[int] = @[]
for opcode in split(input, ','):
    program.add(parseInt(opcode))

var network: seq[IntCodeComputer]
var packetQueues: Table[int, seq[Packet]] = initTable[int, seq[Packet]]()


for i in 0..49:
    let comp = newIntCodeComputer(program)
    # give network addresses and initialize
    comp.addInput(i)
    discard comp.runProgram
    network.add(comp)

var prevNatPacket: Packet = (0, 0)
while true:

    for i in 0..49:
        let comp = network[i]
        if packetQueues.hasKey(i) and packetQueues[i].len > 0:
            # take a packet out of the queue and give it to the computer
            let packet = packetQueues[i][0]
            packetQueues[i].delete(0)
            comp.addInput(packet.x, packet.y)
        else:
            # if there's not packets, pass -1
            comp.addInput(-1)

        let (_, output) = comp.runProgram()
        # echo output
        for n in 0..<int(output.len / 3):
            let s = n * 3
            let address = output[s]
            let packet = (x: output[s + 1], y: output[s + 2])

            # echo address, " <-- ", packet
            if not packetQueues.hasKey(address): packetQueues[address] = @[]


            if address == 255:
                if packetQueues[255].len == 0: packetQueues[255].add(packet)
                else: packetQueues[255][0] = packet
            else:
                packetQueues[address].add(packet)

    if packetQueues.hasKey(255):
        if prevNatPacket == (0, 0):
            echo packetQueues[255][0].y # Part 1
        # break

    if packetQueues.totalPackets == 0:
        if not packetQueues.hasKey(0): packetQueues[0] = @[]
        packetQueues[0].add(packetQueues[255][0])

        if prevNatPacket == packetQueues[255][0]:
            echo packetQueues[255][0].y # Part 2
            break

        prevNatPacket = packetQueues[255][0]

    # echo packetQueues.totalPackets
