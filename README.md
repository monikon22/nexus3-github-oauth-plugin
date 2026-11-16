[![Release](https://github.com/monikon22/nexus3-github-oauth-plugin/actions/workflows/release.yml/badge.svg)](https://github.com/monikon22/nexus3-github-oauth-plugin/actions/workflows/release.yml)
![Total Downloads Badge](https://img.shields.io/github/downloads/monikon22/nexus3-github-oauth-plugin/total.svg)
# Nexus3 Github OAuth Plugin
This plugin adds a Github realm to Sonatype Nexus Repository and enables you to authenticate with Github Users and authorize with Github Orgs and Teams.

This fork targets **Nexus Repository 3.98.x** (Spring Boot runtime). See [README_PORT.md](README_PORT.md) for what changed compared to the original Karaf-based plugin.

The plugin does not implement a full OAuth flow, instead you use your github user name + an OAuth token you generated in your account to log in to the nexus.
This works through the web as well as through tools like maven, gradle etc.

## Setup

#### 1. Activate the Realm
Log in to your nexus and go to _Administration > Security > Realms_. Move the Github Realm to the right. The realm order in the form determines the order of the realms in your authentication flow. We recommend putting Github _after_ the built-in realms:
![setup](setup.png)

#### 2. Group / Roles Mapping
When logged in through Github, all organizations and teams the user is a member of will be mapped into roles like so:

_organization name/team name_ e.g. `dummy-org/developers`

You need to manually create these roles in _Administration > Security > Roles > (+) Create Role > Nexus Role_ in order to assign them the desired privileges. The _Role ID_ should map to the _organization name/team name_. Note that by default anybody is allowed to login (authenticate) with a valid Github Token from your Github instance, but he/she won't have any privileges assigned with their teams (authorization) - see the config property `github.org` if you want to change that behaviour.

![role-mapping](role-mapping.png)

## Usage

The following steps need to be done by every developer who wants to login to your nexus with Github.
#### 1. Generate OAuth Token

In your github account under _Settings > Personal access tokens_ generate a new OAuth token. The only scope you need is **read:org**

#### 2. Login to nexus

When logging in to nexus, use your github user name as the username and the oauth token you just generated as the password.
This also works through maven, gradle etc.

Example Maven settings.xml fragment:

```xml
<servers>
  <server>
    <id>Id that matches the id element of the repository/mirror that Maven tries to connect to</id>
    <username>Your Github user name</username>
    <password>Your Github token</password>
  </server>
</servers>
```

## Installation

#### 0. Prerequisites

* Nexus Repository 3.98.x, installed in `/opt/nexus` (adjust `--nexus-home` below if yours differs)
* `bash`, `python3` and root access on the Nexus host

Nexus 3.98 starts through the Spring Boot `JarLauncher` and no longer scans the `deploy/` directory, so the old `.kar` drop-in install does not work. The plugin is embedded into the Nexus boot jar by an installer script instead.

#### 1. Download and install

Download the plugin jar, `install-nexus-plugin.sh` and `SHA256SUMS` from the [latest release](https://github.com/monikon22/nexus3-github-oauth-plugin/releases/latest), then:

```shell
sha256sum -c SHA256SUMS
chmod +x install-nexus-plugin.sh
sudo ./install-nexus-plugin.sh \
  --plugin nexus3-github-oauth-plugin-<version>.jar \
  --nexus-home /opt/nexus
```

The script backs up the Nexus boot jar before patching it. Rollback and details are in [README_PORT.md](README_PORT.md#deploy).

#### 2. Create configuration
Create `$NEXUS_HOME/etc/githuboauth.properties` (or `/opt/sonatype-work/nexus3/etc/githuboauth.properties`).

Within the file you can configure the following properties:

|Property        |Description                              |[Default](src/main/java/org/sonatype/nexus/plugins/githuboauth/GithubOauthConfiguration.java)|
|---             |---                                      |---    |
|`github.api.url`|URL of the Github API to operate against.|`https://api.github.com`|
|`github.principal.cache.ttl`|[Java Duration](https://docs.oracle.com/javase/8/docs/api/java/time/Duration.html#parse-java.lang.CharSequence-) for how long a given Access will be cached for. This is a tradeoff of how quickly access can be revoked and how quickly a Github user's rate limit will be reached for the Github User API. _Note:_ Github Enterprise does not have a rate limit!|`PT1M` (1 Minute)|
|`github.org`|The comma-separated list of Organizations the user should be a member of. If this is not set, anyone with a Github account is allowed to log in.|----|
|`request.timeout.connection-request`|The timeout in milliseconds used when requesting a connection from the connection manager. A timeout value of zero is interpreted as an infinite timeout. A negative value is interpreted as undefined (system default).|`-1`|
|`request.timeout.connect`|The timeout in milliseconds until a connection is established. A timeout value of zero is interpreted as an infinite timeout. A negative value is interpreted as undefined (system default).|`-1`|
|`request.timeout.socket`|The socket timeout (`SO_TIMEOUT`) in milliseconds, which is the timeout for waiting for data  or, put differently, a maximum period inactivity between two consecutive data packets). A timeout value of zero is interpreted as an infinite timeout. A negative value is interpreted as undefined (system default).|`-1`|

This is what an example file would look like:
```properties
# note: no trailing slash!!!
github.api.url=https://github.example.com/api/v3
github.principal.cache.ttl=PT1M
```

#### 3. Restart Nexus
Restart your Nexus instance to let it pick up your changes, then activate the realm as described in [Setup](#setup).

## Development
Requires JDK 21+ and Maven 3.9.6+. Build with the integrated maven wrapper:

```shell
./mvnw -Denforcer.skip=true clean package
```

The shaded plugin jar ends up in `target/`. Releases are built by the [release workflow](.github/workflows/release.yml) when a `v*` tag is pushed (or when it is started manually).

## Credits

The whole project is heavily influenced by the [nexus3-crowd-plugin](https://github.com/pingunaut/nexus3-crowd-plugin).

Originally written by [larscheid-schmitzhermes](https://github.com/larscheid-schmitzhermes/nexus3-github-oauth-plugin); this fork continues through [L21s](https://github.com/L21s/nexus3-github-oauth-plugin) and [cheese-work](https://github.com/cheese-work/nexus3-github-oauth-plugin).
