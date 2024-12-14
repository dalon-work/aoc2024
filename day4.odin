package main

import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:math"
import "core:slice"
import "core:bytes"
import "core:text/regex"
import "base:intrinsics"

xmas := [4]u8{'X','M','A','S'}

mas := intrinsics.matrix_flatten(matrix[3,3]rune{
'M', '.', 'S',
'.', 'A', '.',
'M', '.', 'S',
})

search_for_mas :: proc(map2d:[][]u8, i, j: int) -> int {
  mat : matrix[3,3]rune

  for jj in 0..<3 {
    for ii in 0..<3 {
      mat[jj,ii] = rune(map2d[i+ii][j+jj])
    }
  }

  mat[1,0] = '.'
  mat[0,1] = '.'
  mat[2,1] = '.'
  mat[1,2] = '.'

  flat := intrinsics.matrix_flatten(mat)

// M S
//  A
// M S
  if flat == mas { return 1 }
// M M
//  A
// S S
  if flat == swizzle(mas,0,1,6,3,4,5,2,7,8) { return 1 }
// S M
//  A
// S M
  if flat == swizzle(mas,6,1,8,3,4,5,0,7,2) { return 1 }
// S S
//  A
// M M
  if flat == swizzle(mas,8,1,2,3,4,5,6,7,0) { return 1 }

  return 0

}

search_for_xmas :: proc(map2d: [][]u8, i, j: int) -> int {

  copy : [4]u8

  count := 0

  if j+3 < len(map2d[i]) {
    for k in 0..<4 {
      copy[k] = map2d[i][j+k]
    }
    if copy == xmas {
      count += 1
    }
  }

  if j-3 >= 0 {
    for k in 0..<4 {
      copy[k] = map2d[i][j-k]
    }
    if copy == xmas {
      count += 1
    }
  }

  if i+3 < len(map2d) {
    for k in 0..<4 {
      copy[k] = map2d[i+k][j]
    }
    if copy == xmas {
      count += 1
    }
  }

  if i-3 >= 0 {
    for k in 0..<4 {
      copy[k] = map2d[i-k][j]
    }
    if copy == xmas {
      count += 1
    }
  }

  if i+3 < len(map2d) && j+3 < len(map2d[i]) {
    for k in 0..<4 {
      copy[k] = map2d[i+k][j+k]
    }
    if copy == xmas {
      count += 1
    }
  }

  if i+3 < len(map2d) && j-3 >= 0 {
    for k in 0..<4 {
      copy[k] = map2d[i+k][j-k]
    }
    if copy == xmas {
      count += 1
    }
  }

  if i-3 >= 0 && j-3 >= 0 {
    for k in 0..<4 {
      copy[k] = map2d[i-k][j-k]
    }
    if copy == xmas {
      count += 1
    }
  }
    
  if i-3 >= 0 && j+3 < len(map2d[i]) {
    for k in 0..<4 {
      copy[k] = map2d[i-k][j+k]
    }
    if copy == xmas {
      count += 1
    }
  }

  return count
  
}

day4 :: proc() {

  data := #load("data/day4.txt", string)

//data := `MMMSXXMASM
//MSAMXMSMSA
//AMXSXMAAMM
//MSAMASMSMX
//XMASAMXAMM
//XXAMMXXAMA
//SMSMSASXSS
//SAXAMASAAA
//MAMMMXMMMM
//MXMXAXMASX
//`

  lines := strings.split_lines(data)
  defer delete(lines)

  lines = lines[:len(lines)-1]

  map2d := make([dynamic][]u8, len(lines))
  defer delete(map2d)

  for l, i in lines {
    map2d[i] = transmute([]u8) l
  }

  part1 := 0
  for i in 0..<len(map2d) {
    for j in 0..<len(map2d[i]) {
      if map2d[i][j] == 'X' {
        part1 += search_for_xmas(map2d[:], i, j)
      }
    }
  }

  fmt.println("Day 4, Part 1:", part1)

  part2 := 0

  for i in 0..<len(map2d)-2 {
    for j in 0..<len(map2d[i])-2 {
      part2 += search_for_mas(map2d[:],i,j)
    }
  }

  fmt.println("Day 4, Part 2:", part2)

}


