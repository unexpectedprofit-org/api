# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "constructor"
  s.version = "2.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Atomic Object"]
  s.date = "2010-12-29"
  s.description = "Declarative means to define object properties by passing a hash to the constructor, which will set the corresponding ivars."
  s.email = ["github@atomicobject.com"]
  s.homepage = "http://atomicobject.github.com/constructor"
  s.require_paths = ["lib"]
  s.rubyforge_project = "constructor"
  s.rubygems_version = "1.8.25"
  s.summary = "Declarative named-argument object initialization."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, ["<= 1.3.1", ">= 1"])
      s.add_development_dependency(%q<rake>, [">= 0.8.7"])
    else
      s.add_dependency(%q<rspec>, ["<= 1.3.1", ">= 1"])
      s.add_dependency(%q<rake>, [">= 0.8.7"])
    end
  else
    s.add_dependency(%q<rspec>, ["<= 1.3.1", ">= 1"])
    s.add_dependency(%q<rake>, [">= 0.8.7"])
  end
end
