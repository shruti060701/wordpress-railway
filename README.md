# WordPress — Self-Hosted Content Management System

Deploy WordPress, the CMS that powers over 40% of the web, on Railway with one click. Full control over plugins, themes, and hosting, without a managed platform's per-site fees or plugin restrictions.

## Deploy on Railway

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/new/template)

## Features

- **Full plugin and theme freedom** — Install anything from the WordPress plugin repository or upload custom code, no managed-host restrictions.
- **Complete database ownership** — Your content lives in a Railway-managed MySQL database you fully control, not a third party's shared infrastructure.
- **Persistent uploads** — Media, themes, and plugins persist across redeploys via a Railway volume mounted at `wp-content`.
- **Automatic HTTPS** — Railway handles SSL certificates automatically, no manual configuration.
- **Pinned, stable image** — Runs `wordpress:7.0.2-php8.3-apache`, a specific verified release rather than a floating tag that could change behavior under you between deploys.

## How to Use

1. Click the Deploy on Railway button above.
2. Railway automatically provisions MySQL for WordPress's database and a persistent volume for `wp-content`.
3. Wait for the healthcheck to pass, then open your Railway domain.
4. Complete WordPress's own five-minute setup: site title, admin username, admin password, and admin email.
5. Log in at `/wp-admin` and start building, install a theme, add plugins, or start publishing.

## Notes

- **Data persistence** — Media uploads, installed themes, and plugins live on the Railway volume mounted at `wp-content`. Your actual posts, pages, and settings live in the MySQL database. Both need to stay attached to survive redeploys.
- **No pre-created admin account** — You create it yourself during the first-run setup wizard, in the browser, the first time you open the domain.
- **Complete setup immediately after deploying** — Until you finish the setup wizard, WordPress's installer is reachable by anyone who has your domain, with no login required. Whoever submits it first becomes the site admin. This is standard WordPress behavior everywhere, not specific to this template, but it means the setup step isn't optional-when-convenient: do it right after your first deploy, before sharing the domain with anyone.
- **Port** — Apache in the official image always listens on port 80 internally, this template sets `PORT=80` explicitly so Railway's edge routes correctly.
- **Upload limits raised** — This template bumps `upload_max_filesize` and `post_max_size` to 64MB (the stock image ships with a much lower 2MB default), enough for most media uploads without extra config.

## Self-Hosting on Other Platforms

Clone the repository:
```bash
git clone https://github.com/WordPress/WordPress
```

For Docker:
```bash
docker run -d --name wordpress \
  -e WORDPRESS_DB_HOST=your-db-host \
  -e WORDPRESS_DB_USER=wordpress \
  -e WORDPRESS_DB_PASSWORD=your-password \
  -e WORDPRESS_DB_NAME=wordpress \
  -v wp-content:/var/www/html/wp-content \
  -p 80:80 \
  wordpress:7.0.2-php8.3-apache
```

## License

WordPress is released under the GPL-2.0-or-later open-source license, free to self-host with no site or user limits.

## Support

- **GitHub** — https://github.com/WordPress/WordPress
- **Docs** — https://wordpress.org/documentation/
- **Support Forums** — https://wordpress.org/support/
- **Docker Image** — https://hub.docker.com/_/wordpress
