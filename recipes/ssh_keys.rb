home = node[:system][:user]? "/home/#{node[:system][:user]}":'/root'
manage_ssh_keys home, node.system_user

# Identify Git pushers for backups or releases
execute "git config --global user.email '#{node["git_config"]["email"]}'"
execute "git config --global user.name '#{node["git_config"]["name"]}'"
execute "git config --global push.default simple"

# Add known hosts
ssh_known_hosts_entry 'github.com'
ssh_known_hosts_entry 'bitbucket.org'

