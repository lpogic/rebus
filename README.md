rebus - ruby stencil compiler
===

Universal template compiler based on ruby dynamic evaluation feature. 
Minimalistic design, customizable tokens, comments support, easy debugging.


For example this document was rendered from [readme.md.rbs](https://github.com/lpogic/white_gold/tree/master/doc/draft/readme.md.rbs) template.

Installation
---
```
gem install rebus
```

Basics
---

Rules are:
- input is interpreted line by line
- initial white spaces are ignored
- there are 3 different line types recognized by the following prefixes:
  - `#` - a comment line skipped during compilation
  - `|>` - a code line evaluated during compilation
  - any other prefix - a string line with possible interpolated code (see Ruby string interpolation rules)

#### Sample (stealed and translated from [ERB documentation](https://ruby-doc.org/stdlib-3.1.0/libdoc/erb/rdoc/ERB.html#class-ERB-label-Ruby+in+HTML)):


Template(Rebus - HTML):
```HTML
<html>
  <head><title>Ruby Toys -- #@name</title></head>
  <body>

    <h1>#@name (#@code)</h1>
    <p>#@desc</p>

    <ul>
      |> @features.each do |f|
        <li><b>#{f}</b></li>
      |> end
    </ul>

    <p>
      |> if @cost < 10
        <b>Only #@cost!!!</b>
      |> else
        Call for a price, today!
      |> end
    </p>

  </body>
</html>
```

Source code(Ruby):
```RUBY
require 'rebus'
require 'modeling' # to keep sample code concise

class Product
  model :@code, :@name, :@desc, :@cost do
    @features = [ ]
  end

  def add_feature( feature )
    @features << feature
  end
end

toy = Product.new( "TZ-1002",
  "Rubysapien",
  "Geek's Best Friend!  Responds to Ruby commands...",
  999.95 )
toy.add_feature("Listens for verbal commands in the Ruby language!")
toy.add_feature("Ignores Perl, Java, and all C variants.")
toy.add_feature("Karate-Chop Action!!!")
toy.add_feature("Matz signature on left leg.")
toy.add_feature("Gem studded eyes... Rubies, of course!")

puts Rebus.compile_file "a0.rbs", toy
```

Output(HTML):
```
<html>
<head><title>Ruby Toys -- Rubysapien</title></head>
<body>

<h1>Rubysapien (TZ-1002)</h1>
<p>Geek's Best Friend!  Responds to Ruby commands...</p>

<ul>
<li><b>Listens for verbal commands in the Ruby language!</b></li>
<li><b>Ignores Perl, Java, and all C variants.</b></li>
<li><b>Karate-Chop Action!!!</b></li>
<li><b>Matz signature on left leg.</b></li>
<li><b>Gem studded eyes... Rubies, of course!</b></li>
</ul>

<p>
Call for a price, today!
</p>

</body>
</html>
```

Usage
---
### 1. Render from string, |> code lines
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

### 2. #{Interpolation}, # comments
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

`b.html.rbs` content:
```HTML
<ul>
  |> items.each do |i|
    <li>#{i}</li>
  |> end
</ul>
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
