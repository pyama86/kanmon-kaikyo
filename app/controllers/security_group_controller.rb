class SecurityGroupController < BaseController
  def self.instance
    Yao.configure do
      auth_url             ENV['OS_AUTH_URL']
      tenant_name          ENV['OS_TENANT_NAME']
      username             ENV['OS_USERNAME']
      password             ENV['OS_PASSWORD']
      client_cert          ENV['OS_CERT']
      client_key           ENV['OS_KEY']
      region_name          ENV['OS_REGION_NAME']
      identity_api_version ENV['OS_IDENTITY_API_VERSION']
      user_domain_name     ENV['OS_USER_DOMAIN_NAME']
      project_domain_name  ENV['OS_PROJECT_DOMAIN_NAME']
      debug                ENV['YAO_DEBUG']
    end

    new(App::Models::SecurityGroup.new, App::Views::SecurityGroup.new)
  end

  def server
    execute(match, "server")
  end

  def securitygroup
    execute(match, "securitygroup")
  end

  def list
    blocks = Yao::Project.list.map do |t|
      Yao::SecurityGroup.list(project_id: t.id).map do |s|
        m = s.name.match(/kanmon-([^:]+):(.+)-user:(.+)$/)
        next unless m
        {
          type: "section",
          text: {
            type: "mrkdwn",
            text: "名前:#{s.name} 作成日:#{s['created_at']} テナント:#{t.name}"
          },
          accessory: {
            action_id: "delete_sg_handler",
            type: "button",
            url: "#{Settings.url}/#{m[1]}/close?id=#{m[2]}&username=#{m[3]}&tenant_name=#{t.name}",
            text: {
              type: "plain_text",
              text: "削除 :sushi:",
              emoji: true
            },
            value: "delete_sg_handler"
          }
        }
      end
    end.flatten.compact
    params = {
      channel: data.channel,
      blocks: blocks
    }

    view.reply(nil, params)

  end
  private

  def execute(match, type)
    params = model.params(match[:expression])
    unless params
      return view.show_usage
    end

    tenant_name = if type == "server"
                    Yao::Project.get(Yao::Server.get(params["id"]).tenant_id).name
                  else
                    Yao::Project.get(Yao::SecurityGroup.get(params["id"]).tenant_id).name
                  end
    query = %w(
      id
      ip
      port
    ).map { |n| "#{n}=#{params[n]}" if params[n] }.compact.join("&")
    view.tell("please open url: #{Settings.url}/#{type}/#{params['action']}?#{query}&user=#{data.user}&tenant_name=#{tenant_name}")
  end
end
