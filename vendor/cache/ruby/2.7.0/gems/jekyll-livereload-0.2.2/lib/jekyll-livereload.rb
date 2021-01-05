require 'jekyll'

module Jekyll
  module Livereload
    LIVERELOAD_PORT = 35729
    LIVERELOAD_DIR = File.expand_path("../js", File.dirname(__FILE__))

    class << self
      attr_accessor(:pages, :reactor)
      def pages
        @pages ||= []
      end
    end

    require "jekyll-livereload/build"
    require "jekyll-livereload/serve"
    require "jekyll-livereload/version"
    require "jekyll-livereload/websocket"
  end
end

# Add livereload support the Jekyll
class << Jekyll::Commands::Serve
  prepend Jekyll::Livereload::Serve
end

class << Jekyll::Commands::Build
  prepend Jekyll::Livereload::Build
end
