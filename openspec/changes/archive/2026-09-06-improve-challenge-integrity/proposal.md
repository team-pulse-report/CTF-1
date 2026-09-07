# Improve challenge integrity

## Why

An adversarial review of this challenge on 2026-09-06 (10 deep reviewers plus 10
independent skeptics against the files as built) found the documented solution
path is self-contradicting at the gleb -> rebeca -> container-root escalation:

- Stage 6 drives `sudo` from the SUID-`find` shell, but `sudo` authorizes by
  real UID and the `find -exec /bin/sh -p` shell leaves ruid=gleb, so the
  documented escalation dead-ends.
- The walkthrough labels `rebeca`'s SSH private key a red herring, when that key
  is in fact the load-bearing way to obtain a real `rebeca` login (ruid=rebeca)
  and pass `sudo`. `rebeca`'s account password is randomized at build time, so
  the key is the only route in.
- `docker-web/nginx.Dockerfile` installs the crontab twice: `crontab /etc/crontab`
  registers `/etc/crontab` (which carries a `user` field) as root's user
  crontab, which is malformed for a user crontab and errors every minute, on top
  of the correct system crontab that `service cron start` already runs.
- `docker-web/sudoers` carries a redundant `rebeca ... NOPASSWD: /usr/bin/sudo -l`
  grant and a stray trailing-whitespace line.

The challenge is still solvable; the defect is that the intended, documented path
does not work as written and mislabels the credential that makes it work.

## What Changes

- ADDED requirement: the documented solution path is reproducible against the
  files as built, with no dead-ending or self-contradicting stage (rewrite
  Stages 5-6 of `docs/WALKTHROUGH.md` to read `rebeca`'s key via the euid shell,
  `ssh -i` back in as a real `rebeca`, then `sudo nano`).
- ADDED requirement: the walkthrough classifies each credential/key honestly; a
  key required to complete a documented stage is not labeled a red herring
  (delete the red-herring note for `rebeca`'s SSH key).
- ADDED requirement: scheduled jobs and service startup are free of recurring
  errors (drop the double crontab install; keep the single system crontab).
- ADDED requirement: build pins stay reproducible and their rot risk is
  documented (keep the exact `DOCKER_CLI_VERSION` pin; note the bump reminder).

## Impact

- Affected: documentation and challenge build/config content only
  (`docs/WALKTHROUGH.md`, `docker-web/nginx.Dockerfile`, `docker-web/sudoers`,
  `CHANGELOG.md`, `README.md`).
- No scoring change: no flag value is changed, and no flag file's content is
  moved or deleted; flags remain reachable by their intended readers.
- No credential change: `rebeca`'s password stays randomized (never documented),
  so no credential goes out of sync; the SSH keypair in `docker-web/.ssh.tar` is
  unchanged.
- Out of scope: any change to the SQLi entry, the MySQL/king credentials, the
  flag values, or the docker.sock breakout mechanics.
- No git commit: edits are left uncommitted in the working tree on `main`; a
  later phase archives the OpenSpec change.
