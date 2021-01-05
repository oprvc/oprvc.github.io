module Jekyll
  module Livereload
    module Configuration
      private
      def load_config_options(opts)
        opts = configuration_from_options(opts)
        opts['host'] = 'localhost' unless opts.key?('host')
        opts['reload_port'] = Livereload::LIVERELOAD_PORT unless opts.key?('reload_port')

        if opts['ssl_cert'] && opts['ssl_key']
          opts[:tls_options] = {
            :private_key_file => Jekyll.sanitized_path(opts['source'], opts['ssl_key']),
            :cert_chain_file => Jekyll.sanitized_path(opts['source'], opts['ssl_cert']),
          }
          opts[:secure] = true
        end

        return opts
      end
    end
  end
end
