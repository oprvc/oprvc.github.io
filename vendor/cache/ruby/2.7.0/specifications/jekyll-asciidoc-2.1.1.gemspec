# -*- encoding: utf-8 -*-
# stub: jekyll-asciidoc 2.1.1 ruby lib

Gem::Specification.new do |s|
  s.name = "jekyll-asciidoc".freeze
  s.version = "2.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Dan Allen".freeze, "Paul Rayner".freeze]
  s.date = "2018-11-09"
  s.description = "A Jekyll plugin that converts the AsciiDoc source files in your site to HTML pages using Asciidoctor.".freeze
  s.email = ["dan.j.allen@gmail.com".freeze]
  s.homepage = "https://github.com/asciidoctor/jekyll-asciidoc".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.3".freeze)
  s.rubygems_version = "3.1.2".freeze
  s.summary = "A Jekyll plugin that converts the AsciiDoc source files in your site to HTML pages using Asciidoctor.".freeze

  s.installed_by_version = "3.1.2" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<asciidoctor>.freeze, [">= 1.5.0"])
    s.add_runtime_dependency(%q<jekyll>.freeze, [">= 2.3.0"])
    s.add_development_dependency(%q<rake>.freeze, [">= 0"])
    s.add_development_dependency(%q<rspec>.freeze, ["~> 3.5.0"])
  else
    s.add_dependency(%q<asciidoctor>.freeze, [">= 1.5.0"])
    s.add_dependency(%q<jekyll>.freeze, [">= 2.3.0"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.5.0"])
  end
end
