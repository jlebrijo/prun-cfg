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
    sudo apt-get install -y git build-essential libsqlite3-dev libssl-dev gawk
    sudo apt-get install -y libreadline6-dev libyaml-dev sqlite3 autoconf libgdbm-dev
    sudo apt-get install -y libncurses5-dev automake libtool bison pkg-config libffi-dev

    git clone https://github.com/sstephenson/ruby-build.git ~/ruby-build
    ~/ruby-build/install.sh

    export RUBY_VERSION=#{node['ruby_version']}
    ruby-build --verbose $RUBY_VERSION /usr/local/ruby/$RUBY_VERSION

    rm /usr/bin/ruby
    #ln -s /usr/local/ruby/$RUBY_VERSION/bin/ruby /usr/bin/ruby
    echo "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/ruby/#{node['ruby_version']}/bin" | sudo tee -a /etc/environment
    echo "export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/ruby/#{node['ruby_version']}/bin" >> ~/.profile
    source /etc/environment

    # Install prerequisites
    echo gem: --no-ri --no-rdoc > /root/.gemrc
    gem install bundler
    gem install rack -v 1.6.0
    gem install thin -v 1.6.3
    thin install
    /usr/sbin/update-rc.d -f thin defaults
  EOH
  not_if "ls /usr/local/bin | grep thin"
end
