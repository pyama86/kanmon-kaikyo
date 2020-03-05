require 'slack-ruby-bot'
require 'sinatra'
require 'sinatra'
require_relative '../app/registry'
require_relative '../app/api'

require "dotenv"
Dotenv.load

[
  'mixins',
  'hooks',
  'models',
  'views',
  'controllers',
].each { |subdir|
  Dir[File.join(File.dirname(__FILE__), '../app', subdir, '**/*.rb')].sort.each do |file|
    require file
  end
}

require 'config'
Config.load_and_set_settings(Config.setting_files("config", ENV['APP_ENV']))

module App
  class Bot < SlackRubyBot::App
    def start_rtm_pong_server
      Thread.new do
        server = TCPServer.new 1234
        loop do
          begin
            sock = server.accept
            client.ping
            line = sock.gets
            sock.write("HTTP/1.0 200 OK\n\nok")
            sock.close
          end
        end
      end
    end
  end

  def logger
    App::Bot.instance.logger
  end

  def env
    @env ||= Class.new {
      class << self
        def production?
          ENV["APP_ENV"] == 'production'
        end

        def development?
          ENV["APP_ENV"] == 'development'
        end

        def test?
          ENV["APP_ENV"] == 'test'
        end
      end
    }
  end

  module_function :logger
  module_function :env
end

Dir[File.join(File.dirname(__FILE__), '../config/initializers/*.rb')].sort.each do |file|
  require file
end
