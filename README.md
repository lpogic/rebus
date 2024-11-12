rebus - Ruby stencil compiler
===

Rebus template language compiler based on Ruby dynamic evaluation.
Minimalistic and customizable.


For example this document was rendered from [readme.md.rbs](https://github.com/lpogic/rebus/blob/main/doc/draft/readme.md.rbs) template.

Installation
---
```
gem install rebus
```

Basics
---

Rules are:
- input is interpreted line by line
- there are 3 different line types recognized by the following prefixes:
  - `# `  - a comment line skipped during compilation
  - `$ `  - a code line evaluated during compilation
  - any other - a string line with possible interpolated code (see Ruby string interpolation rules)

#### Sample (stealed and translated from [ERB documentation](https://ruby-doc.org/stdlib-3.1.0/libdoc/erb/rdoc/ERB.html#class-ERB-label-Ruby+in+HTML)):


Template(Rebus - HTML):
```HTML
<html>
  <head><title>Ruby Toys -- #@name</title></head>
  <body>

    <h1>#@name (#@code)</h1>
    <p>#@desc</p>

    <ul>
      $ @features.each do |f|
      <li><b>#{f}</b></li>
      $ end
    </ul>

    <p>
      $ if @cost < 10
      <b>Only #@cost!!!</b>
      $ else
      Call for a price, today!
      $ end
    </p>

  </body>
</html>
```

Source code(Ruby):
```RUBY
require 'rebus'
require 'modeling' # to keep sample code concise

class Product
  model :code, :name, :desc, :cost do
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
```HTML
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
[Wiki](https://github.com/lpogic/rebus/blob/main/doc/wiki/README.md)

Authors
---
- Łukasz Pomietło (oficjalnyadreslukasza@gmail.com)
