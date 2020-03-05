class BaseController < SlackRubyBot::MVC::Controller::Base

  include SlackRubyBot::Loggable

  define_callbacks :exception
  set_callback :exception, :around, :around_reaction

  class << self
    attr_accessor :controller_classes

    def inherited(subclass)
      self.controller_classes ||= []
      self.controller_classes << subclass
    end

    def dispatch(method, client, data, match)
      c = instance
      c.use_args(client, data, match)
      c.send(method)
    end

    def action_dispatch(method, payload, match={})

      params = {
        user: payload.user.id,
        channel: payload.channel.id,
        ts: payload.actions.first.action_ts,
      }
      data = Slack::Messages::Message.new(params)

      c = instance
      c.use_args(nil, data, match)
      c.send(method)
    end
  end

  protected

  def around_reaction
    file, line, method = parse_caller(caller[2])
    logger.debug("Controller >> %s %s: %s" % [file, line, method])
    logger.debug("%s" % data.to_h)
    logger.debug("%s" % match)

    yield
  rescue => e
    unless App.env.test?
      view.notify_exception(e)
    end

    raise e
  end

  def parse_caller(at)
    if /^(.+?):(\d+)(?::in `(.*)')?/ =~ at
      file = $1
      line = $2.to_i
      method = $3
      [file, line, method]
    end
  end
end
