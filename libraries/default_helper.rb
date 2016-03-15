class Chef
  class Node
    def server_name_for(app)
      env_subdomain = (node["environment"] == "production")? '':"#{node["environment"]}-"
      "#{env_subdomain}#{app}.#{domain_root_name}"
    end

    def domain_root_name
      node[:system][:domain_name]
    end

    def system_user
      node[:system][:user] || 'root'
    end
    def system_group
      node[:system][:group] || 'root'
    end
  end
  class Recipe
    def manage_ssh_keys(home, user)
      execute "Generate ssh keys for #{user}." do
        user user
        creates "#{home}/.ssh/id_rsa.pub"
        command "ssh-keygen -t rsa -q -f #{home}/.ssh/id_rsa -P \"\""
        not_if "ls #{home}/.ssh/id_rsa"
      end
      # Add Authorized keys
      cookbook_file "authorized_keys" do
        path "#{home}/.ssh/authorized_keys"
        mode 0644
        user user
        group user
      end

    end
  end
end