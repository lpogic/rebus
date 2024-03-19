Welcome to the _rebus_ documentation home page!
===

Installation
---
```
gem install rebus
```

Usage
---
### 1. Render from string & code lines
```RUBY
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
```

### 2. Interpolation & comments
```RUBY
require 'rebus'

template = <<~'EOS'
  <ul>
# this is commented line - parser skip it
    |> i = "Hello"
#    |> (1..5).each do |i|
      <li>#{i}</li>
#    |> end
  </ul>
EOS

puts Rebus.compile template

# Output:
#
# <ul>
# <li>Hello</li>
# </ul>
```

### 3. Render from IO
```RUBY
require 'rebus'

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
  |> (1..3).each do |i|
    <li>#{i}</li>
  |> end
</ul>
```

### 4. Binding as template context
```RUBY
require 'rebus'

items = [:a, :b, :c]
puts Rebus.compile DATA, binding

# Output:
#
# <ul>
# <li>a</li>
# <li>b</li>
# <li>c</li>
# </ul>

__END__

<ul>
  |> items.each do |i|
    <li>#{i}</li>
  |> end
</ul>
```

### 5. Block argument - automatic context catching & granulated output
```RUBY
require 'rebus'

items = [:a, :b, :c]
Rebus.compile DATA do |line|
  puts line
end
  
# Output:
#
# <ul>
# <li>a</li>
# <li>b</li>
# <li>c</li>
# </ul>

__END__

<ul>
  |> items.each do |i|
    <li>#{i}</li>
  |> end
</ul>
```

### 6. Object as template context
```RUBY
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
  |> items.each do |i|
    <li>#{i}</li>
  |> end
</ul>
```

### 7. Keyword arguments as template context
```RUBY
require 'rebus'

puts Rebus.compile DATA, items: [:alpha, :beta, :gamma]
  
# Output:
#
# <ul>
# <li>alpha</li>
# <li>beta</li>
# <li>gamma</li>
# </ul>

__END__

<ul>
  |> items.each do |i|
    <li>#{i}</li>
  |> end
</ul>
```

`b.html.rbs` content:
```HTML
<ul>
  |> items.each do |i|
    <li>#{i}</li>
  |> end
</ul>
```
### 8. File content rendering
```RUBY
require 'rebus'

items = [:a, :b, :c]
puts Rebus.compile_file "b.html.rbs", binding
  
# Output:
#
# <ul>
# <li>a</li>
# <li>b</li>
# <li>c</li>
# </ul>

```

### 9. Setting file home path
```RUBY
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

```

### 10. Debugging - exception backtrace points to broken lines
```RUBY
require 'rebus'

puts Rebus.compile_file "b.html.rbs"
  
# Output:
#
# .../sample/b.html.rbs:2: undefined local variable or method `items'...

```

### 11. Setting template tokens
```RUBY
require 'rebus'

Rebus.code_prefix = "%"
Rebus.comment_prefix = "//"
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
    // this is comment line
    <li>#{i}</li>
    // <br>
  % end
</ul>
```


Authors
---
- Łukasz Pomietło (oficjalnyadreslukasza@gmail.com)
