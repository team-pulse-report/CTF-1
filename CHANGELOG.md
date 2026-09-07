# Changelog

## Integrity fixes (2026-09-06)

Follow-up from an adversarial review of the challenge. Documentation and
build/config hygiene only: no flag value changed, no flag moved, and no scoring
change.

### Fixed

- Corrected the documented escalation. Stage 6 previously drove `sudo` from the
  SUID-`find` shell, but `sudo` authorizes by real UID and that shell leaves
  ruid=gleb, so the documented path dead-ended. `docs/WALKTHROUGH.md` now reads
  `rebeca`'s SSH key through the euid=rebeca shell, `ssh -i` back in as a real
  `rebeca` (ruid=rebeca), then `sudo nano`. Its account password is randomized,
  so the key is the only login route.
- Stopped mislabeling `rebeca`'s SSH private key as a red herring in the
  walkthrough Notes; it is load-bearing.
- Dropped the double crontab install in `docker-web/nginx.Dockerfile`.
  `crontab /etc/crontab` registered the system crontab (which carries a `user`
  field) as root's user crontab, which is malformed and errored every minute;
  `service cron start` already runs `/etc/crontab` as the system crontab.
- Removed a redundant `rebeca ... NOPASSWD: /usr/bin/sudo -l` grant and a stray
  trailing-whitespace line in `docker-web/sudoers`; the only `rebeca` grant is
  the intended NOPASSWD `/usr/bin/nano`.

### Documented

- Noted in `docker-web/nginx.Dockerfile` that `DOCKER_CLI_VERSION` is an exact
  pin to bump when the static tarball stops resolving.
- Noted in `README.md` that `docker-web/.ssh.tar` is an intentional disposable
  challenge key, to preempt false-positive secret-scan reports.

## Quality overhaul

Maintained fork of the original Docker-in-Docker CTF. This revision fixes the
challenge logic, updates all base image versions, and cleans up build hygiene.

### Fixed

- Wired the final escape. The web container now has the outer Docker socket
  mounted (`/var/run/docker.sock`). Root inside the web container can drive the
  outer Docker engine and break out to the outer host to read `root.txt`.
  Previously the outer `root.txt` was unreachable: the web container had no
  socket, was not privileged, and the outer `king` user had no path to root, so
  the final flag could not be captured by any intended route.
- Made the web-container track reachable from the web. A `backup_credentials`
  table now stores gleb's system login as an unsalted MD5, so a player who reads
  the database (SQL injection plus the exposed MySQL port) can crack gleb's
  password. Before, gleb's password only existed inside the build files on the
  outer host, which forced an odd ordering and spoiled the whole privilege
  escalation route.
- Fixed the malformed HTML comment in `robots.txt` (`<--!` to `<!--`).

### Changed

- Base image versions bumped:
  - nginx `1.27.2` to `1.30.4`
  - php-fpm `8.2-fpm-alpine` to `8.4-fpm-alpine`
  - mysql `8.0.40-debian` to `8.4` (current LTS)
  - ubuntu stays at `24.04` (current LTS)
- Removed the deprecated `version:` key from the Compose file and added DNS to
  every service so builds and pulls resolve inside the nested engine.
- Regenerated every flag value and the MySQL root password, so old writeups do
  not spoil this fork.
- Rewrote the README (no emojis) and documented the intended solution in
  `docs/WALKTHROUGH.md`.

### Removed

- Deleted the 83 MB pre-baked `docker-images/php-fpm.tar`. It was an amd64-only
  image that broke nested builds on arm64 and only saved one image pull (mysql
  and nginx already pulled at runtime). The inner stack now pulls all base
  images normally, which makes the challenge multi-arch and shrinks the working
  tree by about 83 MB.

### Build hygiene

- Added `.dockerignore` so the git history, docs, license, and runtime state are
  not sent into the build context or baked into image layers.
- Added the runtime MySQL data directory and log directory to `.gitignore`.
