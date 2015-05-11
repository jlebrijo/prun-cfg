execute "apt-get update"
# Supervisor (not needed really: come from container reqs)
package 'supervisor'

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

# Nginx
package 'nginx'
link "/etc/nginx/sites-enabled/default" do
  action :delete
end

# Install ruby
bash "Installing Ruby #{node['ruby_version']}" do
  code <<-EOH
    apt-get install -y git build-essential libsqlite3-dev libssl-dev gawk
    apt-get install -y libreadline6-dev libyaml-dev sqlite3 autoconf libgdbm-dev
    apt-get install -y libncurses5-dev automake libtool bison pkg-config libffi-dev

    rm /usr/bin/ruby

    git clone https://github.com/sstephenson/ruby-build.git /root/ruby-build
    /root/ruby-build/install.sh

    export RUBY_VERSION=#{node['ruby_version']}
    ruby-build --verbose $RUBY_VERSION /usr/local/ruby/$RUBY_VERSION
    export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/ruby/$RUBY_VERSION/bin
    echo PATH=$PATH > /etc/environment

    # Install prerequisites
    echo gem: --no-ri --no-rdoc > /root/.gemrc
    gem install bundler
    gem install rack -v 1.6.0
    gem install thin -v 1.6.3
    thin install
    /usr/sbin/update-rc.d -f thin defaults
  EOH
  not_if "ls /usr/local/ruby/#{node['ruby_version']}/bin | grep thin"
end
