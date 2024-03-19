require_relative "./lib/rebus/version"

Gem::Specification.new do |s|
  s.name        = "rebus"
  s.version     = Rebus::VERSION
  s.summary     = "ruby stencil processor"
  s.description = <<~EOT
    Universal template processor based on ruby dynamic evaluation feature. 
    Minimalistic design, customizable tokens, comments support, easy debugging.
  EOT
  s.authors     = ["Łukasz Pomietło"]
  s.email       = "oficjalnyadreslukasza@gmail.com"
  s.files       = Dir.glob('lib/**/*')
  s.homepage    = "https://github.com/lpogic/rebus"
  s.license       = "Zlib"
  s.required_ruby_version     = ">= 3.2.2"
  s.add_runtime_dependency("modeling", "~> 0.0.4")
  s.metadata = {
    "documentation_uri" => "https://github.com/lpogic/rebus/blob/main/doc/wiki/README.md",
    "homepage_uri" => "https://github.com/lpogic/rebus"
  }
end