execute "apt-get update"
# Supervisor (not needed really: come from container reqs)
package 'supervisor'

# Nginx
package 'nginx'
link "/etc/nginx/sites-enabled/default" do
  action :delete
end

# Install ruby
bash "Installing Ruby #{node['ruby_version']}" do
  code <<-EOH
    # Pre-requirements
    sudo apt-get install -y git build-essential libsqlite3-dev libssl-dev gawk g++
    sudo apt-get install -y libreadline6-dev libyaml-dev sqlite3 autoconf libgdbm-dev
    sudo apt-get install -y libncurses5-dev automake libtool bison pkg-config libffi-dev

    # Ruby
    sudo apt-get -y install software-properties-common
    sudo apt-add-repository -y ppa:brightbox/ruby-ng
    sudo apt-get update
    sudo apt-get -y install ruby#{node['ruby_version']} ruby#{node['ruby_version']}-dev

    # Install prerequisites
    echo gem: --no-ri --no-rdoc | sudo tee -a /root/.gemrc
    sudo gem install bundler
    sudo gem install rack -v 1.6.0
    sudo gem install thin -v 1.6.3
    sudo thin install
    sudo /usr/sbin/update-rc.d -f thin defaults
  EOH
  not_if "which ruby"
end
