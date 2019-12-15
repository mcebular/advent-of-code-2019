import strutils
import tables
import sequtils
import strformat
import math

###
### Type definitions and procedures
###

type Chemical = tuple[name: string, amount: int]

proc chemicalFromString(str: string): Chemical =
    let t = str.split(" ")
    return (name: t[1], amount: t[0].parseInt)

proc `$`(chemical: Chemical): string =
    return &"{chemical.amount} {chemical.name}"

proc `+`(chem1: Chemical, chem2: Chemical): Chemical =
    if chem1.name != chem2.name:
        raise newException(Exception, "Chemicals being added must be the same.")
    return (name: chem1.name, amount: chem1.amount + chem2.amount)

proc `-`(chem1: Chemical, chem2: Chemical): Chemical =
    if chem1.name != chem2.name:
        raise newException(Exception, "Chemicals being subtracted must be the same.")
    return (name: chem1.name, amount: chem1.amount - chem2.amount)

proc `*`(chem: Chemical, mult: int): Chemical =
    return (name: chem.name, amount: chem.amount * mult)


type Reaction = ref object of RootObj
    inputs: seq[Chemical]
    output: Chemical

proc reactionFromString(str: string): Reaction =
    let t = str.split(" => ")
    let inputs = map(t[0].split(", "), chemicalFromString)
    let output = t[1].chemicalFromString
    return Reaction(inputs: inputs, output: output)

proc `$`(reaction: Reaction): string =
    return &"{reaction.inputs} => {reaction.output}"


type Production = TableRef[string, Chemical]

proc hasOnlyOre(production: Production): bool =
    for name, chem in production.pairs:
        if chem.amount <= 0: continue
        if chem.name != "ORE":
            return false

    return true

proc addChemical(production: var Production, chemical: Chemical) =
    if not production.hasKey(chemical.name):
        production.add(chemical.name, chemical)
    else:
        production[chemical.name] = production[chemical.name] + chemical

proc removeChemical(production: var Production, chemical: Chemical) =
    production[chemical.name] = production[chemical.name] - chemical

proc process(production: var Production, reactions: TableRef[string, Reaction]) =
    var toBeAdded: seq[Chemical] = @[]
    var toBeRemoved: seq[Chemical] = @[]

    # for each chemical...
    for name, chem in production.pairs:
        if chem.amount <= 0: continue
        if chem.name == "ORE": continue

        # find a reaction...
        let reaction = reactions[name]
        # assumption: reactions involving ORE have the ORE as the only input

        # remove the reaction's output chemical from production
        let amountMult = int( ceil(chem.amount / reaction.output.amount))
        toBeRemoved.add(reaction.output * amountMult)
        # add the reaction's input chemicals
        for chem in reaction.inputs:
            toBeAdded.add(chem * amountMult)

    for chem in toBeRemoved:
        production.removeChemical(chem)
    for chem in toBeAdded:
        production.addChemical(chem)

###
### The program
###

var reactions: TableRef[string, Reaction] = newTable[string, Reaction]()

let f = open("input/day14.txt")
while not f.endOfFile():
    let line = f.readLine()
    let reaction = line.reactionFromString
    reactions.add(reaction.output.name, reaction)
f.close()

# echo reactions


var production1: Production = newTable[string, Chemical]()
production1["FUEL"] = (name: "FUEL", amount: 1)

while not production1.hasOnlyOre():
    production1.process(reactions)
    # echo production
    # echo "-----"

echo production1["ORE"] # Part 1


# Doing it the brute-force way
var oreAmount = 0

# But guessing the starting amount of fuel until I got close enough
# (i.e. start with small amount and large step and use the result as
# fuel amount and reduce the step, for the next run)
var fuelAmount = 7_993_820
var fuelStep = 1

while true:
    var production2: Production = newTable[string, Chemical]()
    production2["FUEL"] = (name: "FUEL", amount: fuelAmount + fuelStep)

    while not production2.hasOnlyOre():
        production2.process(reactions)

    if production2["ORE"].amount >= 1_000_000_000_000:
        break

    oreAmount = production2["ORE"].amount
    fuelAmount += fuelStep

echo &"With {oreAmount} ORE, {fuelAmount} FUEL can be produced."
