module App
  module Hooks
    class Base

      include SlackApiCallerble

      protected
      # @return String
      def collapse_message_text(message)
        if attachment = message.attachments &.first
          [
            message.text       || "",
            attachment.text    || "",
            attachment.pretext || "",
            attachment.title   || "",
          ].join
        else
          message.text
        end
      end

      def find_reacted_message(data)
        result = user_token_client.channels_history(
          channel: data.item.channel,
          oldest: data.item.ts,
          latest: data.item.ts,
          inclusive: true,
          count: 1,
        )
        result.messages.first
      end
    end
  end
end
