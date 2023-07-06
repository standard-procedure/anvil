# Standard::Procedure::Anvil

Some simple scripts for installing [Dokku](https://dokku.com) applications on Ubuntu servers.

## Why does this exist?

I needed a tool to [simplify the management](/docs/why.md) of my many dokku-deployed Ruby on Rails apps.

## Installation

Anvil requires Ruby 2.7 or newer, as it uses ConcurrentRuby to handle doing more than one thing at once.

```ruby
gem install standard-procedure-anvil
```

## Usage

### Build a server

Ultimately the plan is to use [Fog](https://github.com/fog/fog) to handle building servers.

But until then, you can prepare your servers using [CloudInit](https://cloudinit.readthedocs.io/en/latest/)

[Generating a cloudinit file](/docs/cloudinit.md) with `anvil cloudinit generate`

### Install and deploy

Use the `anvil app install` and `anvil app deploy` commands to [install and deploy](/docs/app.md) your app to your server.

### Manage and reconfigure

Use `anvil app scale` and `anvil app reconfigure` to manage and reconfigure your app.  (Docs coming soon)

### Ruby on Rails

I'm a Rails developer and I built anvil to help me with my Rails apps.  Here are [some things I learnt along the way](/docs/ruby-on-rails.md).

## Contributing

Check out the [Roadmap](/docs/roadmap.md)

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/standard-procedure-anvil.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
