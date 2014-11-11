# PRUN-cfg

Helps to configure PRUN servers (PostgreSQL / Ruby on Rails/ Ubuntu / Nginx).

## Recipes

### recipe[prun-cfg]: Rails stack

Default recipe which configures PRUN stack: Nginx / Postgresql / Rails structure / SSH access keys. 

Attributes:

* "apps": Rails applications
* "ssl_apps": Applications with ssl access (443 port)
* "domain_name": Base domain name
* "common_repo": Common repo for private common code
* "db": hash with database values
  * "user": db use
  * "password": db password
* "pg_extensions": Postgresql extensions to be configured

```json
  "default_attributes": {
    "apps": ["www", "app", "labs"],
    "ssl_apps": ["app"],
    "domain_name": "lebrijo.com",
    "common_repo": "git@bitbucket.org:lebrijo/common.git",
    "db": {
      "user": "db_user",
      "password": "Rxxxxxx9"
    },
    "pg_extensions": ["unaccent", "hstore"]
  }
```

Files you need at 'site-cookboks/prun-cfg/files/default':

* 'application.yml': Common parameters based on Figaro gem file.
* 'authorized_keys': list of public keys with access to server.
* 'id_rsa' and 'id_rsa.pub': identity ssh keys for the server.
* '<app>.<domain>.crt' and '<app>.<domain>.key' files for SSL applications. 

### recipe[prun-cfg::newrelic]: Monitoring

Mounts NewRelic plugins to monitor Nginx, System and Database.

Attributes

* "newrelic_key": Account key access

```json
  "default_attributes": {
    "newrelic_key": "249xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx9ab"
  }
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/prun-cfg/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

[MIT License](http://opensource.org/licenses/MIT). Made by [Lebrijo.com](http://lebrijo.com)

## Release notes

### v0.0.1

* First publication
* Adding SSL configuration for app with node["ssl_apps"] parameter. Certificates should be added to 'site-coockbooks/prun-cfg/files/default' as '<app>.<domain>.crt' and'<app>.<domain>.key'
 
### v0.0.2

* Adding node["domain_name"] parameter because node name could be from other domain.

### v0.0.4

* Configure one database per application defined in node["apps"] 
* Create a /etc/init.d/<app> service file per app to start|stop|restart thin
* Adding node["pg_extensions"] to integrate extensions needed for the system

### v0.0.5

* Adding README.md 
