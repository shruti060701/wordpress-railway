## Template Titles

**Railway Title:** `WordPress` (plain name only, this field controls the URL slug)
**Railway Description:** `WordPress [Jul '26] (Self-Hosted Content Management System) Self Host`
**Spreadsheet Title:** `WordPress (Open-Source CMS, Blogging & Website Builder Platform)`
**GitHub Description:** `WordPress: the open-source CMS powering 40%+ of the web, self-hosted on Railway with one click.`

---

![WordPress admin dashboard showing posts and site management](https://res.cloudinary.com/dt8h4kuxe/image/upload/v1746791300/wordpress-banner.png "Hosting WordPress on Railway")

# Deploy and Host Self-Hosted WordPress (Open-Source CMS) on Railway

WordPress is the open-source content management system powering over 40% of all websites on the internet. Build blogs, business sites, online stores, or full custom applications with total control over plugins, themes, and hosting, no platform lock-in, no per-site fees eating into your budget as you grow.

## About Hosting WordPress Open-Source Software on Railway (Self-Hosted WordPress Template)

Self-hosting WordPress means you control every plugin, every theme, and every byte of your content, no managed platform vetting or blocking what you can install. Railway provisions managed MySQL for your content, a persistent volume for uploads and themes, automatic HTTPS, and zero-config private networking, so you get the full, unrestricted CMS without managing a server yourself.

## Why Deploy WordPress, the WP Engine & Wix Alternative on Railway (Railway Free Trial)

WP Engine's entry-level managed hosting starts at $25-30/month for a single site with a 25k monthly visit cap, and its Growth tier runs $96-109/month for 10 sites. WordPress self-hosted on Railway costs a flat infrastructure fee with no visit caps, no site limits baked into the price, and no plugin restrictions a managed host might impose. Railway's $5 free trial covers your first month of hosting it.

### Railway vs Other Hosting Providers and VPS for WordPress Self Hosting

| Provider          | What You Get with Railway           | What You Get with the Other Provider     |
| ----------------- | ------------------------------------ | ----------------------------------------- |
| **DigitalOcean**  | Managed MySQL, auto HTTPS, zero server maintenance | Raw droplets you patch, secure, and back up yourself |
| **AWS**           | Simple usage-based billing, no RDS/EC2 maze | Manual RDS setup, security groups, surprise egress fees |
| **Hetzner**       | One-click deploy, automatic domain, instant rollback | Cheap hardware but you own the OS, backups, and TLS |

## Common Use Cases for Hosted WordPress

- **Bloggers and writers**: Full ownership of content and audience, no platform algorithm deciding who sees your posts.
- **Small business websites**: A professional site with a contact form, service pages, and a blog, without a monthly SaaS website-builder fee.
- **Online stores**: Pair with WooCommerce for a full e-commerce site with no per-transaction platform cut beyond payment processor fees.
- **Agencies managing client sites**: Spin up a separate Railway project per client, each fully isolated, without per-site managed-hosting markups.
- **Developers building custom themes/plugins**: Full filesystem and database access for custom development work a managed host would restrict or charge extra for.

![WordPress plugin repository showing installable plugins and themes](https://res.cloudinary.com/dt8h4kuxe/image/upload/v1746791301/wordpress-features.png "WordPress plugin and theme ecosystem")

## Dependencies for WordPress Docker Hosted on Railway

WordPress needs a MySQL (or MariaDB-compatible) database for posts, pages, users, and settings, plus persistent storage for uploaded media, themes, and plugins.

### Deployment Dependencies for Managed WordPress Service (Content Management System)

This template provisions Railway-managed MySQL and a persistent volume mounted at `wp-content`, both wired to the WordPress container over Railway's private network. No Redis, no separate cache layer, WordPress runs as a single PHP/Apache process plus its database.

### Implementation Details for WordPress (Using WordPress Official Docker Image)

The template deploys `wordpress:7.0.2-php8.3-apache`, a specific verified release tag matching the image's actual `latest` digest at build time, not a floating tag that could silently change. Apache inside the image always listens on port 80 internally, not configurable via a simple env var, so `PORT=80` is set explicitly as a Railway variable rather than relying on a Dockerfile default alone. Upload limits are raised to 64MB (the stock PHP default is a restrictive 2MB), enough for most media uploads without extra configuration.

## Environment Variables Reference for WordPress on Railway

| Variable | Description | Value |
|----------|-------------|-------|
| `WORDPRESS_DB_HOST` | Hostname for WordPress's MySQL database. | `${{MySQL.MYSQLHOST}}` |
| `WORDPRESS_DB_USER` | Username for WordPress's MySQL database. | `${{MySQL.MYSQLUSER}}` |
| `WORDPRESS_DB_PASSWORD` | Password for WordPress's MySQL database. | `${{MySQL.MYSQLPASSWORD}}` |
| `WORDPRESS_DB_NAME` | Database name for WordPress's content. | `${{MySQL.MYSQLDATABASE}}` |
| `WORDPRESS_DB_PORT` | Port for WordPress's MySQL database. | `${{MySQL.MYSQLPORT}}` |
| `PORT` | Port Railway routes external traffic to. Must be set explicitly, Apache inside the image isn't configurable to read a dynamic port variable. | `80` |

## How Does WordPress Compare Against Other CMS/Website Platforms

### WordPress vs Wix
* **Pricing:** WordPress self-hosted has no per-site subscription; Wix's Business plans run $27-159/month depending on tier.
* **Flexibility:** WordPress supports 60,000+ plugins and any custom theme; Wix restricts you to its own app marketplace and drag-and-drop builder.
* **Data ownership:** WordPress content lives in a database you control; Wix content stays locked to Wix's platform with no true export.

### WordPress vs Squarespace
* **Cost at scale:** WordPress has no per-site fee regardless of how many sites you run; Squarespace charges per site starting around $16-49/month each.
* **Customization:** WordPress allows full theme and plugin customization; Squarespace's templates are more restrictive by design.
* **E-commerce:** WordPress plus WooCommerce has no transaction fee beyond payment processing; Squarespace charges platform fees on lower tiers.

### WordPress vs WP Engine (Managed WordPress)
* **Cost:** Self-hosted WordPress on Railway avoids WP Engine's $25-30/month starting price and visit caps entirely.
* **Control:** Self-hosting gives full server and plugin access; WP Engine blocks certain plugins and restricts server-level changes.

## How to Use WordPress (the Open-Source CMS)?

Deploy the template, wait for the healthcheck to pass, open your Railway domain, and complete WordPress's own setup wizard, site title, admin account, and email, then start publishing.

## How to Self Host WordPress on Other VPS Services (WordPress Self Hosting Guide)

### Clone the Repository
Clone `github.com/WordPress/WordPress` or pull the `wordpress` image directly.

### Install Dependencies
Docker, plus a MySQL or MariaDB database. PHP 8.1+ is required if running without Docker.

### Configure Environment Variables
Set `WORDPRESS_DB_HOST`, `WORDPRESS_DB_USER`, `WORDPRESS_DB_PASSWORD`, and `WORDPRESS_DB_NAME` before starting the container.

### Start the WordPress Application
Run the container with a volume mounted at `wp-content`, and expose port 80 behind a reverse proxy with TLS.

## Official Pricing of WordPress (WordPress Pricing)

WordPress core software is GPL-2.0-licensed and entirely free to self-host, with no site cap, no visit cap, and no feature gating. The only cost is your own hosting infrastructure and any premium themes or plugins you choose to buy.

## WordPress Cloud vs Self Hosted Comparison (Pricing, Features, Costs, and More)

WordPress.com's hosted tiers and WP Engine's managed hosting both handle infrastructure for a recurring fee that scales with visits and site count. Self-hosting on Railway gives you the identical open-source WordPress core, full plugin freedom, and a predictable infrastructure cost with no visit caps.

### Monthly Cost of Self Hosting WordPress on Railway

Typical cost: $5-15/month covering the WordPress app, managed MySQL, and the storage volume together, regardless of how much traffic your site gets.

### System Requirements for Hosting WordPress on a VPS

Minimum: 1 shared vCPU, 512MB RAM, PHP 8.1+, MySQL 5.7+ or MariaDB 10.4+. Higher-traffic sites benefit from more RAM for PHP's opcode cache.

## Frequently Asked Questions (FAQs)

### What is WordPress self hosted?
The open-source CMS behind over 40% of the web, deployed on infrastructure you control instead of a managed platform like WordPress.com or WP Engine.

### How much does WordPress self hosting cost on Railway?
Typically $5-15/month total for the app, database, and storage volume combined, with no per-visit or per-site fees.

### Is WordPress free to use?
Yes, the core software is GPL-licensed and free forever. Some premium themes and plugins are paid, but the CMS itself has no license cost.

### Can I install any plugin or theme?
Yes, full access to the WordPress plugin repository and custom uploads, unlike managed hosts that vet or block certain plugins for performance or security reasons.

### Will my uploads and plugins survive a redeploy?
Yes, as long as the Railway volume this template provisions stays attached to your project. Posts and settings live in MySQL; uploads, themes, and plugins live on the volume.

### Where can I download WordPress?
Source code is at `github.com/WordPress/WordPress`, with Docker images published as `wordpress`. This template pulls a specific verified version automatically.
