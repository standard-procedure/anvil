# Roadmap

As I mentioned, this is pretty much designed for my own use.

There are a few bits I still need (which will be V1) and then I want to open it up.  But if it gets too generic, you might as well just write a load of shell scripts to manage dokku yourself - it's important to keep it simple.

## To do

- [ ] `app reconfigure`
- [ ] Add `--first`/`--not-first` options to `app deploy` so you can override the first-deployment behaviour (in case you get a failure and need to re-run everything)
- [ ] Instead of relying on the ssh-agent, allow the use of your private key when connecting to servers
- [ ] Parallel execution across multiple hosts
