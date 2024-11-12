require 'rebus'

puts Rebus.compile DATA

# Output:
#
# Hello World!

__END__

#{
  def foo
    "World!"
  end
  nil
}\
\
Hello #{ foo }