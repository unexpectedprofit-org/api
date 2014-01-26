# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "needle"
  s.version = "1.3.0"

  s.required_rubygems_version = nil if s.respond_to? :required_rubygems_version=
  s.authors = ["Jamis Buck"]
  s.autorequire = "needle"
  s.cert_chain = nil
  s.date = "2005-12-24"
  s.email = "jamis@37signals.com"
  s.extra_rdoc_files = ["doc/README"]
  s.files = ["doc/README"]
  s.homepage = "http://needle.rubyforge.org"
  s.rdoc_options = ["--title", "Needle -- Dependency Injection for Ruby", "--main", "doc/README"]
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new("> 0.0.0")
  s.rubygems_version = "1.8.25"
  s.summary = "Needle is a Dependency Injection/Inversion of Control container for Ruby. It supports both type-2 (setter) and type-3 (constructor) injection. It takes advantage of the dynamic nature of Ruby to provide a rich and flexible approach to injecting dependencies."

  if s.respond_to? :specification_version then
    s.specification_version = 1

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
