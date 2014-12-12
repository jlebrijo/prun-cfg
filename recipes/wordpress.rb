
bash "Install Mysql Server" do
  code <<-EOH
    debconf-set-selections <<< 'mysql-server mysql-server/root_password password #{node[:mysql][:root_password]}'
    debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password #{node[:mysql][:root_password]}'
    apt-get -y install mysql-server
    service mysql start
  EOH
  not_if "dpkg-query -W 'mysql-server'"
end

bash "Create Database and user" do
  code <<-EOH
    touch ~/.my.cnf
    echo "[client]" >> ~/.my.cnf
    echo "user = root" >> ~/.my.cnf
    echo "password = #{node[:mysql][:root_password]}" >> ~/.my.cnf

    mysql -e 'create database #{node[:mysql][:db_name]};'
    mysql -e "grant all on #{node[:mysql][:db_user]}.* to '#{node[:mysql][:db_name]}'@'localhost' identified by '#{node[:mysql][:db_password]}';"
  EOH
  not_if "mysql -e 'SELECT User FROM mysql.user;' | grep #{node[:mysql][:db_user]}"
end

# Install PHP-pfm
%w(php5-fpm php5-mysql).each {|p| package p}
service "php5-fpm" do
  action :restart
end

# Install Wordpress
directory "/var/www"
bash "Install Wordpress" do
  code <<-EOH
    wget https://wordpress.org/latest.tar.gz
    tar -zxvf latest.tar.gz
    mv wordpress /var/www/blog
    chown www-data:www-data -R /var/www/blog/
  EOH
  not_if "ls /var/www  | grep blog"
end

template "/var/www/blog/wp-config.php" do
  source "wordpress/wp-config.php.erb"
  not_if "ls /var/www  | grep blog"
end

# Configure NGINX
template "/etc/nginx/conf.d/blog.conf" do
  source "wordpress/nginx.conf.erb"
end

service "nginx" do
  action :restart
end

# Create supervisord file
%w(mysql php5-fpm).each do |app|
  template "/etc/supervisor/conf.d/#{app}.conf" do
    source "supervisord.conf.erb"
    variables app: app
  end
end

# Restore/backup Blog scripts
if node[:backup] then
  template "/root/restore_blog.sh" do
    source "wordpress/restore_blog.sh.erb"
    mode "0700"
  end
  template "/root/backup_blog.sh" do
    source "wordpress/backup_blog.sh.erb"
    mode "0700"
  end
end