node["packages"].each {|p| package p} if node["packages"]

# Config files
node["apps"].each_with_index do |app, i|
  directory "/var/www/#{app}/shared/config/" do
    recursive true
  end

  template "/var/www/#{app}/shared/config/database.yml" do
    source "rails_server/database.yml.erb"
    variables db_name: app
  end

  cookbook_file "application.yml" do
    path "/var/www/#{app}/shared/config/application.yml"
    ignore_failure true
  end

  template "/etc/logrotate.d/#{app}" do
    source "rails_server/logrotate_app.erb"
    variables app: app
  end

  template "/var/www/#{app}/shared/config/newrelic.yml" do
    source "rails_server/newrelic.yml.erb"
    variables app: app
  end if node["newrelic_key"]

  execute "change-permission /var/www/#{app}" do
    command "sudo chown -R #{node.system_user}:#{node.system_group} /var/www/#{app}"
  end

  bash "Configuring thin for #{app}" do
    code <<-EOH
      source /etc/environment
      thin config -C /etc/thin/#{app}.yml -c /var/www/#{app}/current -l log/thin.log -e #{node["environment"]} --servers 1 --port #{3000 + i}
    EOH
  end

  # Creating init scripts
  template "/etc/init.d/#{app}" do
    source "rails_server/init-script.sh.erb"
    variables app: app
    mode "0755"
  end
  execute "update-rc.d #{app} defaults"

  # Supervisor scripts
  template "/etc/supervisor/conf.d/#{app}.conf" do
    source "supervisord.conf.erb"
    variables app: app
  end
end

# Common code repo
if node.has_key? "common_repo"
  git "/var/www/common" do
    repository node["common_repo"]
  end
  node["apps"].each do |app|
    directory "/var/www/#{app}/releases/"
    link "/var/www/#{app}/releases/common" do
      to "/var/www/common"
    end
    link "/var/www/#{app}/common" do
      to "/var/www/common"
    end
  end
end
