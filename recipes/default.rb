execute "apt-get update" do
  command "apt-get update"
end

include_recipe "prun-cfg::ssh_keys"
include_recipe "prun-cfg::rails_server"
include_recipe "prun-cfg::nginx"

