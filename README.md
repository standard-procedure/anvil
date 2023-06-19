# Standard::Procedure::Anvil

Some simple scripts for installing [Dokku](https://dokku.com) applications on Ubuntu servers.

## Installation

```ruby
gem install standard-procedure-anvil
```

## Usage

### To build a new server

Coming soon (plan is to use [Fog](https://github.com/fog/fog) to handle building servers)

### To install an application onto a blank server

Move to your application's root folder and create the anvil.yml file (see below).

Then run `anvil user@host --use-sudo --identity=~/.ssh/my_key`.

This will SSH into each server and:

- Set the server hostname and timezone
- Install various necessary packages, plus dokku itself
- Set up the firewall
- Create unix users for each app, adding them to the sudo and docker groups, and setting their authorized_keys files with the given public key
- Disallow root and passwordless logins over SSH
- Schedule a `docker system prune` once per week to clean up any dangling images or containers
- Configure nginx
- Install dokku plugins and run any configuration you have defined
- Sets the deployment branch to `main`

For each app it will then:

- Create the dokku app
- Set the environment variables to those defined in your configuration and secrets files
- Set the app's domain and set up a proxy from nginx to the app's port
- Sets resource limits for the app
- Disables checks for workers

Then a git remote for each app is created on your local machine and then pushed.  This performs the initial dokku deployment. Once complete:

- The app is scaled to the correct number of workers
- Plugins are configured for the app

### Configuration Files

An Anvil configuration file specifies the configuration for multiple servers and multiple apps.  Each server is configured, then each app is installed onto each server.

So you could have one app on two servers (and, we assume, a load-balancer set up in front of them).  Or two apps on one server.  Or even two apps on two servers (again, using a load-balancer)


```yml
version: 0.1
servers:
  hosts:
    - server1.example.com
  user: user
  public_key: /home/local-user/.ssh/my-key.pub
  timezone: Europe/London
  ports:
    - 22/tcp
    - 80/tcp
    - 443/tcp
  nginx:
    forward_proxy_headers: false
    client_max_body_size: 512m
    proxy_read_timeout: 60s
  plugins:
    cron-restart:
      url: https://github.com/dokku/dokku-cron-restart.git
    maintenance:
      url: https://github.com/dokku/dokku-maintenance.git
    redis:
      url: https://github.com/dokku/dokku-redis.git
    memcached:
      url: https://github.com/dokku/dokku-memcached.git
    letsencrypt:
      url: https://github.com/dokku/dokku-letsencrypt.git
      config:
        - set --global email ssl-admin@mycompany.com
        - cronjob --add
apps:
  first_app:
    hostname: first_app.example.com
    port: 3000
    environment:
      - ENV_VAR=value
      - ENV_VAR2=value2
      - RAILS_ENV=production
    secrets: secrets.yml
    resource_limit: 2048m
    scale: web=2 worker=1
    plugins:
        cron-restart:
          - set first_app schedule '0 3 * * *'
        redis:
          - create first_app_redis_db
          - link first_app_redis_db first_app
        memcached:
          - create first_app_memcached
          - link first_app_memcached first_app
        letsencrypt:
          - set first_app email ssl-admin@mycompany.com
          - enable first_app
  second_app:
    hostname: second_app.example.com
    port: 3000
    environment:
      - ENV_VAR=value
      - ENV_VAR2=value2
      - RAILS_ENV=production
    secrets: secrets.yml
    resource_limit: 2048m
    scale: web=2 worker=1
    plugins:
        cron-restart:
          - set second_app schedule '0 3 * * *'
        letsencrypt:
          - set second_app email ssl-admin@mycompany.com
          - enable second_app

```
`secrets.yml` is an optional additional file containing environment variables that you do not want to check into your source code repository.  It is a simple KEY=VALUE format:

```
DB_PASSWORD=letmein
ENCRYPTION_KEY=secretstuff
```


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/standard-procedure-anvil.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
