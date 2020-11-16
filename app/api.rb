require 'sinatra/reloader' if development?
require 'sinatra/custom_logger'
require 'kanmon'
require "thread"
require 'raven'
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
      begin
        m.lock
        server("open", params, request)
      ensure
        m.unlock
      end
    end

    get '/server/close' do
      content_type 'text/plain; charset=utf8'
      server("close", params, request)
    end

    def m
      @locker ||= Mutex::new
      @locker
    end

    def server(type, params, request)
      return 'server id is required' if !params['id'] || params['id'].empty?
      ENV['OS_TENANT_NAME'] = params['tenant_name'] if params['tenant_name']
      Kanmon.init_yao
      s = Kanmon::Server.new(params['id'], params['port'], params['ip'] || request.ip)
      s.user_name = params['username'] || App::Registry.find(:bot_token_client).users_info(user: params['user']).user.name
      s.send(type)
      'success'
    rescue Kanmon::AlreadySecurityExistsError
      'already exist'
    rescue => e
      Raven.capture_exception(e)
    end

    def securitygroup(type, params, request)
      Kanmon.init_yao
      Kanmon::SecurityGroup.new(params['id'], params['port'], params['ip'] || request.ip).send(type)
      'success'
    rescue Kanmon::AlreadySecurityExistsError
      'already exist'
    end
  end
end
