require 'rebus'

class Foo
  def items
    [:alpha, :beta, :gamma]
  end
end

foo = Foo.new
puts Rebus.compile DATA, foo
  
# Output:
#
# <ul>
# <li>alpha</li>
# <li>beta</li>
# <li>gamma</li>
# </ul>

__END__

<ul>
  #| items.each do |i|
    <li>#{i}</li>
  #| end
</ul>