home = node[:system][:user]? "/home/#{node[:system][:user]}":'/root'
# Add Deployer keys
cookbook_file "id_rsa" do
  path "#{home}/.ssh/id_rsa"
  mode 0600
  user "#{node.system_user}"
  group "#{node.system_group}"
end
cookbook_file "id_rsa.pub" do
  path "#{home}/.ssh/id_rsa.pub"
  mode 0644
  user "#{node.system_user}"
  group "#{node.system_group}"
end

# Identify Git pushers for backups or releases
execute "git config --global user.email '#{node["git_config"]["email"]}'"
execute "git config --global user.name '#{node["git_config"]["name"]}'"
execute "git config --global push.default simple"

# Add Authorized keys
cookbook_file "authorized_keys" do
  path "#{home}/.ssh/authorized_keys"
  mode 0644
  user "#{node.system_user}"
  group "#{node.system_group}"
end

# Add known hosts
ssh_known_hosts_entry 'github.com'
ssh_known_hosts_entry 'bitbucket.org'

