execute "apt-get update" do
  command "apt-get update"
end

include_recipe "prun-stack::ssh_keys"
include_recipe "prun-stack::postgresql"
include_recipe "prun-stack::rails_app"
include_recipe "prun-stack::nginx"

