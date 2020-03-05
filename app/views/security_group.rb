module App
  module Views
    class SecurityGroup < Base

      def self.usage
        <<EOS
```
@kanmon-kaikyo server <open|close> <server_id> <ip:option> <port:option>
@kanmon-kaikyo securitygroup <open|close> <security_group_id> <ip:option> <port:option>
```
EOS
      end
    end
  end
end
