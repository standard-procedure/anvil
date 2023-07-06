# Building a server

## Cloudinit

A [CloudInit](https://cloudinit.readthedocs.io/en/latest/) file is a YML file that you load into a virtual machine while it is being created.  As the server boots, uses the cloudinit configuration to install software and set itself up.  With most cloud hosting providers, you will find an option for "user data", or something similar, on the "create a new server" page.

### Generate a configuration

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

### Testing your configuration

To test this, it's worth taking a look at [Multipass](https://multipass.run) - a tool from Canonical that lets you create virtual machines (using cloud init files) on your local machine.  This means you can try out various configurations without spending money at a hosting company.

One thing to note when using multipass - it requires SSH access for a user called "ubuntu".  So take your generated cloudinit file, locate the SSH configuration section and the "AllowUsers" line - and add the "ubuntu" user to it.  Something like: `  - sed -i '$a AllowUsers %{USER} ubuntu dokku' /etc/ssh/sshd_config`.

Multipass has its own private key generated for the ubuntu user, and uses this to manage the server.  Of course, the multipass VM is only on your machine, plus its private key is hidden away, so it's not a security risk.  But in general `anvil cloudinit generate` disallows all SSH access apart from your named user (using your own key), and the `dokku` user if applicable.

Once you've built a preconfigured virtual machine, we can move on to getting our dokku application installed.  However, note that it can take several minutes for the initialisation process to complete - so don't start your deployment too early, or your server won't be ready and will reboot whilst your setting things up.
