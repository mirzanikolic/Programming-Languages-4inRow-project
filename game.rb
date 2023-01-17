require 'yaml'

class FourInARow
  def initialize(rows, columns, shouldContinue)
    if (rows - columns).abs > 2
      raise "Number of rows and columns must not differ by more than 2"
    end

    if (shouldContinue == "y")
      load_game
    else
      @board = Array.new(rows) { Array.new(columns, ' ') }
      @current_player = :🌑
      @moves = { 🌑: [], 🌕: [] }
    end
  end

  def play_again
    print "Enter number of rows: "
    rows = gets.to_i
    print "Enter number of columns: "
    columns = gets.to_i
    FourInARow.new(rows, columns, false).play
  end

  def play
    loop do
      print_board
      puts "Enter QS to quit and save"
      puts "Player #{@current_player}, enter a column number (1-#{@board[0].size}):"
      column = gets.chomp
      if (column == "QS")
        save_game
        break
        else
          column = column.to_i - 1
      end
      @moves[@current_player] << column
      row = drop_piece(column)
      if check_win(row, column)
        print_board
        puts "Player #{@current_player} wins!"
        puts "Do you want to play again (y/n)?"
        choice = gets.chomp
        if (choice == "y")
          play_again
        else
          break
        end
      elsif @board.flatten.none?(' ')
        print_board
        puts "It's a tie!"
        break
      end
      @current_player = @current_player == :🌑 ? :🌕 : :🌑
    end

    puts "Moves: Red - #{@moves[:🌑].join(', ')}, Yellow - #{@moves[:🌕].join(', ')}"
  end

  def print_board
    @board.each do |row|
      puts row.map { |cell| cell == ' ' ? '-' : cell }.join(' | ')
      puts '-' * (@board[0].size * 4 - 1)
    end
  end

  def drop_piece(column)
    (0...@board.size).reverse_each do |i|
      if @board[i][column] == ' '
        @board[i][column] = @current_player
        return i
      end
    end

    puts "Column is full"
  end

  def check_win(row, column)
    # Check horizontal win
    @board[row].each_cons(4).any? { |a, b, c, d| a == b && b == c && c == d && a != ' ' } ||
      # Check vertical win
      @board.transpose[column].each_cons(4).any? { |a, b, c, d| a == b && b == c && c == d && a != ' ' } ||
      # Check diagonal win
      (0...@board.size).each_cons(4).any? { |a, b, c, d| @board[a][b] == @board[b][c] && @board[b][c] == @board[c][d] && @board[c][d] == @board[d][a] && @board[a][b] != ' ' }
  end

  def save_game
    data = {
      rows: @board.size,
      columns: @board[0].size,
      current_player: @current_player,
      moves: @moves,
      board: @board
    }
    File.open("saved_game.txt", "w") do |file|
      file.write(YAML.dump(data))
    end
  end

  def load_game
    if File.exist?("saved_game.txt")
      data = YAML.load(File.read("saved_game.txt"))
      @board = data[:board]
      @current_player = data[:current_player]
      @moves = data[:moves]
    else
      puts "No saved game found."
    end
  end

puts "Enter number of rows: "
rows = gets.to_i
puts "Enter number of columns: "
columns = gets.to_i
puts "Do you want to load the previous saved game? (y/n)"
choice = gets.chomp
FourInARow.new(rows, columns, choice).play
end