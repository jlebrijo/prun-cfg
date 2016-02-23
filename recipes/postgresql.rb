package 'postgresql'
# POSTGRESQL prepared for localhost connections
bash "Installing PostgreSQL" do
  code <<-EOH
    export LANGUAGE=en_US.UTF-8
    apt-get -y install postgresql libpq-dev

    sed -i "s/#listen_addresses = 'localhost'/listen_addresses = 'localhost'/" /etc/postgresql/9.3/main/postgresql.conf
    sed -i "s/local   all             all                                     peer/local   all             all                                     md5/" /etc/postgresql/9.3/main/pg_hba.conf
    sed -i "s/ssl = true/ssl = false/" /etc/postgresql/9.3/main/postgresql.conf
  EOH
  not_if "which psql"
end

service 'postgresql' do
  action :restart
end
bash "create pg_user" do
  code <<-EOH
  sudo -u postgres psql -c "create role #{node["db"]["user"]} with createdb login password '#{node["db"]["password"]}';"
  EOH
  not_if "sudo -u postgres PGPASSWORD=#{node["db"]["password"]} psql -U #{node["db"]["user"]} -c \"\\du\" | grep #{node["db"]["user"]}"
end

# Create databases
package "postgresql-contrib"
node["apps"].each do |app|
  bash "create #{app} database" do
    code <<-EOH
    sudo -u postgres psql -c "create database #{app};"
    sudo -u postgres psql -c "grant all privileges on database #{app} to #{node["db"]["user"]};"
    EOH
    not_if "sudo -u postgres PGPASSWORD=#{node["db"]["password"]} psql -U #{node["db"]["user"]} -c \"\\l\" | grep #{app}"
  end

  node["pg_extensions"].each do |extension|
    bash "create extension #{extension}" do
      code <<-EOH
        sudo -u postgres psql -d #{app} -c 'create extension #{extension};'
      EOH
      not_if "sudo -u postgres PGPASSWORD=#{node["db"]["password"]} psql -U #{node["db"]["user"]} -d #{app} -c \"\\dx\" | grep #{extension}"
    end
  end if node["pg_extensions"]
end

service 'postgresql' do
  action :restart
end

package ['python-pip', 'libpq-dev', 'python-dev']
bash "install pgcli" do
  code <<-EOH
    pip install pgcli
  EOH
  not_if "which pgcli"
end
