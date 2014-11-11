# PRUN-cfg

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