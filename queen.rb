require 'set'
require 'pry'

class Position
  attr_reader :status, :col, :row

  def initialize(c,r)
    @col = c
    @row = r
  end

  def -(other_position)
    Position.new(col - other_position.col, row - other_position.row)
  end
end


class Board
  attr_reader :size, :positions

  def initialize(size, positions = [])
    @size = size
    @positions = positions
  end

  def copy
    Board.new(size, positions.map(&:copy))
  end

  def place_queen(c,r)
    copy.place_queen!(c,r)
  end

  def available_placements
    acc = []
    size.times do |r|
      size.times do |c|
        acc << place_queen(c,r) if free? Position.new(c,r)
      end
    end

    return acc
  end

  def self.solve_by_random_placement!(size)
    count = 0
    loop do
      b = new(size)

      break if b.solved?

      until (next_queens = b.available_placements).empty?
        b = next_queens.sample
      end

      if count % size == 0
        system 'clear'
        puts "count: #{count}"
        b.display!
      end
      count += 1
    end

    system 'clear'
    count += 1
    print "Count: #{count}"
    return b
  end

  def self.solve_by_column!(size)
    count = 0

    loop do
      b = new(size)

      size.times do |c|
        next_queens = b.available_placements_in_column(c)
        break if next_queens.empty?
        b = next_queens.sample
      end

      if count % size == 0
        system 'clear'
        puts "count: #{count}"
        b.display!
      end
      count += 1

      if b.solved?
        system 'clear'
        puts "count: #{count}"
        b.display!

        return
      end
    end

  end

  def available_placements_in_column(c)
    acc = []
    size.times do |r|
      acc << place_queen(c,r) if free? Position.new(c,r)
    end
    return acc
  end

  def to_s
    display!(s = StringIO.new)
    s.rewind
    s.read
  end

  def inspect
    to_s
  end

  def display!(out = STDOUT)
    out.puts
    out.puts "#{size}x#{size} #{solved? ? '✓' : '✗'}"
    out.puts "-"*size
    size.times do |r|
      size.times do |c|
        new_pos = Position.new(c,r)
        case
        #order matters here, #occupies? implies #blocked?
        when occupied?(new_pos)
          out.print 'Q'
        when blocked?(new_pos)
          out.print 'x'
        else
          out.print '.'
        end
      end
      out.puts
    end
    out.puts "-"*size
  end

  def solved?
    # a board is 'solved' if there are at least as many queens as there are
    # columns or rows
    positions.size == size
  end

  protected

  def place_queen!(c,r)
    q = Queen.new(c,r)
    if free? q
      positions << Queen.new(c,r)
    end
    return self
  end

  private

  def free?(pos)
    # implies not #occupied?
    not blocked?(pos)
  end

  def blocked?(pos)
    positions.any? { |p| p.blocks? pos }
  end

  def occupied?(pos)
    positions.any? { |p| p.occupies? pos }
  end

end


class Queen
  attr_reader :position

  def initialize(c,r)
    @position = Position.new(c,r)
  end

  def copy
    Queen.new(col,row)
  end

  def occupies?(other)
    row == other.row and col == other.col
  end

  def blocks?(other)
    # anything that barks like Position will work, assume #position returns such
    # a thing
    other_position = other
    other_position = other.position if other.respond_to?(:position)

    forward_diagonal_block?(other_position) or
      reverse_diagonal_block?(other_position) or
      row_block?(other_position) or
      column_block?(other_position)
  end

  def row
    position.row
  end

  def col
    position.col
  end

  def forward_diagonal_block?(other)
    # where k is some integer constant, q is this queen, p is the other queen
    # if k<1,1> + q == p for some k, then q collides with p
    #
    # thus
    #
    #   p - q / k == <1,1> for some k, then q collides with p
    #
    # thus if `p-q` has each component equal, then q collides with p
    #
    collision_vector = position - other
    collision_vector.row == collision_vector.col
  end

  def reverse_diagonal_block?(other)
    # similar to #forward_diagonal_block?, if:
    #
    #   k<1,-1> + q == p
    #
    # then the queens collide on the reverse. Thus, by similar reasoning, if one
    # component is the negative of the other, then they collide.
    #
    collision_vector = position - other
    collision_vector.row == -collision_vector.col
  end

  def row_block?(other)
    other.row == row
  end

  def column_block?(other)
    other.col == col
  end
end
