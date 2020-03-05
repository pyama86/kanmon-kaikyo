class HelpController < BaseController
  def self.instance
    new(App::Models::Base.new, App::Views::SecurityGroup.new)
  end

  # help
  def help
    view.reply(":eye: Only visible to you で表示します")
    view.tell(view.show_usage)
  end
end
