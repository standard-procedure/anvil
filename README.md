# Standard::Procedure::Anvil

Some simple scripts for installing [Dokku](https://dokku.com) applications on Ubuntu servers.

## Installation

```ruby
gem install standard-procedure-anvil
```

## Usage

### To build a new server

Ultimately the plan is to use [Fog](https://github.com/fog/fog) to handle building servers.

But until then, you can prepare your servers using [CloudInit](https://cloudinit.readthedocs.io/en/latest/)

A cloudinit file is a YML file that you load into a virtual machine while it is being created.  As the server boots, uses the cloudinit configuration to install software and set itself up.  With most cloud hosting providers, you will find an option for "user data", or something similar, on the "create a new server" page.

So firstly we ask Anvil which cloudinit configurations it has available:

```sh
anvil cloudinit list
```

This will give us a list of prewritten cloud init scripts - of which dokku is probably the one we're most interested in.

Next we tell anvil to generate our configuration:

```sh
anvil cloudinit generate dokku --user app --public-key ~/.ssh/my_key.pub > ~/Desktop/my_server.yml
```

Anvil generates a dokku configuration (and places it on our desktop) that will create an Ubuntu 22.04 box with docker and dokku preinstalled.  Plus it will create a user called `app` that can log in through SSH using a public key `my_key.pub`.  The server itself is locked down so only ports 80, 443 and 22 are open, only the users `app` and `dokku` are allowed to log in and they must use public/private key encryption - no passwords allowed.

To test this, it's worth taking a look at [Multipass](https://multipass.run) - a tool from Canonical that lets you create virtual machines (using cloud init files) on your local machine - meaning you can try out various configurations without spending money at a hosting company.

Once you've built a preconfigured virtual machine, we can move on to getting our dokku application installed.

### Installing an application onto the server

Move to your application's root folder and create the deploy.yml file (see below).  Then use the `app install` command to set dokku up for your first deployment.

```sh
anvil app install
```

This will SSH into the server (or servers if you have multiple) from your config file and:

- Installs any dokku plugins that you have specified
- Tells dokku to create the app
- Uses your config file to set the environment variables for the app
- Sets some sensible defaults for Nginx and makes sure it proxies correctly to your app
- Optionally forwards the correct SSL/TLS headers if your app is behind a load-balancer
- Finally it runs the post-installation scripts from your config file, which you can use to configure your plugins

Next up we deploy the app.

```sh
anvil app deploy
```
As this is the first deployment, anvil will create git remotes for each host, then do the initial git push.  If you have multiple servers configured, these should run in parallel (coming soon).  Once each deployment has completed, anvil will SSH in, scale your app and run the post-first-deployment scripts.

You can then use the same `anvil app deploy` command to deploy the app again - but as it knows this isn't the first deployment (as it does not need to create the git remotes), it will run your post-deployment scripts (not post-first-deployment) each time.

To change the number of processes (as defined by your Procfile), you can set the `scale` key(s) in your config file and then call:

```sh
anvil app scale
```

(COMING SOON)
Finally, if you need to change the values of any environment variables, update your config file and use:

```sh
anvil app configure
```

### Configuration Files

An Anvil configuration file specifies the configuration for multiple servers and multiple apps.  Each server is configured, then each app is installed onto each server.

For now take a look at the two samples in the spec folder - [multi-server](/spec/fixtures/multi-server.config.yml) and [single-server](/spec/fixtures/single-server.config.yml).

### Secrets

Finally, you'll probably want to check your deploy.yml file into source control.  But you _definitely_ don't want to be storing important secrets - database passwords, encryption keys and so on - where everyone can see them.

So the `anvil app` commands also allow you to specify secrets, either from another file, or via the command line.

The secrets are just extra environment variables that are added to the ones defined in your config file - in the format:

```
SECRET1=VALUE1 SECRET2=VALUE2
```

You can either specify `--secrets my-secrets-file.env` to load these from a separate file.  Or you can load them from stdin.

For example, I use [Bitwarden](https://bitwarden.com) as my password locker and use the Bitwarden CLI to access my secrets.  The CLI is installed through homebrew, I then authenticate and can use a command like:

```sh
bw get notes secrets@myapp.com | anvil app install deploy.myapp.yml -S
```
I have the environment variables for myapp.com stored in Bitwarden as a secure note with the title "secrets@myapp.com".  So `bw get notes secrets@myapp.com` loads them from my vault and pipes them to the `anvil app install` command.  The anvil command is using the `-S` (or `--secrets-stdin`) option which means it will read the information piped in by bitwarden.  So, once decrypted, the confidential data never touches a disk until it gets written into the dokku app configuration on the server.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/standard-procedure-anvil.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
