module App
  module Views
    class Base < SlackRubyBot::MVC::View::Base

      include SlackApiCallerble

      def self.usage
        "please define usage message"
      end

      def in_thread?
        !!data.thread_ts
      end

      def show_usage
        if in_thread?
          reply_on_thread(self.class.usage)
        else
          reply(self.class.usage)
        end
      end

      def reply(text, options={})
        message = {
          icon_emoji: :kanmon_kaikyo,
          channel: data.channel,
          text: text,
          as_user: true,
        }.merge(options)

        App::Registry.bot_token_client.chat_postMessage(message)
      end

      def tell(text, options={})
        message = {
          username:  client.name,
          icon_emoji: :kanmon_kaikyo,
          channel: data.channel,
          user: data.user,
          text: text,
          as_user: true,
        }.merge(options)

        App::Registry.bot_token_client.chat_postEphemeral(message)
      end

      def say(text, options={})

        options = {
          channel: data.channel,
          text: text,
        }.merge(options)

        client.say(options)
      end

      def reply_on_thread(text, options={})
        options[:thread_ts] = data.thread_ts || data.ts
        reply(text, options)
      end

      def notify_exception(e)
        attachments = [
          {
            text: "```%s\n%s```" % [e, e.backtrace.join("\n")],
            color: "#ff0000",
          }
        ]

        reply_on_thread("sorry... :fire:", attachments: attachments)
      end
    end
  end
end
