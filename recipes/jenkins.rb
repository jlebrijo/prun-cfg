%w(libcurl4-openssl-dev libmagickwand-dev).each {|p| package p}

## Jenkins ownership
execute "chown -R jenkins:jenkins /var/lib/jenkins"
execute "chown -R jenkins:jenkins /usr/local/rvm"

# Add known hosts
ssh_known_hosts_entry 'github.com'
ssh_known_hosts_entry 'bitbucket.org'

# Identify Git pushers for backups or releases
bash "git config --global" do
  cwd "/var/lib/jenkins/"
  user "jenkins"
  environment ({'HOME' => '/var/lib/jenkins/', 'USER' => 'jenkins'})
  code <<-EOH
    git config --global user.email "#{node["git_config"]["email"]}"
    git config --global user.name "#{node["git_config"]["name"]}"
    git config --global push.default simple
  EOH
end

# Ruby
node['rubies'].each do |ruby|
  execute "Install #{ruby}" do
    command "su jenkins -l -c 'rvm install #{ruby} --verify-downloads 1'"
    not_if "su jenkins -l -c 'rvm install list | grep #{ruby}'"
  end
end

## Configuration
directory "/var/lib/jenkins/jobs/shared"
cookbook_file "application.yml" do
  path "/var/lib/jenkins/jobs/shared/application.yml"
end

## Database
template "/var/lib/jenkins/jobs/shared/database.yml" do
  variables db_name: node["db"]["name"]
end

bash "create #{node["db"]["user"]} user" do
  code <<-EOH
  sudo -u postgres psql -c "create role #{node["db"]["user"]} with createdb login password '#{node["db"]["password"]}';"
  EOH
  not_if "sudo -u postgres psql -c \"\\du\" | grep #{node["db"]["user"]}"
end

bash "create #{node["db"]["name"]} database" do
  code <<-EOH
    sudo -u postgres psql -c "create database #{node["db"]["name"]};"
    sudo -u postgres psql -c "alter database #{node["db"]["name"]} owner to #{node["db"]["user"]};"
  EOH
  not_if "sudo -u postgres psql -c \"\\l\" | grep #{node["db"]["name"]}"
end

## Nginx
template "/etc/nginx/conf.d/jenkins.conf" do
  source "nginx/jenkins.conf.erb"
end
service "nginx" do
  action :restart
end

service "jenkins" do
  action :restart
end
