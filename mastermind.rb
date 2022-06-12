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
    ' ', 'b', 'r', 'y', 'g',
    '0', '1', '2', '3', '4'
  ].freeze
  ABBREVIATIONS = {
    red: 'r', blue: 'b', yellow: 'y', green: 'g', blank: ''
  }.freeze
  RANDOM_CODE = [rand(0..4), rand(0..4), rand(0..4), rand(0..4)].join(' ')
  COLOR_DIGIT = { blank: 0, blue: 1, red: 2, yellow: 3, green: 4 }.freeze

  def initialize(str = RANDOM_CODE)
    @input = str.split(' ') if str.instance_of?(String)
    return unless Code.is_valid?(@input)

    @color = Code.format(@input)
    @digit = Code.to_digit(@color)
  end

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
    @secret_colorpool = create_colorpool
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
    @secret_colorpool = create_colorpool
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

  def check_match(code = current_guess)
    res = []
    code.each_with_index do |digit, index|
      # res << (@secret_code[index] == code[index] ? true : digit)
      res << if @secret_code.digit[index] == code[index]
               @secret_colorpool = update_colorpool(code[index])
               true
             else
               digit
             end
    end
    res
  end

  def check_misplaced(res_true)
    res = []
    res_true.each do |digit|
      res << if digit == true
               digit
             elsif update_secret_code(res_true).include?(digit)
               @secret_colorpool = update_colorpool(digit)
               'misplaced'
             else
               false
             end
    end
    # p"check_missplaced => #{res}"
    res
  end

  def compare(code = current_guess)
    return Array.new(4, true) if match_secret?(code)

    # p"code = #{code}"
    res_true = check_match(code)
    check_misplaced(res_true)
  end

  def update_secret_code(res_true)
    secret_code_updated = []
    res_true.each_with_index do |digit, index|
      if digit == true
        @secret_colorpool = update_colorpool(@secret_code.digit[index])
      else
        secret_code_updated << @secret_code.digit[index]
      end
    end
    # p"secret_code #{@secret_code}"
    # p"secret_code_updated #{secret_code_updated}"
    secret_code_updated
  end

  def create_colorpool(code = @secret_code.color)
    code.reduce(Hash.new(0)) do |result, digit|
      result[digit] += 1
      result
    end
  end

  def update_colorpool(digit, colorpool = @secret_colorpool)
    color = COLOR.key(digit)
    colorpool[color] -= 1 if colorpool.key?(color) && colorpool[color].positive?
    colorpool
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

  private

  def match_secret?(code = current_guess)
    @secret_code.digit == code
  end
end

mastermind = Mastermind.new

mastermind.play

# code = Code.new("r r r r")

# p code

# code2 = Code.new

# p code2
