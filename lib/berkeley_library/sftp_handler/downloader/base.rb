module BerkeleyLibrary
  module SftpHandler
    module Downloader
      class Base
        # The base downloader class defines the interface and provides helper methods
        # for provider-specific downloaders. To implement a new provider, inherit from
        # this class and implement the `download!` method.
        #
        # This class's `initialize` method handles pulling all relevant connection configuration
        # information from the environment. Individual options can be overwritten at runtime by
        # setting ENV['LIT_<CLASS_NAME>_<VALUE>']. For example, to override the Gobi password, set
        # it in LIT_GOBI_PASSWORD. This behavior is automatic and should work as-is when adding new
        # downloader classes.

        attr_accessor :host, :username, :password, :keys, :key_data

        def download!
          raise NotImplementedError, 'Child classes must implement this method'
        end

        def initialize(host: nil, username: nil, password: nil, keys: nil, key_data: nil)
          @host = host || default_for(:host)
          @username = username || default_for(:username)
          @password = password || default_for(:password)
          @keys = keys || default_for(:keys, '').split(',')

          key_data ||= default_for(:key_data)
          @key_data = key_data.is_a?(Array) ? key_data : [key_data].compact
        end

        def connect(&block)
          puts "Connecting to sftp://#{@username}@#{@host}"
          Net::SFTP.start(@host, @username, ssh_options, sftp_options, &block)
        end

        def ssh_options
          @ssh_options ||= {}.tap do |opts|
            opts[:key_data] = @key_data unless @key_data.nil? || @key_data.empty?
            opts[:keys] = @keys unless @keys.nil? || @keys.empty?
            opts[:password] = @password unless @password.nil?
          end
        end

        def assert_not_exists!(local_path)
          raise "Local file already exists: #{local_path}" \
            if Pathname.new(local_path).exist?
        end

        def sftp_options
          @sftp_options ||= {}
        end

        # Helper method for pulling default initializer values from the environment
        def default_for(option, fallback = nil)
          envvar = "#{config_prefix}#{option.to_s.upcase}"
          getter = "default_#{option}".to_sym
          ENV.fetch(envvar, respond_to?(getter) ? send(getter) : fallback)
        end

        def default_host
          nil
        end

        def default_username
          nil
        end

        def config_prefix
          "LIT_#{self.class.name.split('::').last.upcase}_"
        end
      end
    end
  end
end
