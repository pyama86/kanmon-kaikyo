module App
  module Hooks
    module Hello
      class SayHello < App::Hooks::Base

        @@connected = false

        def call(client, data)

          text = if @@connected
                   'RTM 再接続しました. pid:%d' %  Process.pid
                 else
                   @@connected = true
                   'RTM つなぎました. pid:%d' %  Process.pid
                 end

          params = {
            channel: Settings.hooks.hello.channel,
            text: text,
            as_user: 'true',
            icon_emoji: :sssbot,
          }

          App::Registry.bot_token_client.chat_postMessage(params)

          # slack につないだ際に domain = workspace の名前を取れるので registry に登録しておく
          App::Registry.register(:domain, client.team.domain)

          if ARGV[0] &.match(/console/)
            DebugController.dispatch(:debug_console, client, data, nil)
          end

          if App.env.development?
            `terminal-notifier -title sssbot -message 'successfully connected'`
          end
        end
      end
    end
  end
end

