require 'rebus'

puts Rebus.compile DATA, items: [:alpha, :beta, :gamma]
  
# Output:
#
# <ul>
#   <li>alpha</li>
#   <li>beta</li>
#   <li>gamma</li>
# </ul>

__END__

<ul>
  $ items.each do |i|
  <li>#{i}</li>
  $ end
</ul>