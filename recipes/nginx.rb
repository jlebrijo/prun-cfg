# Reset nginx configuration
directory "/etc/nginx/conf.d" do
  recursive true
  action :delete
end
directory "/etc/nginx/conf.d"

# example.com --> www.example.com always
template "/etc/nginx/conf.d/root_to_www.conf" do
  source "nginx/root_to_www.conf.erb"
end

# Configuring Rails Apps as Virtual hosts
node["apps"].each_with_index do |app, i|

  template "/etc/nginx/sites-available/vhost_#{app}.conf" do
    source "nginx/app.conf.erb"
    variables app: app, port: 3000 + i
  end
  link "/etc/nginx/sites-enabled/vhost_#{app}.conf" do
    to "/etc/nginx/sites-available/vhost_#{app}.conf"
  end

  if node["ssl_apps"] && node["ssl_apps"].include?(app)
    directory "/etc/nginx/ssl/"
    cookbook_file "/etc/nginx/ssl/#{node.domain_root_name}.crt"
    cookbook_file "/etc/nginx/ssl/#{node.domain_root_name}.key"
  end
end

cookbook_file "/etc/nginx/ssl/dh2048.pem"
cookbook_file '/etc/nginx/conf.d/gzip.conf' do
  source 'nginx/gzip.conf'
end
service "nginx" do
  action :restart
end