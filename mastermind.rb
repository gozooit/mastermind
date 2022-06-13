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
    '0', '1', '2', '3', '4'
  ].freeze
  ABBREVIATIONS = {
    red: 'r', blue: 'b', yellow: 'y', green: 'g', blank: '.'
  }.freeze
  RANDOM_CODE = [rand(0..4), rand(0..4), rand(0..4), rand(0..4)].join(' ')
  COLOR_DIGIT = { blank: 0, blue: 1, red: 2, yellow: 3, green: 4 }.freeze

  def initialize(str = RANDOM_CODE)
    @input = str.split(' ') if str.instance_of?(String)
    return unless Code.valid?(@input)

    @color = Code.format(@input)
    @digit = Code.to_digit(@color)
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

  def self.to_color(code)
    code.map do |digit|
      COLOR_DIGIT.key(digit).to_s
    end
  end

  def self.to_digit(code)
    code.map do |color|
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
    while @turn < 12
      @turn += 1
      puts "\nTurn #{@turn}"
      @guessed_code = if defined?(res)
                        Computer.guess(res, @previous_codes)
                      else Code.new end
      @previous_codes.push(@guessed_code.digit)
      res = compare
      break if display_res(res)
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

# Computer makes guesses
class Computer
  attr_accessor :computer_code

  def self.guess(res, previous_codes)

  end
end

mastermind = Mastermind.new

mastermind.computer_play