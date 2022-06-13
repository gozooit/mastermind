# todo
# - check user input, allow r instead of red etc
# - create code class
# - create compare class ?

class String
  def integer?
    self.to_i.to_s == self
  end
end

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
    return unless Code.is_valid?(@input)

    @color = Code.format(@input)
    @digit = Code.to_digit(@color)
    # @colorpool = Code.create_colorpool(@color)
  end

  # def self.create_colorpool(code)
  #   code.reduce(Hash.new(0)) do |result, digit|
  #     result[digit] += 1
  #     result
  #   end
  # end

  # def update_colorpool(digit)
  #   color = COLOR_DIGIT.key(digit).to_s
  #   @colorpool[color] -= 1 if @colorpool.key?(color) && @colorpool[color].positive?
  # end

  # def reset_colorpool
  #   @colorpool = Code.create_colorpool(@color)
  # end

  # Rajouter digit, number et colorpool
  def self.is_valid?(input)
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

class Mastermind
  COLOR = { blank: 0, blue: 1, red: 2, yellow: 3, green: 4 }.freeze

  def initialize
    @secret_code = Code.new
    @guessed_codes = []
    @turn = 0
  end

  def play
    while @turn < 12
      @turn += 1
      puts "\nTurn #{@turn}"
      guess
      # p"@secret code #{@secret_code}", "@secret colorpool #{@secret_colorpool}"
      res = compare
      # p"@secret code #{@secret_code}", res
      break if display_res(res)
      # break if res == [true, true, true, true]
    end
  end

  def guess
    input = player_input
    @player_code = Code.new(input)
    @guessed_codes.push(@player_code.digit)
    # Update secret color pool at each guess so compare works
    @player_code
  end

  def player_input
    loop do
      puts 'Please make your guess (color color color color) :'
      input = gets.chomp
      break input if Code.is_valid?(input.split) == true
    end
  end

  def current_guess
    @guessed_codes[@turn - 1]
  end

  def check_match(code = @player_code)
    res = []
    code.digit.each_with_index do |digit, index|
      # res << (@secret_code[index] == code[index] ? true : digit)
      res << if @secret_code.digit[index] == code.digit[index]
              #  @secret_code.colorpool = code.update_colorpool(code.digit[index])
               true
             else
               digit
             end
    end
    res
  end

  def check_misplaced(res_match)
    res = []
    res_match.each do |digit|
      res << if digit == true then digit
             elsif update_secret_code(res_match).include?(digit)
               'misplaced'
             else
               false
             end
    end
    res
  end

  def compare(code = @player_code)
    return Array.new(4, true) if match_secret?

    # p"code = #{code}"
    res_match = check_match(code)
    res = check_misplaced(res_match)
    # @secret_code.reset_colorpool
    res
  end

  def update_secret_code(res_match)
    secret_code_updated = []
    res_match.each_with_index do |digit, index|
      unless digit == true || digit == 'misplaced'
        secret_code_updated << @secret_code.digit[index]
      end
    end
    # p"secret_code #{@secret_code}"
    # p"secret_code_updated #{secret_code_updated}"
    secret_code_updated
  end

  # def check_compare(res, guess = current_guess)
  #   hash_secret = number_of_color(@secret_code)
  #   hash_guess = number_of_color(guess)
  #   p digit_to_color(@secret_code), digit_to_color(guess), res, hash_secret, hash_guess
  # end

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

  def match_secret?(code = @player_code)
    @secret_code.digit == code.digit
  end
end

mastermind = Mastermind.new

mastermind.play

# code = Code.new("r r r r")

# p code

# code2 = Code.new

# p code2.colorpool

# code2.update_colorpool(1)

# p code2.colorpool

# p code2
