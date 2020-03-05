class SecurityGroupController < BaseController
  def self.instance
    new(App::Models::SecurityGroup.new, App::Views::SecurityGroup.new)
  end

  def server
    execute(match, "server")
  end

  def securitygroup
    execute(match, "securitygroup")
  end

  private

  def execute(match, type)
    params = model.params(match[:expression])
    unless params
      return view.show_usage
    end

    query = %w(
      id
      ip
      port
    ).map { |n| "#{n}=#{params[n]}" if params[n] }.compact.join("&")
    view.tell("please open url: #{Settings.url}/#{type}/#{params['action']}?#{query}&user=#{data.user}")
  end
end
