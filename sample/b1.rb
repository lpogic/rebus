require 'rebus'

items = [:a, :b, :c]
puts Rebus.compile_file "b.html.rbs", binding
  
# Output:
#
# <ul>
#   <li>a</li>
#   <li>b</li>
#   <li>c</li>
# </ul>
