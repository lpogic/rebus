require 'rebus'

puts Rebus.compile_file "b.html.rbs"
  
# Output:
#
# .../sample/b.html.rbs:2: undefined local variable or method `items'...
