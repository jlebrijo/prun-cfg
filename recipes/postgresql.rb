service 'postgresql' do
  action :restart
end
bash "create pg_user" do
  code <<-EOH
  sudo -u postgres psql -c "create role #{node["db"]["user"]} with createdb login password '#{node["db"]["password"]}';"
  EOH
  not_if "sudo -u postgres psql -c \"\\du\" | grep #{node["db"]["user"]}"
end

# Create databases
package "postgresql-contrib"
node["apps"].each do |app|
  bash "create #{app} database" do
    code <<-EOH
    sudo -u postgres psql -c "create database #{app};"
    sudo -u postgres psql -c "grant all privileges on database #{app} to #{node["db"]["user"]};"
    EOH
    not_if "sudo -u postgres psql -c \"\\l\" | grep #{app}"
  end

  node["pg_extensions"].each do |extension|
    bash "create extension #{extension}" do
      code <<-EOH
        sudo -u postgres psql -d #{app} -c 'create extension #{extension};'
      EOH
      not_if "sudo -u postgres psql -d #{app} -c \"\\dx\" | grep #{extension}"
    end
  end
end

service 'postgresql' do
  action :restart
end
