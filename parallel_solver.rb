require 'celluloid'
require 'celluloid/autostart'
require './queen.rb'


class ErrorResponse
  def initialize(x,y)
    # literally don't care
  end
end

class Solver
  include Celluloid

  attr_reader :size

  def initialize(size)
    @size = size
  end

  def solver
    b = Board.new(size)

    loop do
      size.times do |c|
        next_queens = b.available_placements_in_column(c)
        break if next_queens.empty?
        b = next_queens.sample
      end
      return b if b.solved?
      b = Board.new(size)
    end
  end


  def self.workpool(size)
    @workpool ||= pool(args: [size])
  end

  def self.solve!(size)
    workers = (1..4).map { workpool(size).future.solver }
    loop do
      if workers.any?(&:ready?)
        finished = workers.select(&:ready?)[0].value
        workers.map { |w| w.cancel("Done") rescue true }
        reset!
        return finished
      end
      sleep 1
    end
  end

  def self.reset!
    @workpool = nil
  end
end



require 'benchmark'


Benchmark.bmbm do |x|
  (5..100).each do |i|
    x.report("Time to solve a #{i}x#{i}:") { Solver.solve!(i) }
  end
end
