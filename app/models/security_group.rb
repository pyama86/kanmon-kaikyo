module App
  module Models
    class SecurityGroup < SlackRubyBot::MVC::Model::Base
      def params(text)
        text.match(/(?<action>[^\s]+)\s+(?<project>[^\s]+)\s+(?<id>[^\s]+)\s?(?<ip>[^\s]+)?\s?(?<port>[^\s]+)?$/i)
      end
    end
  end
end
