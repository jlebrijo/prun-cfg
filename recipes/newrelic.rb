bash "install New Relic Sysmond" do
  code <<-EOH
  echo deb http://apt.newrelic.com/debian/ newrelic non-free > /etc/apt/sources.list.d/newrelic.list
  wget -O- https://download.newrelic.com/548C16BF.gpg | apt-key add -
  apt-get update
  apt-get install newrelic-sysmond
  nrsysmond-config --set license_key=#{node["newrelic_key"]}
  EOH
  not_if "ls /etc/newrelic | grep nrsysmond.cfg"
end

service 'newrelic-sysmond' do
  action :restart
end

bash "install Pip" do
  code <<-EOH
  curl --silent --show-error --retry 5 https://bootstrap.pypa.io/get-pip.py | sudo python2.7
  EOH
  not_if "which pip"
end

package "python-dev"
directory "/var/log/newrelic"
directory "/var/run/newrelic"
directory "/etc/newrelic"
bash "install MeetMe/newrelic-plugin-agent" do
  code <<-EOH
  pip install newrelic-plugin-agent

  mv /opt/newrelic-plugin-agent/newrelic-plugin-agent.deb /etc/init.d/newrelic-plugin-agent
  chmod +x /etc/init.d/newrelic-plugin-agent
  update-rc.d newrelic-plugin-agent defaults

  pip install newrelic-plugin-agent[postgresql]
  sudo -u postgres psql -c "alter user #{node["db"]["user"]} with superuser"
  EOH
  not_if "which newrelic-plugin-agent"
end

template "/etc/newrelic/newrelic-plugin-agent.cfg" do
  source "newrelic/newrelic-plugin-agent.cfg.erb"
end

service 'newrelic-plugin-agent' do
  action :restart
end

# NewRelic for blog
if node[:blog_dns_name]
  package "php5-dev"
  bash "Install newrelic-php5" do
    code <<-EOH
      echo newrelic-php5 newrelic-php5/application-name string "#{node[:mysql][:db_name]}-#{node[:rails_env]}" | debconf-set-selections
      echo newrelic-php5 newrelic-php5/license-key string "#{node["newrelic_key"]}" | debconf-set-selections
      apt-get -y install newrelic-php5
      cp /etc/newrelic/newrelic.cfg.template /etc/newrelic/newrelic.cfg
      service newrelic-daemon restart
      service php5-fpm restart
      service nginx restart
    EOH
    not_if "dpkg-query -W 'newrelic-php5'"
  end
  template "/etc/supervisor/conf.d/newrelic-daemon.conf" do
    source "supervisord.conf.erb"
    variables app: "newrelic-daemon"
  end
end

# Create supervisord file
%w(newrelic-plugin-agent newrelic-sysmond).each do |app|
  template "/etc/supervisor/conf.d/#{app}.conf" do
    source "supervisord.conf.erb"
    variables app: app
  end
end