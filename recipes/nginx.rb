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

  template "/etc/nginx/conf.d/vhost_#{app}.conf" do
    source "nginx/app.conf.erb"
    variables app: app, port: 3000 + i, domain: node["domain_name"]
  end

  if node["ssl_apps"].include? app
    directory "/etc/nginx/ssl/"
    cookbook_file "/etc/nginx/ssl/#{app}.#{node["domain_name"]}.crt"
    cookbook_file "/etc/nginx/ssl/#{app}.#{node["domain_name"]}.key"
  end
end

service "nginx" do
  action :restart
end