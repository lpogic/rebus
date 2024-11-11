require 'rebus'

items = [:a, :b, :c]
Rebus.compile DATA do |line|
  puts line
end
  
# Output:
#
# <ul>
#   <li>a</li>
#   <li>b</li>
#   <li>c</li>
# </ul>

__END__

<ul>
  $ items.each do |i|
  <li>#{i}</li>
  $ end
</ul>