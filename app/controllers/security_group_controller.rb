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
    Yao::Project.list.each do |t|
      next if %w(petit).include?(t.name)
      begin
        tenant = ENV['OS_TENANT_NAME']
        ENV['OS_TENANT_NAME'] = t.name
        Kanmon.init_yao
        Yao::SecurityGroup.list(project_id: t.id).each do |s|
          m = s.name.match(/kanmon-([^:]+):(.+)-user:(.+)$/)
          next unless m
          Yao::Server.remove_security_group(m[2], s.id) rescue nil
          Yao::SecurityGroup.destroy(s.id)
          view.reply("heimon success #{s.name}")
        end
      rescue => e
        view.reply("can't heimon tenant #{t.name} error:#{e.inspect}")
      ensure
        ENV['OS_TENANT_NAME'] = tenant
      end
    end
    Kanmon.init_yao
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

    if blocks.empty?
      view.reply("not found")
    else
      view.reply(nil, params)
    end

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
