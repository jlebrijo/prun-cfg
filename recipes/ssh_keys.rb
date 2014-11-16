# Add Deployer keys
cookbook_file "id_rsa" do
  path "/root/.ssh/id_rsa"
  mode 0600
end
cookbook_file "id_rsa.pub" do
  path "/root/.ssh/id_rsa.pub"
  mode 0644
end

# Identify Git pushers for backups or releases
execute "git config --global user.email '#{node["ops_email"]}'"
execute "git config --global user.name '#{node["ops_name"]}'"

# Add Authorized keys
cookbook_file "authorized_keys" do
  path "/root/.ssh/authorized_keys"
  mode 0644
end

# Add known hosts
ssh_known_hosts_entry 'github.com'
ssh_known_hosts_entry 'bitbucket.org'

