# kong-island
dev-test setup for kong, the cloud-native API gateway.

# Description
This setup helps to develop and test multiple kong plugins. It uses [kong-pongo](https://github.com/Kong/kong-pongo) to run tests against the plugins and [konga](https://github.com/pantsel/konga) for dashboard.

# Features
1. Setup to develop and test multiple kong plugins locally.
2. Public kong plugins can be submoduled and used.
3. Supports running tests on individual plugins using `kong-pongo`
4. Supports running integration tests across multiple plugins, again using `kong-pongo`.
5. Pre-seeded `konga` configuration for local dashboard access.
6. Build deployable custom `kong` image with plugins configured.
7. Easy `make` targets for the functionalities defined.
8. `Dockerfile` can be used to build kong image with custom plugins.

# Directories
The repo has the following important directories:

- [kong-plugins](https://github.com/Abhishekvrshny/kong-island/tree/master/kong-plugins): This is a repository of all kong custom plugins. Some of them can be `submodule`d from other public git repositories.
- [kong-pongo](https://github.com/Kong/kong-pongo): Tooling to run plugin tests with Kong.

# Setup
Clone master branch  with submodules
```sh
git clone --recurse-submodules -j8 https://github.com/Abhishekvrshny/kong-island
cd kong-island
```

To fetch a specific branch
```sh
git clone https://github.com/Abhishekvrshny/kong-island
cd kong-island
git fetch origin <branch>
git submodule init
git submodule update
```

Initialize using make
```sh
make init # This will make pongo executable available in your host's path.
make help # This will print all available make targets.
down                           Brings down kong, cassandra and konga
help                           Shows help.
init                           Initialization: Symblinks kong-pongo's executable to host's path.
lint                           Runs linters for all kong plugins.
test-clean                     Cleans test setup
test-each                      Runs individual tests for each kong plugin.
test-integration               Runs integration tests across all kong plugins.
test                           Runs all tests for all kong plugins.
up                             Brings up kong, cassandra and konga
```

Export `KONG_VERSION` environment variable. The version is mentioned in `Makefile`
```
export KONG_VERSION=<version>
```

To change `KONG_VERSION`
1. Change `KONG_VERSION` in `Makefile`
2. Export the updated `KONG_VERSION` environment variable.
3. Update the kong image version in Dockerfile i.e `FROM kong:2.0.x`
 
Bring up kong, cassandra and konga
```sh
make up
# Access kong at http://127.0.0.1:8000/
# Access kong admin API at http://127.0.0.1:8001/
# Access konga at http://127.0.0.1:1337/ 
# Default user credentials for konga: root/root123
```

Bring down kong, cassandra and konga
```sh
make down
```

# Plugin development

All plugins are available under [kong-plugins dir](https://github.com/Abhishekvrshny/kong-island/tree/master/kong-plugins).

## Including an open-source plugin
Add the open-source plugin as a submodule in `kong-island`
```sh
git submodule add http://github.com/Kong/kong-plugin
```

## Interacting with a plugin
You can cd to any of them and make use of pongo executable to interact with the plugin project and environment e.g. getting into a kong container shell, running linters and tests etc. Refer kong-pongo's [readme](https://github.com/Kong/kong-pongo/blob/master/README.md) for various project and environment actions.

After cd-ing to plugin project dir do ensure required components are up
```sh
pongo up
```

And now can get into kong's container shell
```sh
pongo shell
```

From within kong's container shell
```sh
# To see all environment variables.
env

# To run one time migrations if any.
kong migrations up
kong migrations bootstrap

# To start kong server
kong start

curl -I localhost:8001 # curl should be preinstalled and if not can do `apk add curl`.
# HTTP/1.1 200 OK
# Server: openresty
# Date: Fri, 27 Mar 2020 11:24:49 GMT
# Content-Type: text/html; charset=UTF-8
# Connection: keep-alive
# Access-Control-Allow-Origin: *
# X-Kong-Admin-Latency: 256

# Reload kong after changes in plugin code.
# This works because `kong-plugins/kong-plugin` is mounted on `/kong-plugin` in container
kong prepare
kong reload
```

## Enabling the plugin

Edit the `kong.conf` configuration file to make the following changes

1. Add the plugin in `plugins` as comma-separated values

```
plugins=myplugin
```

## Demo Video
[https://www.youtube.com/watch?v=YyRvzT6ng9U](https://www.youtube.com/watch?v=YyRvzT6ng9U)
