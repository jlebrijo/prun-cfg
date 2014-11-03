# Add Deployer keys
cookbook_file "id_rsa" do
  path "/root/.ssh/id_rsa"
  mode 0600
  action :create_if_missing
end
cookbook_file "id_rsa.pub" do
  path "/root/.ssh/id_rsa.pub"
  mode 0644
  action :create_if_missing
end

# Add known hosts
ssh_known_hosts_entry 'github.com'
ssh_known_hosts_entry 'bitbucket.org'

# Add Authorized keys
cookbook_file "authorized_keys" do
  path "/root/.ssh/authorized_keys"
  mode 0644
end