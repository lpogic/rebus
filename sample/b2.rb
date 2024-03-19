require 'rebus'

items = [:a, :b, :c]
Rebus.home = __dir__
puts Rebus.compile_file "b.html.rbs", items: [:a, :b, :c]
  
# Output:
#
# <ul>
# <li>a</li>
# <li>b</li>
# <li>c</li>
# </ul>
