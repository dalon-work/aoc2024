package main

import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:math"
import "core:slice"
import "core:bytes"
import "core:text/regex"
import "base:intrinsics"

Reg :: struct {
  A : int,
  B : int,
  C : int,
}

Op :: enum u8 {
  ADV,
  BXL,
  BST,
  JNZ,
  BXC,
  OUT,
  BDV,
  CDV,
}

combo :: proc(r : Reg, i: u8) -> int {
  switch i {
    case 0..=3: return int(i)
    case 4: return r.A
    case 5: return r.B
    case 6: return r.C
    case: assert(false)
  }
  return 0
}

intcode :: proc(r : Reg, pr : []u8) -> []u8 {
  r := r
  output := make([dynamic]u8)
  iptr : int = 0
  for iptr < len(pr) {
    switch Op(pr[iptr]) {
      case .ADV:
        r.A = r.A >> uint(combo(r,pr[iptr+1]))
        iptr += 2
      case .BXL:
        r.B = r.B ~ int(pr[iptr+1])
        iptr += 2
      case .BST:
        r.B = combo(r,pr[iptr+1]) % 8
        iptr += 2
      case .JNZ:
        if r.A != 0 {
          iptr = int(pr[iptr+1])
        } else {
          iptr += 2
        }
      case .BXC:
        r.B = r.B~r.C
        iptr += 2
      case .OUT:
        append(&output, u8(combo(r,pr[iptr+1]) % 8))
        iptr += 2
      case .BDV:
        r.B = r.A >> uint(combo(r,pr[iptr+1]))
        iptr += 2
      case .CDV:
        r.C = r.A >> uint(combo(r,pr[iptr+1]))
        iptr += 2
    }
  }
  return output[:]
}

print_output :: proc(data : []u8) {
  if len(data) == 0 {
    return
  }

  for d, i in data {
    fmt.printf("%d", d)
    if i < len(data)-1 {
      fmt.printf(",")
    }
  }

  fmt.printf("\n")
    
}

day17 :: proc() {

  r := Reg{A = 66752888, B = 0, C = 0}
  pr := [?]u8{2,4,1,7,7,5,1,7,0,3,4,1,5,5,3,0}

  part1 := intcode(r, pr[:])
  defer delete(part1)

  fmt.printf("Day 17, Part 1: ")
  print_output(part1)
  fmt.printf("\n")

}


