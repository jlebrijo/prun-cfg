%w(libmagickwand-dev libcurl4-openssl-dev).each {|p| package p}

# Config files
node["apps"].each_with_index do |app, i|
  directory "/var/www/#{app}/shared/config/" do
    recursive true
  end

  template "/var/www/#{app}/shared/config/database.yml" do
    variables db_name: app
  end

  cookbook_file "application.yml" do
    path "/var/www/#{app}/shared/config/application.yml"
  end

  bash "Configuring thin for #{app}" do
    code <<-EOH
      source /etc/environment
      thin config -C /etc/thin/#{app}.yml -c /var/www/#{app}/current -l log/thin.log -e #{node["rails_env"]} --servers 1 --port #{3000 + i}
    EOH
  end

  # Creating init scripts
  template "/etc/init.d/#{app}" do
    source "init-script.sh.erb"
    variables app: app
    mode "0755"
  end
  execute "update-rc.d #{app} defaults"

end

# Images directories
directory "/var/www/www/shared/public/uploads/" do
  recursive true
end
directory "/var/www/app/shared/public/" do
  recursive true
end
link "/var/www/app/shared/public/uploads" do
  to "/var/www/www/shared/public/uploads"
end

# Common code repo
if node.has_key? "common_repo"
  git "/var/www/common" do
    repository node["common_repo"]
  end
  node["apps"].each do |app|
    link "/var/www/#{app}/releases/common" do
      to "/var/www/common"
    end
    link "/var/www/#{app}/common" do
      to "/var/www/common"
    end
  end
end
