module App
  module Models
    class SecurityGroup < SlackRubyBot::MVC::Model::Base
      def params(text)
        text.match(/(?<action>[^\b\s]+)[\b\s]+(?<id_or_name>[^\s\b]+)[\b\s]?(?<tenant>[^\s\b]+)?$/i)
      end
    end
  end
end
