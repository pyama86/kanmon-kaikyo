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

  def heimon
    Yao::Project.list.map do |t|
      Yao::SecurityGroup.list(project_id: t.id).map do |s|
        m = s.name.match(/kanmon-([^:]+):(.+)-user:(.+)$/)
        next unless m
        tenant = ENV['OS_TENANT_NAME']
        begin
          ENV['OS_TENANT_NAME'] = t.name
          Kanmon.init_yao
          server = Kanmon::Server.new(m[2], nil)
          server.user_name = m[3]
          server.close
          view.reply("heimon success #{s.name}")
        rescue => e
          view.reply("can't heimon #{s.name}")
        ensure
          ENV['OS_TENANT_NAME'] = tenant
        end
      end
    end
    view.reply("heimon done!")
  end

  def list
    blocks = Yao::Project.list.map do |t|
      Yao::SecurityGroup.list(project_id: t.id).map do |s|
        m = s.name.match(/kanmon-([^:]+):(.+)-user:(.+)$/)
        next unless m
        {
          type: "section",
          fields: [
            {
              type: "mrkdwn",
              text: "*名前*:#{s.name}"
            },
            {
              type: "mrkdwn",
              text: "*作成日*:#{s['created_at']}"
            },
            {
              type: "mrkdwn",
              text: "*テナント*:#{t.name}"
            },
            {
              type: "mrkdwn",
              text: "*作成者*:#{m[3]}"
            }

          ],
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

    if params["id_or_name"] =~ /[^-]{8}-[^-]{4}-[^-]{4}-[^-]{4}-[^-]{12}/
      s = Yao::Server.get(params["id_or_name"])
      tenant_name = Yao::Project.get(s.tenant_id).name
      view.tell("server: #{s.name} url: #{Settings.url}/#{type}/#{params['action']}?user=#{data.user}&tenant_name=#{tenant_name}&id=#{params["id_or_name"]}")
    elsif params["tenant"]
      Yao::Server.list(all_tenants: true, project_id: Yao::Project.list.find {|t| t.name == params["tenant"] }.id).select {|s| s.name =~ /#{params["id_or_name"]}/ }.each do |s|
        view.tell("server #{s.name} url: #{Settings.url}/#{type}/#{params['action']}?user=#{data.user}&tenant_name=#{params["tenant"]}&id=#{s.id}")
      end
    else
      view.tell("sorry,can't response your request")
    end
  end
end
