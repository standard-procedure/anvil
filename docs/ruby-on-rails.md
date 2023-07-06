# Dokku and Ruby on Rails

(incomplete - coming soon)

- If using the Mysql plugin, use the Mysql2 protocol
- store your RAILS_MASTER_KEY and SECRET_KEY_BASE outside of your configuration file (see [secrets](/docs/secrets.md))
- in your config/environments/production.rb or config/environments/staging.rb set `config.force_ssl = false` - dokku's nginx configuration will do the redirect for you if you're using the Let's Encrypt plugin, or you can set the redirect on your load-balancer.  Setting `config.force_ssl = true` causes issues with the health checks
- Make sure your app knows its hostname; set it as an environment variable in your configuration file and then use that hostname in your environment file as follows: `config.action_mailer.default_url_options = {host: ENV["HOSTNAME"]}` and `Rails.application.routes.default_url_options[:host] = config.action_mailer.default_url_options[:host]`.  This means that when you need to generate a full URL (as opposed to a relative path), Rails knows what to use.
- Use a CHECKS file that looks like this (again using that HOSTNAME environment variable), so dokku's zero-deployment checks can connect correctly.  My `/health_check` route just returns a `200 OK` in most apps, but in some it actually checks the database connection, as well as some other services (although this causes problems with the initial deployment, which is why checks are switched off the first time through)
```
WAIT=10
ATTEMPTS=5
http://{{ var "HOSTNAME" }}/health_check
```

A typical Rails deploy.yml for a single-server, totally self-contained app, looks like this:

```yaml
version: 0.1
hosts:
  - myapp.example.com:
      user: app
app:
  domain: myapp.example.com
  port: 3000
  environment:
    - BUNDLE_WITHOUT=test:development
    - CABLE_CHANNEL_PREFIX=myapp
    - EMAIL_DOMAIN=mail.myapp.example.com
    - EMAIL_HOST=smtp.myapp.example.com
    - EMAIL_PORT=587
    - EMAIL_USER=postmaster@mail.myapp.example.com
    - HOSTNAME=myapp.example.com
    - NODE_ENV=production
    - RACK_ENV=production
    - RAILS_ENV=production
    - RAILS_LOG_TO_STDOUT=true
    - RAILS_MAX_THREADS=10
    - RAILS_SERVE_STATIC_FILES=true
  resource_limit: 2048m
  scale: web=2 worker=1
  load_balancer: false
  nginx:
    client_max_body_size: 512m
    proxy_read_timeout: 60s
  plugins:
    - cron-restart
    - maintenance
    - redis
    - memcached
    - mysql
    - letsencrypt
  scripts:
    after_install:
      - dokku cron-restart:set app schedule '0 3 * * *'
      - dokku memcached:create memcached
      - dokku memcached:link memcached app
      - dokku redis:create redis_db
      - dokku redis:link redis_db app
      - dokku mysql:create mysql_db
      - dokku config:set app MYSQL_DATABASE_SCHEME=mysql2
      - dokku mysql:link mysql_db app
    after_first_deploy:
      - dokku letsencrypt:set app email me@myapp.example.com
      - dokku letsencrypt:enable app
      - dokku letsencrypt:cron-job --add
      - dokku run app bin/rails db:seed

```
