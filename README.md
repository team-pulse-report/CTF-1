# Docker-in-Docker CTF

Docker-in-Docker CTF is a Capture The Flag challenge that runs as a single
privileged Docker container. Inside it, an outer host runs its own Docker engine
and deploys a small web stack (nginx, php-fpm, mysql) with Docker Compose. The
goal is to work through the web application into the inner containers, escalate
privileges, and finally break back out to the outer host.

There are five flags:

| Flag file | Location | Prefix |
|---|---|---|
| user.txt | outer host, user `king` | `MAIN_FLAG{...}` |
| gleb.txt | web container, user `gleb` | `FLAG{...}` |
| rebeca.txt | web container, user `rebeca` | `FLAG{...}` |
| docker-root.txt | web container, `root` | `DOCKER_FLAG{...}` |
| root.txt | outer host, `root` | `MAIN_FLAG{...}` |

## Requirements

- Docker Engine that can run a privileged container (Docker Desktop works).
- Internet access on the first run: the inner stack pulls its base images
  (nginx, php, mysql) and a static Docker client at build time.
- Works on both amd64 and arm64 hosts.

## Deployment options

### 1. Build the image from this repository (recommended)

```bash
git clone https://github.com/jesse-quinn/CTF-1.git
cd CTF-1
sudo docker image build -t docker-ctf:latest .
sudo docker container run -it --rm --privileged \
  --hostname docker-ctf --name docker-ctf \
  -p 8080:8080 -p 22:22 -p 23:23 -p 3306:3306 \
  docker-ctf:latest
```

Then wait for the inner Docker Compose stack to finish deploying. The web
application is served on port 8080.

Note: if you use `-d`, you will not see the inner Compose deployment progress.

If some of those host ports are already in use on your machine, remap the left
side of each `-p` flag (for example `-p 18080:8080 -p 2222:22 -p 2323:23
-p 33060:3306`); the challenge itself is unaffected.

### 2. TryHackMe

The original challenge is published as a TryHackMe room:
<https://tryhackme.com/jr/docker-ctf>. The room tracks the upstream project and
may lag the improvements in this repository.

### 3. VirtualBox image

An OVA image may be published in the releases section. Import it, set the network
adapter to Bridged Adapter, start the VM, and access the challenge on the
assigned IP address.

## Flag verification site

A companion flag verification site exists upstream:
<https://github.com/ilolm/ctf-flag-verification-site.git>.

## Rules

- Do not read the flag files or the solution notes during setup. The challenge
  is finding them through gameplay.
- The intended solution path is documented, for maintainers, in
  `docs/WALKTHROUGH.md`. It is a spoiler; do not open it if you want to play.

## Credits

This project is a maintained fork of the original Docker-in-Docker CTF by ilolm
(<https://github.com/ilolm/docker-CTF>). See `CHANGELOG.md` for what changed.
