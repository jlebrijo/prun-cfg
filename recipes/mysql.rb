bash "Installing MySQL" do
  code <<-EOH
    debconf-set-selections <<< 'mysql-server mysql-server/root_password password #{node["db"]['password']}'
    debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password #{node["db"]['password']}'
    apt-get install -y mysql-server mysql-client libmysqlclient-dev
  EOH
  not_if "which mysql"
end

node["apps"].each do |app|
  bash "Create #{app} database" do
    code <<-EOH
      mysql --user='root' --password='#{node["db"]["root_password"]}' --execute='create database #{app};'
      mysql --user='root' --password='#{node["db"]["root_password"]}' --execute="grant all on #{app}.* to #{node["db"]["user"]}@'%' identified by '#{node["db"]["password"]}';"
    EOH
    not_if "mysql --user='root' --password='#{node["db"]["root_password"]}' --execute='show databases;' | grep pppp#{app}"
  end
end
