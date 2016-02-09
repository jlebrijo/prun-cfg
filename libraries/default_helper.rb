class Chef
  class Node
    def server_name_for(app)
      env_subdomain = (node["environment"] == "production")? '':"#{node["environment"]}-"
      "#{env_subdomain}#{app}.#{domain_root_name}"
    end

    def domain_root_name
      node.name.split('.')[-2..-1].join('.')
    end

    def system_user
      node[:system][:user] || 'root'
    end
    def system_group
      node[:system][:group] || 'root'
    end
  end
end