class Code
  def initialize(str)
    # Rajouter digit, number et colorpool
  end
end

class Mastermind
  COLOR = { blank: 0, blue: 1, red: 2, yellow: 3, green: 4 }.freeze

  def initialize
    @secret_code = [rand(0..4), rand(0..4), rand(0..4), rand(0..4)]
    @secret_colorpool = create_colorpool
    @guessed_codes = []
    @turn = 0
  end

  def play
    while @turn < 12
      @turn += 1
      puts "\nTurn #{@turn}"
      guess
      res = compare
      break if display_res(res)
      # break if res == [true, true, true, true]
    end
  end

  def guess
    puts 'Please make your guess (color color color color) :'
    input = gets.chomp.split
    player_guess = color_to_digit(input)
    @guessed_codes.push(player_guess)
    player_guess
  end

  def current_guess
    @guessed_codes[@turn - 1]
  end

  def check_match(code = current_guess)
    res = []
    code.each_with_index do |digit, index|
      res << (@secret_code[index] == code[index] ? true : digit)
    end
    p "check_match => #{res}"
    res
  end

  def check_misplaced(res_true)
    res = []
    secret_code_updated = update_secret_code(res_true)
    res_true.each do |digit|
      res << if digit == true
               digit
             else
               secret_code_updated.include?(digit) ? 'misplaced' : false
             end
    end
    p "check_missplaced => #{res}"
    res
  end

  def update_secret_code(res_true)
    secret_code_updated = []
    res_true.each_with_index do |digit, index|
      secret_code_updated << @secret_code[index] unless digit == true
    end
    p secret_code_updated
    secret_code_updated
  end

  def compare(code = current_guess)
    return Array.new(4, true) if match_secret?(code)

    p code
    # current_colorpool = @secret_colorpool.slice
    res_true = check_match(code)
    check_misplaced(res_true)
  end

  def create_colorpool(code = @secret_code)
    digit_to_color(code).reduce(Hash.new(0)) do |result, digit|
      result[digit] += 1
      result
    end
  end

  def update_colorpool(digit, colorpool)
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
           "#{digit_to_color(@secret_code)}"
      true
    else
      puts "You guessed #{digit_to_color(current_guess)}\n=> #{res}"
      false
    end
  end

  private

  def digit_to_color(code)
    code.map do |digit|
      COLOR.key(digit).to_s
    end
  end

  def color_to_digit(code)
    code.map do |color|
      COLOR.fetch(color.to_sym)
    end
  end

  def generate_secret
    @secret_code = [rand(1..4), rand(1..4), rand(1..4), rand(1..4)]
  end

  def match_secret?(code = current_guess)
    @secret_code == code
  end
end

mastermind = Mastermind.new

mastermind.play
