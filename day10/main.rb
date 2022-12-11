def read_cycles_from_input(input_file)
  x_register = 1
  File.readlines(input_file).reduce(Array.new) do |cycles, line|
    first_word, second_word = line.strip().split(" ")
    case first_word
    when "noop"
      # `noop` takes one cycle to complete.
      # It has no other effect.
      cycles.push(x_register)
    when "addx"
      # `addx V` takes two cycles to complete.
      # After two cycles, the X register is increased by the value V. (V can be negative.)
      cycles.concat([x_register, x_register])
      x_register += second_word.to_i
      cycles
    else
      throw "unexpected instruction: #{line.strip()}"
    end
  end
end

def part_one(input_file)
  cycles = read_cycles_from_input(input_file)
  (20..220).step(40).reduce(0) do |sum, i|
    x_register = cycles.at(i - 1)
    signal_strength = x_register * i
    sum + signal_strength
  end
end

def part_two(input_file)
  cycles = read_cycles_from_input(input_file)
  crt_width = 39
  (0..cycles.length - 1).each do |pixel|
    _pixel_row, pixel_col = pixel.divmod(crt_width + 1)

    sprite_middle = cycles.at(pixel)
    sprite = (sprite_middle - 1..sprite_middle + 1)

    if sprite.include? pixel_col
      print "#"
    else
      print "."
    end

    if pixel_col == crt_width
      puts "" # start newline
    end
  end
end

def main(input_file)
  part_one_answer = part_one(input_file)
  puts "part one: #{part_one_answer}"
  raise "wrong answer to part one" unless part_one_answer == 16020

  puts "part two:"
  part_two(input_file)
end

main(ARGV[0])
