require_relative "./lib/rebus/version"

Gem::Specification.new do |s|
  s.name        = "rebus"
  s.version     = Rebus::VERSION
  s.summary     = "Ruby stencil compiler"
  s.description = <<~EOT
    Rebus template language compiler based on Ruby dynamic evaluation.
    Minimalistic and customizable.
  EOT
  s.authors     = ["Łukasz Pomietło"]
  s.email       = "oficjalnyadreslukasza@gmail.com"
  s.files       = Dir.glob('lib/**/*')
  s.homepage    = "https://github.com/lpogic/rebus"
  s.license       = "Zlib"
  s.required_ruby_version     = ">= 3.2.2"
  s.add_runtime_dependency("modeling", "~> 0.1.0")
  s.metadata = {
    "documentation_uri" => "https://github.com/lpogic/rebus/blob/main/doc/wiki/README.md",
    "homepage_uri" => "https://github.com/lpogic/rebus"
  }
end