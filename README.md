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
  * "host": host name
* "pg_extensions": Postgresql extensions to be configured
* "git_config":
  * "name": Git identification for server
  * "email": Git email identification for server
* "ngx_leaky_bucket_vhosts":
  * Security limitation to avoid DoS attacks, based on
  [Leaky Bucket](https://en.wikipedia.org/wiki/Leaky_bucket) and
  [Nginx module](http://nginx.org/en/docs/http/ngx_http_limit_req_module.html)
  * if the requests rate exceeds the "rate" configured for a zone ("app" named, like the "apps" 
    attribute above), their processing is delayed until their number exceeds the maximum "burst"
    size in which case the request is terminated with an error 503 (Service Temporarily Unavailable).

```json
  "default_attributes": {
    "apps": ["www", "app", "labs"],
    "ssl_apps": ["app"],
    "domain_name": "lebrijo.com",
    "common_repo": "git@bitbucket.org:lebrijo/common.git",
    "db": {
      "user": "db_user",
      "password": "Rxxxxxx9",
      "host": "db.lebrijo.com"
    },
    "pg_extensions": ["unaccent", "hstore"],
    "packages": ["imagemagick", "libmagickwand-dev", "libcurl4-openssl-dev"]
    // Name email to identify backup commits for example
    "git_config": {
      "name": "Jenkins",
      "email": "jenkins@comapny.org"
    },
    "ngx_leaky_bucket_vhosts": {
      "app": {
        "mem": '3m',
        "rate": '1r/s',
        "burst": '1',
        "nodelay": "true"
      }
    }
  }
```

Files you need at 'site-cookboks/prun-cfg/files/default':

* 'application.yml': Common parameters based on Figaro gem file.
* 'authorized_keys': list of public keys with access to server.
* 'id_rsa' and 'id_rsa.pub': identity ssh keys for the server.
* '<app>.<domain>.crt' and '<app>.<domain>.key' files for SSL applications.
* 'dh2048.pem: Diffie-Hellman file for secure DHE (generate: `openssl dhparam -out dh2048.pem 2048`)

### recipe[prun-cfg::prun_base]: Monitoring

Configures all needed in a PRUN server (Postgres, Ruby and Nginx).

Attributes

* "ruby_version": Ruby version

```json
  "default_attributes": {
    "ruby_version": "2.2.0"
  }
```

### recipe[prun-cfg::newrelic]: Monitoring

Mounts NewRelic plugins to monitor Nginx, System and Database.

Attributes

* "newrelic_key": Account key access

```json
  "default_attributes": {
    "newrelic_key": "249xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx9ab"
  }
```

### recipe[prun-cfg::jenkins]: Jenkins

Configure a Jenkins server for Rails testing and deployment

Attributes

* "rubies": Rubies on RVM to run our applications
* "db": PostgreSQL Database configuration
* "git_config":
  * "name": Git identification for server
  * "email": Git email identification for server
* "packages": list of needed packages

```json
  "default_attributes": {
    "rubies": ["ruby-2.1.2", "ruby-2.1.5"],
    "db": {
      "name": "test_ddbb",
      "user": "user_db",
      "password": "password_db"
    },
    // Name email to identify backup commits for example
    "git_config": {
      "name": "Jenkins",
      "email": "jenkins@comapny.org"
    },
    "packages": ["libcurl4-openssl-dev", "libmagickwand-dev", "build-essential"]
  }
```

### recipe[prun-cfg::wordpress]: Wordpress blog

Configure Mysql//Php5-fpm/Nginx/Wordpress to allocate organization blog

Attributes

* "blog_dns_name": DNS name for the blog
* "mysql": Mysql configuration
  * "root_password": password for root user
  * "db_name": database name
  * "db_user": user name
  * "db_password": pasword for user
* "backup": backup configuration
  * "repo": Repository to store the backups
* "git_config":
  * "name": Git identification for server
  * "email": Git email identification for server

```json
  "default_attributes": {
    "blog_dns_name": "blog.agilar.org",
    "mysql": {
      "root_password": "fexXFAp",
      "db_name": "blog",
      "db_user": "blog",
      "db_password": "IH3Wv"
    },
    "backup": {
      "repo": "git@github.com:company/backup.git"
    }
    // Name email to identify backup commits for example
    "git_config": {
      "name": "Blog",
      "email": "blog@comapny.org"
    }
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

### v0.0.9

* Adding Operations identification in server with two attributes: ops_name and ops_email

### v0.0.10

* Fix error: do not process "ssl_apps" and "pg_extensions" they are not defined

### v0.0.13

* Create Jenkins recipe

### v0.0.16

* Adding "ops_email" and "ops_name" to Jenkins recipe because in some case it will make commits

### v0.1.0

* Adding Wordpress recipe
* Create Supervisor conf for newrelic daemons

### v0.1.1

* If you use 'opoen-dock' you need to add   'hostname:' to container to fix the name and recognise in newrelic.
* Fixed Newrelic Nginx stats
* Some fixes for Blog for several environments
* Change 'ops_name' and 'ops_email' to 'git_config:{name,email}'

### v0.1.3

* Including node["packages"] for Rails server, to install Ubuntu packages
* NewRelic (config/newrelic.yml) is managed for rails apps. So you need to:
    * set :linked_files, %w{... config/newrelic.yml}
    * Remove file from repo and add to .gitignore

### v0.1.7

* Including node["packages"] for Jenkins server, to install Ubuntu packages

### v0.1.8

* Replacing node["rails_env"] to node["environment"], making use of chef environments

### v0.1.15

* Added [prun-cfg::prun_base] recipe

### v0.2.0

* Added recipes: [prun-cfg::mysql], [prun-cfg::postgresql]
* Postgresql is detached from prun_base and rails_server recipes
* You will need to include a database recipe anywhere

### v0.2.2

* Added Nginx Leaky bucket support

### v0.2.11

* Included Diffie-Hellman file for secure DHE. `dh2048.pem` file must be added.