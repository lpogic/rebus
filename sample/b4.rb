require 'rebus'

Rebus.code_prefix = "%"
Rebus.comment_prefix = "#"
puts Rebus.compile DATA

# Output:
#
# <ul>
# <li>1</li>
# <li>2</li>
# <li>3</li>
# </ul>

__END__

<ul>
  % (1..3).each do |i|
    # this is comment line
    <li>#{i}</li>
    # <br>
  % end
</ul>