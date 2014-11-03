template "/etc/nginx/conf.d/nginx.conf" do
  source "nginx.conf.erb"
  variables domain: Chef::Config[:node_name]
end
node["apps"].each_with_index do |app, i|
  template "/etc/nginx/conf.d/#{app}.conf" do
    source "nginx-app.conf.erb"
    variables app: app, port: 3000 + i, domain: Chef::Config[:node_name]
  end
end

service 'nginx' do
  action :restart
end