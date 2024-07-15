## [Unreleased]

## [0.1.0] - 2023-06-19

- Initial release

## [0.2.0] - 2023-07-05

- It works for me
Successfully deployed a number of apps into production using this

## [0.2.1] - 2023-07-06

- Corrected dokku proxy SSL settings
- Tidy up of various bits of code and configuration

## [0.2.2] - 2023-08-14

- Updated the redis cloudinit file to use the latest version from Redis, instead of the older one that is included with Ubuntu.

## [0.2.3] - 2024-01-17

- Updaetd the dokku cloudinit file to install dokku and docker from the official repositories
- Added support for %{HOSTNAME} in cloudinit files
- Improved reliability when reading configuration files

## [0.2.4] - 2024-07-15

- Set the RAM resource limit when installing an app
