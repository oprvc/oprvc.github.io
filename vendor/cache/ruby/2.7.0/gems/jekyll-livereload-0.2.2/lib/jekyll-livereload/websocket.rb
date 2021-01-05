# Credit Alex Wood (https://github.com/awood) for most of this code.
# This was modified to work with both version 3.0.5 and 3.1.3 of Jekyll

# The MIT License (MIT)
#
# Copyright (c) 2014 Alex Wood
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'json'
require 'em-websocket'
require 'http/parser'

module Jekyll
  module Livereload
    # The LiveReload protocol requires the server to serve livereload.js over HTTP
    # despite the fact that the protocol itself uses WebSockets.  This custom connection
    # class addresses the dual protocols that the server needs to understand.
    class HttpAwareConnection < EventMachine::WebSocket::Connection
      attr_reader :reload_file

      def initialize(opts)
        @reload_file = File.join(LIVERELOAD_DIR, "livereload.js")
        super opts
      end

      def dispatch(data)
        parser = Http::Parser.new
        parser << data

        # WebSockets requests will have a Connection: Upgrade header
        if parser.http_method != 'GET' || parser.upgrade?
          super
        elsif parser.request_url =~ /^\/livereload.js/
          headers = [
            'HTTP/1.1 200 OK',
            'Content-Type: application/javascript',
            "Content-Length: #{File.size(reload_file)}",
            '',
            '',
          ].join("\r\n")
          send_data(headers)
          stream_file_data(reload_file).callback do
            close_connection_after_writing
          end
        else
          body = "This port only serves livereload.js over HTTP.\n"
          headers = [
            'HTTP/1.1 400 Bad Request',
            'Content-Type: text/plain',
            "Content-Length: #{body.bytesize}",
            '',
            '',
          ].join("\r\n")
          send_data(headers)
          send_data(body)
          close_connection_after_writing
        end
      end
    end

    class Reactor
      attr_reader :thread
      attr_reader :opts

      def initialize(opts)
        @opts = opts
        @thread = nil
        @websockets = []
        @connections_count = 0
      end

      def stop
        @thread.kill unless @thread.nil?
        Jekyll.logger.debug("LiveReload Server:", "halted")
      end

      def running?
        !@thread.nil? && @thread.alive?
      end

      def start
        @thread = Thread.new do
          # Use epoll if the kernel supports it
          EM.epoll
          EM.run do
            protocol = @opts[:secure] ? "https" : "http"
            Jekyll.logger.info("LiveReload Server:", "#{protocol}://#{@opts['host']}:#{@opts['reload_port']}")
            EM.start_server(@opts['host'], @opts['reload_port'], HttpAwareConnection, @opts) do |ws|
              ws.onopen do |handshake|
                connect(ws, handshake)
              end

              ws.onclose do
                disconnect(ws)
              end

              ws.onmessage do |msg|
                print_message(msg)
              end
            end
          end
        end
      end

      # For a description of the protocol see http://feedback.livereload.com/knowledgebase/articles/86174-livereload-protocol
      def reload
        Livereload.pages.each do |p|
          msg = {
            :command => 'reload',
            :path => p.path,
            :liveCSS => true,
          }

          # TODO Add support for override URL?
          # See http://feedback.livereload.com/knowledgebase/articles/86220-preview-css-changes-against-a-live-site-then-uplo

          Jekyll.logger.debug("LiveReload:", "Reloading #{p.path}")
          @websockets.each do |ws|
            ws.send(JSON.dump(msg))
          end
        end
        Livereload.pages.clear
      end

      private

      def connect(ws, _handshake)
        @connections_count += 1
        Jekyll.logger.info("LiveReload:", "Browser connected") if @connections_count == 1
        ws.send(
          JSON.dump(
            :command => 'hello',
            :protocols => ['http://livereload.com/protocols/official-7'],
            :serverName => 'jekyll livereload',
          ))

        @websockets << ws
      end

      def disconnect(ws)
        @websockets.delete(ws)
      end

      def print_message(json_message)
        msg = JSON.parse(json_message)
        # Not sure what the 'url' command even does in LiveReload
        Jekyll.logger.info("LiveReload:", "Browser URL: #{msg['url']}") if msg['command'] == 'url'
      end
    end
  end
end
