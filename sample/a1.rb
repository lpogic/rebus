require 'rebus'

template = <<~'EOS'
  <ul>
      |> 3.times do
        <li>!</li>
      |> end
  </ul>
EOS

puts Rebus.compile template

# Output:
#
# <ul>
# <li>!</li>
# <li>!</li>
# <li>!</li>
# </ul>