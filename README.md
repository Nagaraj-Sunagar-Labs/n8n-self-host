# n8n Self-Host with Traefik + DuckDNS

Self-hosted [n8n](https://n8n.io/) setup using Docker Compose, Traefik reverse proxy, Let's Encrypt TLS, and DuckDNS for dynamic DNS.

## What is n8n?

n8n is an open-source workflow automation platform.  
You can connect apps, APIs, and custom logic to automate tasks without managing a full custom backend.

Why self-host n8n:
- Full control over data and deployment
- Flexible integration with custom/internal systems
- Low-cost option for personal projects and small teams

## What is Traefik in this setup?

Traefik is a modern reverse proxy and edge router for cloud-native apps.  
In this project, Traefik:
- Listens on ports `80` and `443`
- Routes requests for your domain to the n8n container
- Automatically requests and renews TLS certificates from Let's Encrypt

## Why DuckDNS?

DuckDNS provides free subdomains under `duckdns.org`.  
It is useful when you do not own a custom domain or when your public IP changes.

Example hostname:
- `your-subdomain.duckdns.org`

## Architecture

1. User opens `https://your-subdomain.duckdns.org`
2. DNS resolves that hostname to your server public IP
3. Traefik receives the request on `443`
4. Traefik terminates TLS and forwards traffic to n8n on port `5678`

## Prerequisites

- Docker + Docker Compose plugin installed
- Publicly reachable server (EC2/VPS recommended)
- Inbound ports `80` and `443` open in firewall/security group
- DuckDNS subdomain + token

## Environment Variables

Create `.env`:

```env
DOMAIN_NAME=duckdns.org
SUBDOMAIN=your-subdomain
SSL_EMAIL=you@example.com
GENERIC_TIMEZONE=Asia/Kolkata
DUCKDNS_TOKEN=your-duckdns-token
```

## Update DuckDNS Record

Use the included script:

```bash
bash dns.sh
```

The script updates your DuckDNS record using:
- `SUBDOMAIN`
- `DUCKDNS_TOKEN`

Important:
- DuckDNS API `domains=` must contain only the subdomain (not full `*.duckdns.org`).

## Deploy

```bash
docker compose pull
docker compose up -d
docker compose logs -f traefik
```

After startup, open:

```text
https://your-subdomain.duckdns.org
```

## Common Issues and Fixes

### 1) `NXDOMAIN` during certificate generation

Cause:
- DNS record does not exist yet or wrong subdomain used

Fix:
- Run DuckDNS update script
- Verify DNS:

```bash
nslookup your-subdomain.duckdns.org
```

### 2) `Timeout during connect` from Let's Encrypt

Cause:
- Server is not reachable on `80/443` from internet

Fix:
- Open security group/firewall ports `80` and `443`
- Verify router/NAT settings if hosting at home
- Prefer EC2/VPS to avoid ISP CGNAT issues

### 3) Traefik Docker API version errors

Cause:
- Traefik version incompatible with installed Docker Engine API version

Fix:
- Upgrade Docker Engine, or pin Traefik to a compatible version

## Security Notes

- Do not commit real secrets/tokens to GitHub
- Keep `.env` in `.gitignore`
- Avoid `--api.insecure=true` in production
- Pin image versions for predictable upgrades

## References

- n8n: https://n8n.io/
- Traefik docs: https://doc.traefik.io/traefik/
- DuckDNS: https://www.duckdns.org/
