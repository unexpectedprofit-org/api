# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "rerun"
  s.version = "0.8.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Alex Chaffee"]
  s.date = "2013-10-16"
  s.description = "Restarts your app when a file changes. A no-frills, command-line alternative to Guard, Shotgun, Autotest, etc."
  s.email = "alex@stinky.com"
  s.executables = ["rerun"]
  s.extra_rdoc_files = ["README.md"]
  s.files = ["bin/rerun", "README.md"]
  s.homepage = "http://github.com/alexch/rerun/"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.25"
  s.summary = "Launches an app, and restarts it whenever the filesystem changes. A no-frills, command-line alternative to Guard, Shotgun, Autotest, etc."

  if s.respond_to? :specification_version then
    s.specification_version = 2

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<listen>, ["~> 1.0.3"])
    else
      s.add_dependency(%q<listen>, ["~> 1.0.3"])
    end
  else
    s.add_dependency(%q<listen>, ["~> 1.0.3"])
  end
end
