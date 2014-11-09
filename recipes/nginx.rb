domain_name = Chef::Config[:node_name]

template "/etc/nginx/conf.d/nginx.conf" do
  source "nginx.conf.erb"
  variables domain: domain_name
end

node["apps"].each_with_index do |app, i|

  template "/etc/nginx/conf.d/#{app}.conf" do
    source "nginx-app.conf.erb"
    variables app: app, port: 3000 + i, domain: domain_name
  end

  if node["ssl_apps"].include? app
    directory "/etc/nginx/ssl/"
    cookbook_file "/etc/nginx/ssl/#{app}.#{domain_name}.crt"
    cookbook_file "/etc/nginx/ssl/#{app}.#{domain_name}.key"
  end
end

service 'nginx' do
  action :restart
end