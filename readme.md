# Vagrant

My Vagrantfile for development bliss.

- Ubuntu 13.10
- PHP 5.5
- Nginx
- MySQL
- Postgres
- Node (With Grunt & Gulp)
- Redis
- Memcached
- Beanstalkd

Setup for easily hosting multiple projects on various Nginx sites.

## Setup

1. Install VirtualBox & Vagrant
2. `vagrant box add chef/ubuntu-13.10`
3. Clone this repository into a directory.
4. Configure SSH key, shared folders, and Nginx sites in `Vagrant.yaml`.
6. Run `vagrant up` from that directory.

## Notes

MySQL / Postgres user is `vagrant` and password is `secret`.
