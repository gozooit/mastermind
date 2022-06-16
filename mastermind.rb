# Modified String class to check if string is an integer
class String
  def integer?
    self.to_i.to_s == self
  end
end

# Handle all aspect of code for Mastermind
class Code
  attr_accessor :digit, :color

  ALLOWED_INPUTS = [
    'blank', 'blue', 'red', 'yellow', 'green',
    '.', 'b', 'r', 'y', 'g',
    '0', '1', '2', '3', '4', 0, 1, 2, 3, 4
  ].freeze
  ABBREVIATIONS = {
    red: 'r', blue: 'b', yellow: 'y', green: 'g', blank: '.'
  }.freeze
  RANDOM_CODE = [rand(0..4), rand(0..4), rand(0..4), rand(0..4)].join(' ')
  COLOR_DIGIT = { blank: 0, blue: 1, red: 2, yellow: 3, green: 4 }.freeze

  def initialize(str = RANDOM_CODE)
    @input = str.instance_of?(String) ? str.split(' ') : str
    return unless Code.valid?(@input)

    @color = Code.format(@input)
    @digit = Code.to_digit(@color)
  end

  def self.color_digit
    COLOR_DIGIT
  end

  def self.random_code
    Code.format_digit(RANDOM_CODE.split)
  end

  def self.valid?(input)
    return false if input.length != 4

    input.map { |str| return false unless ALLOWED_INPUTS.include?(str) }
    true
  end

  def self.format(input)
    if input.all?(&:integer?)
      Code.to_color(Code.format_digit(input))
    else
      Code.format_color(input)
    end
  end

  def self.format_digit(input)
    input.map(&:to_i)
  end

  def self.format_color(input)
    input.map do |str|
      if ABBREVIATIONS.values.include?(str)
        ABBREVIATIONS.key(str).to_s
      else
        str
      end
    end
  end

  def self.to_color(code_array)
    code_array.map do |digit|
      COLOR_DIGIT.key(digit).to_s
    end
  end

  def self.to_digit(code_array)
    code_array.map do |color|
      COLOR_DIGIT.fetch(color.to_sym)
    end
  end
end

# Contain the game
class Mastermind
  COLOR = { blank: 0, blue: 1, red: 2, yellow: 3, green: 4 }.freeze
  attr_reader :turn

  def initialize
    @secret_code = Code.new
    @previous_codes = []
    @turn = 0
  end

  def player_play
    while @turn < 12
      @turn += 1
      puts "\nTurn #{@turn}"
      player_guess
      res = compare
      break if display_res(res)
    end
  end

  def computer_play
    set_secret
    computer = Computer.new
    while @turn < 12
      @turn += 1
      puts "\nTurn #{@turn}"
      @guessed_code = defined?(@result) ? computer.guess(@result) : computer.guess
      @previous_codes.push(@guessed_code.digit)
      @result = compare
      # p '', computer, ''
      break if display_res(@result)
    end
  end

  def player_guess
    input = player_input('Please make your guess (color color color color) :')
    @guessed_code = Code.new(input)
    @previous_codes.push(@guessed_code.digit)
    # Update secret color pool at each guess so compare works
    @guessed_code
  end

  def set_secret
    input = player_input('Please chose a secret code '\
      '(color color color color) :')
    @secret_code = Code.new(input)
  end

  def player_input(str)
    loop do
      puts str
      input = gets.chomp
      break input if Code.valid?(input.split) == true
    end
  end

  def current_guess
    @previous_codes[@turn - 1]
  end

  def check_match(code = @guessed_code)
    res = []
    code.digit.each_with_index do |digit, index|
      res << (@secret_code.digit[index] == code.digit[index] ? true : digit)
    end
    res
  end

  def check_misplaced(res_match)
    res = []
    secret_updated = update_secret_code(res_match)
    res_match.each do |digit|
      res << if digit == true then digit
             elsif secret_updated.include?(digit)
               secret_updated.delete_at(secret_updated.index(digit))
               'misplaced'
             else false end
    end
    res
  end

  def compare(code = @guessed_code)
    return Array.new(4, true) if match_secret?

    res_match = check_match(code)
    check_misplaced(res_match)
  end

  def update_secret_code(res_match)
    secret_code_updated = []
    res_match.each_with_index do |digit, index|
      secret_code_updated << @secret_code.digit[index] unless digit == true
    end
    secret_code_updated
  end

  def display_res(res)
    if res == [true, true, true, true]
      puts 'You found the secret code, it was indeed '\
           "#{@secret_code.color}"
      true
    else
      puts "You guessed #{Code.to_color(current_guess)}\n=> #{res}"
      false
    end
  end

  def match_secret?(code = @guessed_code)
    @secret_code.digit == code.digit
  end
end

class Player
  attr_accessor :guessed_code

  # def initialize(name)
  #   @name = name
  # end

  def input(str)
    loop do
      puts str
      input = gets.chomp
      break input if Code.valid?(input.split) == true
    end
  end

  def guess
    input = input('Please make your guess (color color color color) :')
    @guessed_code = Code.new(input)
  end
end

# Computer makes guesses
class Computer
  attr_accessor :guessed_code

  def initialize
    @guessed_code = Code.new
    @code_history = []
    @misplaced_colors = {
      red: [], blue: [], yellow: [], green: [], blank: []
    }
    @valid_colors = [0, 1, 2, 3, 4]
    @incomplete_code = ['', '', '', '']
  end

  def update_guessed_code
    @code_history.push(@guessed_code)
    @guessed_code = Code.new(@incomplete_code)
    # @incomplete_code = Array.new(4, '')
    @incomplete_code = ['', '', '', '']
    @guessed_code
  end

  def analyze(res)
    res.each_with_index do |digit, index|
      case digit
      when true
        @incomplete_code[index] = @guessed_code.digit[index]
        @misplaced_colors[@guessed_code.color[index].to_sym].pop
      when 'misplaced'
        @misplaced_colors[@guessed_code.color[index].to_sym].push(index)
      when false
        @valid_colors.delete(@guessed_code.digit[index])
      end
    end
  end

  def empty_position
    empty_pos = @incomplete_code.map.with_index do |digit, index|
      index if digit == ''
    end
    empty_pos.compact
  end

  # fonction random qui retire les digit false pour tester des nouveaux

  def number_misplaced
    cpt = 0
    @misplaced_colors.each_value { |value| cpt += 1 unless value == [] }
    cpt
  end

  def replace_misplaced
    empty_pos = empty_position
    return if @misplaced_colors.values.all? { |value| value == [] }

    cpt = number_misplaced
    @misplaced_colors.each do |color, value|
      next if value == []

      empty_pos.delete_if do |pos|
        return false if cpt.zero?

        unless value.include?(pos)
          @incomplete_code[pos] = Code.color_digit[color.to_sym]
          cpt -= 1
          true
        end
      end
    end
  end

  def fill_empty
    @incomplete_code.each_with_index do |value, index|
      @incomplete_code[index] = @valid_colors.sample if value == ''
    end
  end

  def guess(res = Array.new(4, true))
    analyze(res)
    replace_misplaced
    fill_empty
    update_guessed_code
    # @guessed_code = Code.new(@incomplete_code)
    # @incomplete_code = ['', '', '', '']
    # @guessed_code
  end
end

#   def guess
#     new_guess = []
#     @incomplete_code.each_with_index do |digit, index|
#       case digit
#       when digit.is_a? == Integer
#         new_guess.push(digit)
#       when ''
#         @misplaced_colors.each do |key, array|
#           next if array.include?(index)
#           new_guess.push(Code.color_digit[key.to_sym])
#           break
#         end
#       end
#     end
#   end
# end

mastermind = Mastermind.new

mastermind.computer_play

# computer = Computer.new

# computer.display_classvar
# computer.guess(['misplaced', false, true, 'misplaced'])
# computer.display_classvar

# array = [1, 2, 3, 4]

# array.delete_if do |v|
#   p v
#   p array
#   p v * 2 if v == 3
# end

# p array

