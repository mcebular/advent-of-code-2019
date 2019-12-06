from strutils import parseInt, split
import tables

###
### Type definitions
###

type Planet = ref object of RootObj
    name: string
    orbits: Planet
    inOrbit: seq[Planet]

###
### Type procedures
###

proc `$`(planet: Planet): string = # toString
    planet.name

proc newPlanet(nname: string): Planet =
    Planet(name: nname, orbits: nil, inOrbit: @[])

proc indirectOrbitsCount(planet: Planet): int =
    var cnt = 0
    var orb = planet
    while orb.orbits != nil:
        # echo orb
        orb = orb.orbits
        cnt += 1
    return cnt

proc pathToComPlanet(planet: Planet): seq[Planet] = 
    var path: seq[Planet] = @[]
    var orb = planet
    while orb.orbits != nil:
        orb = orb.orbits
        path = orb & path
    return path

###
### The program
###

let f = open("input/day6.txt")

var galaxy: TableRef[string, Planet] = newTable[string, Planet]() # map of all planets
var comPlanet: Planet = nil

while not f.endOfFile():
    let tmp = f.readLine().split(')')
    # echo tmp

    var p1: Planet = galaxy.mgetOrPut(tmp[0], newPlanet(tmp[0]))
    var p2: Planet = galaxy.mGetOrPut(tmp[1], newPlanet(tmp[1]))

    p2.orbits = p1
    p1.inOrbit.add(p2)

    if (p1.name == "COM"):
        comPlanet = p1

f.close()

var sum = 0
for p in galaxy.values:
    sum += p.indirectOrbitsCount
echo sum # Part 1

var path1 = galaxy["YOU"].pathToComPlanet()
var path2 = galaxy["SAN"].pathToComPlanet()
var shorterLen = min(path1.len, path2.len)

var diffIndex = 0
for i in 0..<shorterLen:
    # echo path1[i], " <--> ", path2[i]
    if path1[i] != path2[i]:
        diffIndex = i
        break

# echo diffIndex

# Cut away the common path to COM
echo (path1[diffIndex..<path1.len] & path2[diffIndex..<path2.len]).len # Part 2
