# The `app` command

## Installing an application

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

## Deploying an application

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

## Configuration files

The [anvil configuration file](/docs/configuration.md) is the heart of the system.

## Secrets

You don't want to store your secrets (passwords, encryption keys) in your anvil configuration.  Instead anvil can [read your secrets](/docs/secrets.md) from a separate file or from the command line.

