require 'sinatra/reloader' if development?
require 'sinatra/custom_logger'
require 'kanmon'

module App
  class Api < Sinatra::Base
    helpers Sinatra::CustomLogger
    configure :development, :staging, :production do
      logger = Logger.new(STDERR)
      logger.level = Logger::DEBUG if development?
      set :logger, logger
      set :public_folder, 'assets/public'
    end

    # for livenessProbe
    get '/' do
      content_type 'text/plain; charset=utf8'
      'ok'
    end

    get '/server/open' do
      content_type 'text/plain; charset=utf8'
      server("open", params, request)
    end

    get '/server/close' do
      content_type 'text/plain; charset=utf8'
      server("close", params, request)
    end

    get '/securitygroup/open' do
      content_type 'text/plain; charset=utf8'
      securitygroup("open", params, request)
    end

    get '/securitygroup/close' do
      content_type 'text/plain; charset=utf8'
      securitygroup("close", params, request)
    end

    def server(type, params, request)
      ENV['OS_TENANT_NAME'] = params['project']
      Kanmon.init_yao
      s = Kanmon::Server.new(params['id'], params['port'], params['ip'] || request.ip)
      s.user_name = params['user']
      s.send(type)
      'success'
    end

    def securitygroup(type, params, request)
      ENV['OS_TENANT_NAME'] = params['project']
      Kanmon.init_yao
      Kanmon::SecurityGroup.new(params['id'], params['port'], params['ip'] || request.ip).send(type)
      'success'
    end
  end
end
