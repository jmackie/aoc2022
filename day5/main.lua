local crates_parser = (function()
  local lpeg = require("lpeg")
  local EMPTY = {}

  local space = lpeg.P " "
  local empty = space * space * space * lpeg.Cc(EMPTY)
  local open_bracket = lpeg.P "["
  local letter = lpeg.R "AZ"
  local close_bracket = lpeg.P "]"
  local crate = open_bracket * lpeg.C(letter) * close_bracket
  local item = crate + empty

  -- hardcode the number of expected items 😬
  local line = item * space -- 1
      * item * space --        2
      * item * space --        3
      * item * space --        4
      * item * space --        5
      * item * space --        6
      * item * space --        7
      * item * space --        8
      * item --                9

  local function parse(s)
    return lpeg.Ct(line):match(s)
  end

  return { parse = parse, EMPTY = EMPTY }
end)()

local instruction_parser = (function()
  local lpeg = require("lpeg")

  local digit = lpeg.R("09") ^ 1
  local line = lpeg.P("move ") * lpeg.C(digit) * lpeg.P(" from ") * lpeg.C(digit) * lpeg.P(" to ") * lpeg.C(digit)

  local function parse(s)
    return lpeg.Ct(line):match(s)
  end

  return { parse = parse }
end)()

-- Does the line look like: "[G] [B] [V] [R] [L] [N] [G] [P] [F]?"
local function is_crate_line(line)
  -- HACK this isn't great...
  return string.find(line, "[", 0, true)
end

-- Does the line look like: "move 4 from 5 to 3"
local function is_instruction_line(line)
  -- is the first word "move"?
  return string.sub(line, 1, 4) == "move"
end

local function list_map(xs, f)
  local new = {}
  for i, value in pairs(xs) do
    new[i] = f(value)
  end
  return new
end

local function part_one(input_file)
  local stacks = {}

  for line in io.lines(input_file) do
    if line == "" then
      -- noop

    elseif is_crate_line(line) then
      local matches = crates_parser.parse(line)
      for i, crate in pairs(matches) do
        if crate ~= crates_parser.EMPTY then
          if stacks[i] == nil then
            stacks[i] = { crate }
          else
            table.insert(stacks[i], crate) -- push
          end
        end
      end

    elseif is_instruction_line(line) then
      local matches = instruction_parser.parse(line)

      local n = tonumber(matches[1]) -- move this many
      local from = tonumber(matches[2]) -- from here
      local to = tonumber(matches[3]) -- to here

      for _ = 1, n do
        local crate = table.remove(stacks[from], 1) -- pop
        table.insert(stacks[to], 1, crate)
      end
    end
  end

  return table.concat(
    list_map(stacks, function(stack) return stack[1] end)
  )
end

local function part_two(input_file)
  local stacks = {}

  for line in io.lines(input_file) do
    if line == "" then
      -- noop

    elseif is_crate_line(line) then
      local matches = crates_parser.parse(line)
      for i, crate in pairs(matches) do
        if crate ~= crates_parser.EMPTY then
          if stacks[i] == nil then
            stacks[i] = { crate }
          else
            table.insert(stacks[i], crate) -- push
          end
        end
      end

    elseif is_instruction_line(line) then
      local matches = instruction_parser.parse(line)

      local n = tonumber(matches[1]) -- move this many
      local from = tonumber(matches[2]) -- from here
      local to = tonumber(matches[3]) -- to here

      local to_stack = {}
      for _ = 1, n do
        local crate = table.remove(stacks[from], 1) -- pop
        table.insert(to_stack, crate)
      end
      for _ = 1, #stacks[to] do
        table.insert(to_stack, table.remove(stacks[to], 1))
      end
      stacks[to] = to_stack
    end
  end

  return table.concat(
    list_map(stacks, function(stack) return stack[1] end)
  )
end

local function main(input_file)
  local part_one_answer = part_one(input_file)
  assert(part_one_answer == "VPCDMSLWJ", "wrong answer!")
  print("part one:", part_one_answer)

  local part_two_answer = part_two(input_file)
  assert(part_two_answer == "TPWCGNCCG", "wrong answer!")
  print("part two:", part_two_answer)
end

main(arg[1])
