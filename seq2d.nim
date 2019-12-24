# import strutils
import tables
# import sequtils
# import strformat
import heapqueue


type Seq2d*[T] = ref object of RootObj
    field: seq[T]
    width: int
    default: T

proc newSeq2d*[T](defaultValue: T): Seq2d[T] =
    let s = Seq2d[T]()
    s.field = newSeq[T](0)
    s.width = 0
    s.default = defaultValue
    return s

proc clone*[T](s: Seq2d[T]): Seq2d[T] =
    let c = newSeq2d(s.default)
    c.width = s.width
    c.field = s.field
    return c

proc width*(s: Seq2d): int =
    return s.width

proc width*(s: Seq2d, w: int) =
    s.width = w

proc height*(s: Seq2d): int =
    return int(s.field.len / s.width)

proc add*[T](s: Seq2d[T], value: T) =
    s.field.add(value)

proc at*[T](s: Seq2d[T], index: int): T =
    s.field[index]

proc put*[T](s: Seq2d[T], x, y: int, value: T) =
    let p = x + y * s.width
    while s.field.len <= p:
        s.field.add(s.default)
    s.field[p] = value

proc get*[T](s: Seq2d[T], x, y: int): T =
    let p = x + y * s.width
    if s.field.len < p:
        return s.default
    else:
        return s.field[p]

proc count*[T](s: Seq2d[T], value: T): int =
    var count = 0
    for v in s.field:
        if v == value:
            count += 1
    return count

proc find*[T](s: Seq2d[T], value: T): (int, int) =
    for i, v in s.field:
        if v == value:
            let x = i mod s.getWidth()
            let y = int(i / s.getWidth())
            return (x, y)
    return (-1, -1)

proc print*[T](s: Seq2d[T], draw: proc(v: T): string = nil) =
    for i, v in s.field:
        if draw != nil:
            stdout.write(draw(v))
        else:
            stdout.write(v)
        if i mod s.width == s.width-1:
            stdout.write('\n')