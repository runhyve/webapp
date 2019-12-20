# Webapp

This repository contains web application to manage Runhyve hypervisors. It's written in Elixir with Phoenix and uses PosgreSQL to keep the state.
HTTP API is used to communicate with hypervisors. 

![Machines Screenshot](https://gitlab.com/runhyve/webapp/raw/master/assets/static/images/screenshot-machines.png)
Virtual machines view

### Community

Meet us on #runhyve @ freenode.

### Development

##### Using Docker
1. Run `docker-compose up -d` to start containers
2. Setup the database: `docker-compose run webapp mix ecto.setup`
3. Visit http://localhost:4000 to see the webapp running.

You can also run `docker-compose logs -f webapp` to see server logs.<br>
To open Interactive Elixir Shell run `docker-compose run webapp iex -S mix`<br>
To open PostgreSQL interactive terminal run `docker-compose exec -u postgres  postgres psql -U postgres webapp_dev`


### Using local environment

##### Dependencies

- Elixir 1.5 or later
- PostgreSQL
- Node.js

1. Install dependencies with `mix deps.get`
2. Setup database with `mix ecto.setup`
3. Install Node.js dependencies with `cd assets && npm install && cd ..`
4. Start Phoenix server `mix phx.server`

### Basic operations

##### Default credentials

Default credentials are imported from `priv/repo/seeds.exs` file during setup of database (`mix ecto.setup`).

##### Setting up the hypervisor

Setting up the hypervisor is fully automated. [chef-hypervisor](https://gitlab.com/runhyve/chef-hypervisor) repository
contains all you need to proceed. It's basically a Chef cookbook so you can re-use it with Chef server if needed.

First, clone the repository on on your hypervisor:

```
git clone https://gitlab.com/runhyve/chef-hypervisor
```

Then, inside the `chef-hypervisor` directory issue `./install.sh` command as a superuser:
```sudo ./install.sh```

**Note**: at this moment only clean installations of FreeBSD 12.0 are supported.

##### Connecting the hypervisor to webapp

At this point you should have both hypervisor and webapp up and running. To connect the hypervisor with webapp browse to
[Admin->Hypervisors](http://localhost:4000/admin/hypervisors) page and click [New hypervisor](http://localhost:4000/admin/hypervisors/new).
You need a FQDN to connect to the hypervisor. If you're hypervisor is in internal network or don't want to mess with DNS then you can use [xip.io](http://xip.io/).

**Example:**
If your hypervisor has ip **192.168.0.11** then use **192.168.0.11.xip.io** as a FQDN.

TLS certificate isn't generated during the setup so you need to either do it manually or uncheck the _Enable tls_ checkbox if developing in trusted network.

Token is a random string generated during setup of the hypervisor. It's saved in `/usr/local/etc/nginx/.runhyvetoken` file on the hypervisor and it's used to authorize connections from the webapp:
```
$ sudo cat /usr/local/etc/nginx/.runhyvetoken
c81f578d-c558-4623-a2d4-10ada9dcb431
```
After succesfuly connecting to hypervisor you should be able to see its details:

![Hypervisor Screenshot](https://gitlab.com/runhyve/webapp/raw/master/assets/static/images/screenshot-hypervisor.png)
Hypervisor view

##### Downloading images to hypervisors

We included few popular Distributions in development database. At this moment they are not
downloaded automatically on hypervisors so you need to do it manually.
For each image in `priv/repo/seeds.exs` you need issue this command on the hypervisor:
```
vm img <image url>
``` 

After importing images you can list them:
```
vm img
DATASTORE           FILENAME
default             Fedora-Cloud-Base-29-1.2.x86_64.raw
default             FreeBSD-12.0-RELEASE-amd64.raw
default             bionic-server-cloudimg-amd64.img
default             debian-9-openstack-amd64.qcow2
default             ubuntu-18.04-server-cloudimg-amd64.img
```

##### Networking

By default Webapp has configured a network named `public`. It's a bridged network so it'll give you access to your internal network by default.
It's not being created on the hyperisor by default. To setup it please run:

```
vm switch add public
vm switch add public igb0
``` 
Where igb0 is name of the main interface.

## Learn more

  * Phoenix website: http://www.phoenixframework.org/
  * Phoenix Docs: https://hexdocs.pm/phoenix
  * FreeBSD website: https://freebsd.org