service 'postgresql' do
  action :restart
end
bash "create pg_user and pg_ddbb" do
  code <<-EOH
  sudo -u postgres psql -c "create role #{node["db"]["user"]} with createdb login password '#{node["db"]["password"]}';"
  sudo -u postgres psql -c "create database #{node["db"]["name"]};"
  sudo -u postgres psql -c "grant all privileges on database #{node["db"]["name"]} to #{node["db"]["user"]};"
  EOH
  not_if "sudo -u postgres psql -c \"\\du\" | grep #{node["db"]["user"]}"
end