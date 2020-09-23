module App
  module Views
    class SecurityGroup < Base

      def self.usage
        <<EOS
```
@kanmon-kaikyo server <open|close> <server_id or server_name> <tenant_name>
```
EOS
      end
    end
  end
end
