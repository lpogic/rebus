require 'rebus'

template = <<~'EOS'
  <ul>
  # this is a comment line - parser skips it
    $ i = "Hello"
    # $ (1..5).each do |i|
    <li>#{i}</li>
    # $ end
  </ul>
EOS

puts Rebus.compile template

# Output:
#
# <ul>
#   <li>Hello</li>
# </ul>