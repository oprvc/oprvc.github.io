# -*- encoding: utf-8 -*-
# stub: jekyll-livereload 0.2.2 ruby lib

Gem::Specification.new do |s|
  s.name = "jekyll-livereload".freeze
  s.version = "0.2.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Robert DeRose".freeze]
  s.date = "2016-09-02"
  s.description = "    This is a plugin for Jekyll. It adds additional command line options to\n    the server command to provide Livereloading capabilities.\n".freeze
  s.email = ["RobertDeRose@gmail.com".freeze]
  s.homepage = "https://github.com/RobertDeRose/jekyll-livereload".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.0.0".freeze)
  s.rubygems_version = "3.1.2".freeze
  s.summary = "Adds LiveReload support to Jekyll's included Server".freeze

  s.installed_by_version = "3.1.2" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<jekyll>.freeze, ["~> 3.0"])
    s.add_runtime_dependency(%q<em-websocket>.freeze, ["~> 0.5"])
    s.add_development_dependency(%q<bundler>.freeze, ["~> 1.12"])
  else
    s.add_dependency(%q<jekyll>.freeze, ["~> 3.0"])
    s.add_dependency(%q<em-websocket>.freeze, ["~> 0.5"])
    s.add_dependency(%q<bundler>.freeze, ["~> 1.12"])
  end
end
