# Queens

It's pretty rough. Run by loading `queens.rb` into an interpreter and doing
something like:

    Board.solve_by_column!(size)

where `size` is a number, e.g.:

    Board.solve_by_column!(8)

There's also `#solve_by_random_placement(size)`, which does a fully-random
placement by enumeration (essentially, random, breadth-first walk).

I ran this on rubinius 2.5.8 on an Arch Linux system, no promises about getting
it to work elsewhere. Check out `ruby-install` and `chruby` for managing ruby
installs.
