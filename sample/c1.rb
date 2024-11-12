require 'rebus'

Rebus.strip_lines = true
puts Rebus.compile DATA

# Output:
#
# TEST1
#    TEST2
# TEST3

__END__

TEST1
\   TEST2\nTEST3