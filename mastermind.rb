class Mastermind
  COLOR = {
    blue: 1,
    red: 2,
    yellow: 3,
    green: 4
  }.freeze

  def initialize
    @secret_code = [rand(1..4), rand(1..4), rand(1..4), rand(1..4)]
    @guessed_codes = []
    @turn = 0
  end

  def guess
    puts 'Please make your guess (color color color color) :'
    input = gets.chomp.split
    player_guess = color_to_digit(input)
    @guessed_codes.push(player_guess)
    @turn += 1
    player_guess
  end

  def current_guess
    @guessed_codes[@turn]
  end

  def match_secret?(code = current_guess)
    @secret_code == code
  end

  def compare(code = current_guess)
    return Array.new(4, true) if match_secret?(code)

    res = []
    code.each_with_index do |digit, index|
      if @secret_code.include?(digit)
        res << @secret_code[index] == code[index] ? true : 'misplaced'
      else
        res << false
      end
    end
    res
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
end

mastermind = Mastermind.new

mastermind.guess

p mastermind.current_guess
