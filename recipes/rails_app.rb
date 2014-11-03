%w(libmagickwand-dev libcurl4-openssl-dev).each {|p| package p}

# Config files
node["apps"].each_with_index do |app, i|
  directory "/var/www/#{app}/shared/config/" do
    recursive true
  end
  template "/var/www/#{app}/shared/config/database.yml" do
    source "database.yml.erb"
  end
  cookbook_file "application.yml" do
    path "/var/www/#{app}/shared/config/application.yml"
  end
  execute "/usr/local/ruby/2.1.2/bin/thin config -C /etc/thin/#{app}.yml -c /var/www/#{app}/current -l log/thin.log -e #{node["rails_env"]} --servers 1 --port #{3000 + i}"
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