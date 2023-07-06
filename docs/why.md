# Why does this exist?

[Dokku](https://dokku.com) is great at installing and configuring containers on a single host.

But you do need to install dokku, generate your configuration and environment variables, install your plugins and app and then configure all those plugins.

Unfortunately, there's no [single configuration file](https://github.com/dokku/dokku/issues/1558) for dokku.

In addition, dokku is really designed for managing a single server.  But I'm actually using it to manage multiple servers that are hidden behind a load-balancer.

So to manage this, I wanted a single configuration file that I could user for all my dokku information, that could then use that configuration across multiple servers.

Currently it's extremely tailored to my needs - it's built for Ubuntu 22.04, it creates a user called "app" (although you can change that), it names your dokku app "app".

I've also added in cloudinit configs for some of the other servers I have to use.  Of course, these are not related to dokku, but anvil can generate them easily so it's useful to keep them all in one place.

There are several [limitations](/docs/roadmap.md) to how it works - it does what I need but does need expansion.  That will come soon.
