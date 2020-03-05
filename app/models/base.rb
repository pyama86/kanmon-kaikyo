module App
  module Models
    class Base < SlackRubyBot::MVC::Model::Base
      include SlackRubyBot::Loggable
      include SlackApiCallerble

      def pin(message)
        App::Registry.bot_token_client.pins_add(channel: message.channel, timestamp: message.ts)
      end

      def settings
        # ['App', 'Models', 'Docs']
        _, mvc, klass = self.class.name.split('::')

        # Settings['models']['docs']
        Settings[mvc.downcase][klass.downcase]
      end
    end
  end
end
