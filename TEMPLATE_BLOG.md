# Deploy and Host WordPress Self-Hosted on Railway

WordPress is the open-source CMS that runs more than 40% of the web. Blogs, business sites, online stores, portfolios, whatever you're building, WordPress's plugin ecosystem and theme library cover it, and self-hosting means none of it comes with a managed platform's restrictions or per-site fees.

## About Hosting WordPress-Self-Hosted

WP Engine's entry-level managed plan starts at $25-30/month for a single site capped at 25,000 monthly visits. Its Growth tier, for agencies running multiple client sites, runs $96-109/month for just 10 sites. WordPress self-hosted on Railway costs a flat infrastructure fee with no visit cap and no artificial site limit baked into the pricing, so the math gets better the more you actually use it, the opposite of most managed hosting tiers.

The bigger reason to self-host WordPress specifically isn't just the price, though. Managed hosts vet, block, or throttle certain plugins for performance and security reasons, sometimes ones you actually need. Self-hosting means you install anything from the official plugin repository or upload custom code without asking permission. For developers building custom themes or plugins, that's not a convenience, it's the whole point.

It's also worth being clear about what "self-hosted" actually buys you here versus WordPress.com specifically. WordPress.com's free and lower tiers restrict plugin installation entirely, some plans don't allow custom plugins at all. Self-hosting the open-source WordPress core, the same software WordPress.com itself runs, removes that restriction completely, you're running the real thing with none of the platform's guardrails.

This distinction trips people up constantly, so it's worth stating plainly: "WordPress" and "WordPress.com" are not the same thing. WordPress.org publishes the free, open-source software this template deploys. WordPress.com is a separate commercial hosting company that happens to run that same software, with its own pricing tiers and restrictions layered on top. Self-hosting means you get the software with none of the second company's business decisions attached to it.

## Common Use Cases

- **Bloggers and independent writers**: Own your audience and content outright, no platform algorithm deciding your reach, no risk of a policy change burying your archive.
- **Small business websites**: A real site with service pages, a contact form, and a blog, without a recurring website-builder subscription on top of hosting.
- **Online stores**: Pair with WooCommerce for full e-commerce, no per-transaction platform cut beyond whatever your payment processor already charges.
- **Agencies managing multiple client sites**: Spin up a separate isolated Railway project per client instead of paying per-site markups a managed host bakes into every tier.
- **Developers building custom themes and plugins**: Full filesystem and database access for real development work, not the sandboxed environment a managed host gives you.
- **Portfolio and personal sites**: A flexible, ownable home base that doesn't disappear if a free-tier platform changes its terms or shuts down.
- **Membership and community sites**: WordPress's plugin ecosystem covers paywalls, forums, and course platforms without building any of it from scratch.

## Dependencies for WordPress-Self-Hosted Hosting

- MySQL (or MariaDB-compatible) database for posts, pages, users, comments, and settings.
- Persistent storage for uploaded media, installed themes, and plugins.

### Deployment Dependencies

This template provisions Railway-managed MySQL and a persistent volume mounted at `wp-content`, both wired to the WordPress container automatically over Railway's private network. Nothing needs manual connection setup between services. Reference: [WordPress Docker Documentation](https://hub.docker.com/_/wordpress), [WordPress Developer Resources](https://developer.wordpress.org/), [WordPress Plugin Directory](https://wordpress.org/plugins/).

### Implementation Details

This template runs `wordpress:7.0.2-php8.3-apache`, verified as the newest actual stable release tag in the registry at build time, matching the image's own `latest` digest rather than trusting a floating tag that could change under you. Apache inside the image listens on port 80 internally by default and isn't configurable to read a dynamic port variable the way some other apps are, so `PORT=80` is set explicitly as a Railway variable, a lesson already learned the hard way on other templates in this collection where a Dockerfile-only port default alone wasn't picked up by Railway's edge routing. Upload limits are also raised to 64MB, since the stock PHP configuration ships with a restrictive 2MB default that trips up anyone uploading real media on day one.

## How WordPress Compares to the Alternatives

**Vs. Wix**: Wix is fully managed and requires zero technical setup, but its Business plans run $27-159/month and lock you into its own app marketplace and drag-and-drop builder. WordPress trades some of that turnkey simplicity for full plugin freedom and content you can actually export and move anywhere.

**Vs. Squarespace**: Squarespace's polished templates come at a per-site cost, $16-49/month each, with no way to run multiple sites under one bill. WordPress has no per-site fee at all once it's deployed, and its theme customization goes deeper than Squarespace's more rigid template system.

**Vs. WP Engine**: WP Engine handles WordPress hosting and updates for you, but starts at $25-30/month with a visit cap and restricts which plugins you can run. Self-hosting on Railway costs less at typical traffic levels and removes every plugin restriction, at the cost of managing your own updates and backups.

## Getting Started

After deploying, give the healthcheck a moment to pass, WordPress needs its database connection confirmed before it's genuinely ready, not just the container starting.

Open your Railway domain and you'll land on WordPress's own five-minute setup screen: choose a site title, pick an admin username and a strong password (this becomes your only login, WordPress doesn't pre-create one for you), and enter an admin email for notifications. Submit that, and you're in the dashboard.

From here, the real first move is picking a theme under Appearance, install one from the official directory or upload a custom one, and setting your permalink structure under Settings before you publish anything real. Changing permalinks later breaks any links you've already shared, so it's worth deciding early rather than accepting the default and fixing it after the fact.

If you're building a store, install WooCommerce next and run through its own setup wizard, payment methods, shipping zones, tax settings, before adding real products. For anyone building a client site or anything with real traffic expected, install a caching plugin early too, WordPress's dynamic PHP rendering benefits significantly from page caching, and it's a much smaller job to set up before launch than to retrofit after.

One thing worth testing directly rather than assuming works: upload a real media file (an image over a few megabytes is a good test) and confirm it completes without an upload-limit error, this template raises the default limit specifically because the stock configuration trips up exactly this kind of test on a fresh install.

It's also worth checking Settings → General early and confirming your site URL matches your actual Railway domain exactly. WordPress stores this URL in its database and uses it to generate every internal link, get it wrong (say, by testing on one domain and later moving to another) and you'll see broken CSS, broken images, and login redirect loops that look like a bigger problem than they are.

## Why Deploy WordPress-Self-Hosted on Railway?

Railway is a singular platform to deploy your infrastructure stack. Railway will host your infrastructure so you don't have to deal with configuration, while allowing you to vertically and horizontally scale it.

By deploying WordPress-self-hosted on Railway, you are one step closer to supporting a complete full-stack application with minimal burden. Host your servers, databases, AI agents, and more on Railway.

## Frequently Asked Questions

### Do I need to know how to code to use WordPress?
No. The setup wizard, dashboard, and most themes and plugins are built for non-technical users. Coding knowledge only matters if you're customizing themes or building custom plugins yourself.

### Will my media uploads and plugins survive a redeploy?
Yes, as long as the Railway volume this template provisions stays attached to your project. Posts, pages, and settings live in MySQL; uploaded media, themes, and plugins live on the volume, both need to stay attached.

### Can I install premium (paid) themes and plugins?
Yes, self-hosting gives you full filesystem access, so any theme or plugin you've purchased elsewhere can be uploaded and activated, not just what's in the free official directory.

### What happens if I forget my admin password?
Since there's no pre-created account, you'd need database-level access to reset it (WordPress stores a password-reset mechanism, but it depends on your site's email being configured). Set up a real SMTP plugin early so WordPress's built-in "forgot password" flow actually delivers email.

### Does this template include WooCommerce or other plugins pre-installed?
No, this is a clean core WordPress install with nothing pre-configured. Install WooCommerce or any other plugin from the dashboard after your first login, exactly like a fresh WordPress.org download would be.

### Where can I download WordPress?
Source code is at `github.com/WordPress/WordPress`, with Docker images published as `wordpress`. This template pulls a specific verified version automatically.
