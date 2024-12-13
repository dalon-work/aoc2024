package main

import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:math"
import "core:slice"
import "core:bytes"
import "core:text/regex"

TokenType :: enum {
  MUL,
  INTEGER,
  JUNK,
  OPEN_PAREN,
  CLOSE_PAREN,
  COMMA,
  DO,
  DONT,
  EOF
}

EOF : rune : ~rune(0)

Token :: struct {
  type : TokenType,
  text : string,
}

Tokenizer :: struct {
  data : string,
  start : int,
  index : int,
  tokens : [dynamic] Token,
}

tk_emit :: proc(tk: ^Tokenizer, type : TokenType) {
  append(&tk.tokens, Token{type, tk.data[tk.start:tk.index]})
  tk.start = tk.index
}

TokenizeFunc :: proc(tk: ^Tokenizer) -> TokenizeFunc

tk_next :: proc(tk: ^Tokenizer) -> rune {
  if tk.index >= len(tk.data) {
    return EOF
  }
  char := tk.data[tk.index]
  tk.index += 1
  return rune(char)
}

tk_backup :: proc(tk: ^Tokenizer) {
  tk.index -= 1
}

tk_ignore :: proc(tk: ^Tokenizer) {
  tk.start = tk.index
}

tk_peek :: proc(tk: ^Tokenizer) -> rune {
  char := tk_next(tk)
  tk_backup(tk)
  return char
}

tk_junk :: proc(tk: ^Tokenizer) -> TokenizeFunc {
  for {
    if strings.has_prefix(tk.data[tk.index:], "mul") {
      if tk.index > tk.start {
        tk_emit(tk, .JUNK)
      }
      return tk_mul
    } else if strings.has_prefix(tk.data[tk.index:], "do()") {
      if tk.index > tk.start {
        tk_emit(tk, .JUNK)
      }
      return tk_do
    } else if strings.has_prefix(tk.data[tk.index:], "don't()") {
      return tk_dont
    }
    if tk_next(tk) == EOF {
      break
    }
  }

  if tk.index > tk.start {
    tk_emit(tk, .JUNK)
  }

  tk_emit(tk, .EOF)
  return nil
}

tk_open_paren :: proc(tk: ^Tokenizer) -> TokenizeFunc {
  if tk_peek(tk) != '(' {
    return tk_junk
  }
  tk_next(tk)
  tk_emit(tk, .OPEN_PAREN)
  return tk_integer
}

tk_close_paren :: proc(tk: ^Tokenizer) -> TokenizeFunc {
if tk_peek(tk) != ')' {
    return tk_junk
  }
  tk_next(tk)
  tk_emit(tk, .CLOSE_PAREN)
  return tk_junk
}

tk_comma :: proc(tk: ^Tokenizer) -> TokenizeFunc {
if tk_peek(tk) != ',' {
    return tk_junk
  }
  tk_next(tk)
  tk_emit(tk, .COMMA)
  return tk_integer
}

is_digit :: proc(r: rune) -> bool {
  return r >= '0' && r <= '9'
}

tk_integer :: proc(tk: ^Tokenizer) -> TokenizeFunc {
  if !is_digit(tk_peek(tk)) {
    return tk_junk
  }

  for {
    if !is_digit(tk_next(tk)) {
      break
    }
  }

  tk_backup(tk)

  tk_emit(tk, .INTEGER)

  next := tk_peek(tk)

  if next == ',' {
    return tk_comma
  } else if next == ')' {
    return tk_close_paren;
  } else if next == EOF {
    tk_emit(tk, .EOF)
    return nil
  } else {
    return tk_junk
  }

}

tk_mul :: proc(tk: ^Tokenizer) -> TokenizeFunc {
  tk.index += len("mul")
  tk_emit(tk, .MUL)
  return tk_open_paren
}

tk_do :: proc(tk: ^Tokenizer) -> TokenizeFunc {
  tk.index += len("do()")
  tk_emit(tk, .DO)
  return tk_junk
}

tk_dont :: proc(tk: ^Tokenizer) -> TokenizeFunc {
  tk.index += len("don't()")
  tk_emit(tk, .DONT)
  return tk_junk
}

run :: proc(data: string) -> [dynamic]Token {
  tk := Tokenizer{data, 0, 0, nil}

  state : TokenizeFunc = tk_junk;

  for state != nil {
    state = state(&tk)
  }

  return tk.tokens
}

maybe_do_mul :: proc(tokens: []Token) -> int {
  res := 0
    if tokens[0].type == .MUL &&
       tokens[1].type == .OPEN_PAREN &&
       tokens[2].type == .INTEGER &&
       tokens[3].type == .COMMA &&
       tokens[4].type == .INTEGER &&
       tokens[5].type == .CLOSE_PAREN {
       i1, _ := strconv.parse_int(string(tokens[2].text))
       i2, _ := strconv.parse_int(string(tokens[4].text))
       res = i1*i2
    }
  return res
}

part1 :: proc(tokens: []Token) -> int {

  l := len(tokens)

  sum := 0

  for i in 0..<len(tokens)-5 {
    sum += maybe_do_mul(tokens[i:])
  }

  return sum
}

part2 :: proc(tokens: []Token) -> int {

  l := len(tokens)

  sum := 0

  yes_mul := true

  for i in 0..<len(tokens)-5 {
    if tokens[i].type == .DO {
      yes_mul = true
      continue
    } else if tokens[i].type == .DONT {
      yes_mul = false
      continue
    }

    if yes_mul {
      sum += maybe_do_mul(tokens[i:])
    }
  }

  return sum
}


day3 :: proc() {

  data := #load("data/day3.txt", string)

  tokens := run(data)
  defer delete(tokens)

  fmt.println("Day 3, Part 1: ", part1(tokens[:]))
  fmt.println("Day 3, Part 2: ", part2(tokens[:]))

}


