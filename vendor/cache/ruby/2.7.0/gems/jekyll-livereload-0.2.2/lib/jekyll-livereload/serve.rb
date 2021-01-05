require_relative 'configuration'

# Allows us to add more option parameter to the serve command
module Mercenary
  class Command
    def command(cmd_name)
      Jekyll.logger.debug "Refined Command"
      cmd = @commands[cmd_name] || Command.new(cmd_name, self)
      yield cmd
      @commands[cmd_name] = cmd
    end
  end
end

# Monkey Patch the Serve command to do a few things before the built-in
# Serve command methods are invoked.
module Jekyll
  module Livereload
    module Serve
      include Livereload::Configuration

      def init_with_program(prog)
        prog.command(:serve) do |c|
          c.option 'livereload', '-L', '--livereload', 'Inject Livereload.js and run a WebSocket Server'
          c.option 'reload_port', '-R', '--reload_port [PORT]', Integer, 'Port to serve Livereload on'
        end

        super prog
      end

      def process(opts)
        opts = load_config_options(opts)
        if opts['livereload']
          Livereload.reactor = Livereload::Reactor.new(opts)
          Livereload.reactor.start
        end

        super opts
      end
    end
  end
end
