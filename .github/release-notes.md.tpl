GitHub OAuth authentication realm for Sonatype Nexus Repository 3.98.x, build `@VERSION@`.

## Release files

| File | Purpose |
|------|---------|
| `@JAR@` | the plugin (shaded jar) |
| `install-nexus-plugin.sh` | installer that embeds the plugin into the Nexus boot jar |
| `SHA256SUMS` | checksums |

## Installation

Nexus 3.98 starts through the Spring Boot `JarLauncher` and no longer scans the
`deploy/` directory. The plugin has to be embedded into the Nexus executable jar
(`BOOT-INF/lib`), which the installer script does for you.
Requirements: `bash`, `python3` and root access on the Nexus host.

1. Download all release files to the Nexus host and verify the checksums:

   ```bash
   sha256sum -c SHA256SUMS
   ```

2. Install the plugin. The script backs up the boot jar with a timestamp first:

   ```bash
   chmod +x install-nexus-plugin.sh
   sudo ./install-nexus-plugin.sh \
     --plugin @JAR@ \
     --nexus-home /opt/nexus
   ```

3. Restart Nexus during a maintenance window
   (or add `--restart` to the command above):

   ```bash
   sudo systemctl restart nexus
   ```

4. In the UI go to *Administration → Security → Realms*, move
   `Github Enterprise Authentication Realm` from Available to Active and save.

5. Configure the plugin (`github.org`, request timeouts, etc.) in
   `etc/githuboauth.properties` as described in
   [README_PORT.md](https://github.com/@REPO@/blob/@TAG@/README_PORT.md),
   then restart Nexus.

## Verify

```bash
curl -s -u admin:<password> http://127.0.0.1:8081/service/rest/v1/security/realms/available | grep -i github
```

## Rollback

```bash
sudo cp /opt/nexus/bin/sonatype-nexus-repository-<version>.jar.backup.<timestamp> \
  /opt/nexus/bin/sonatype-nexus-repository-<version>.jar
sudo systemctl restart nexus
```

Details about the port: [README_PORT.md](https://github.com/@REPO@/blob/@TAG@/README_PORT.md).
