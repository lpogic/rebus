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