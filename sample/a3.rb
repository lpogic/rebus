require 'rebus'

puts Rebus.compile DATA

# Output:
#
# <ul>
#   <li>1</li>
#   <li>2</li>
#   <li>3</li>
# </ul>

__END__

<ul>
  $ (1..3).each do |i|
  <li>#{i}</li>
  $ end
</ul>