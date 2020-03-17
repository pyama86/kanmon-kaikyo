module App
  module Models
    class SecurityGroup < SlackRubyBot::MVC::Model::Base
      def params(text)
        text.match(/(?<action>[^\s]+)\s+(?<id_or_name>[^\s]+)\s?(?<tenant>[^\s]+)?$/i)
      end
    end
  end
end
