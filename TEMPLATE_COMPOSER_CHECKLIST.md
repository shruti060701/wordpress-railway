# Railway Template Composer Checklist — WordPress

Apply these settings in the Railway template composer when generating the template from the project.

**Expected services this template deploys:** `wordpress` (the app), `MySQL`. **Verify against the actual live service name once deployed** — Railway auto-assigns a random adjective-noun name to GitHub-connected services, so `wordpress` below is a placeholder until confirmed live via `railway status --json`.

**SEO note (applies to every future template, not just this one):** when generating the template, set the **Title field to just `WordPress`**, plain name only. Railway derives the marketplace URL slug directly from this field, and a decorated title like `WordPress [Updated Jul '26]` produces a long, messy slug that hurts search ranking. See `SKILL.md`'s Title section for the full rule.

---

## 1. Healthcheck Settings

### `wordpress` (app service)
- **Healthcheck Path:** `/wp-admin/install.php` — confirmed live via a real test deploy to return `200` in both the pre-install state (fresh DB, no tables) and after setup is complete. `/wp-login.php` was tried first and rejected: it returns `302` on a fresh uninstalled site (redirects toward the installer), which every real deployer hits on their first deploy, and Railway's healthcheck requires `2xx`, not `3xx`, to pass.
- **Healthcheck Timeout:** `120` seconds — needs to wait on the MySQL connection being ready, not just the PHP/Apache process starting.

### `MySQL`
- No public port exposed — no healthcheck needed (internal service only)

---

## 2. Variable Descriptions (Add to EVERY variable)

### `wordpress` (App) Variables

| Variable | Value | Mark Optional? | Description |
|----------|-------|-----------------|-------------|
| `WORDPRESS_DB_HOST` | `${{MySQL.MYSQLHOST}}` | No | Hostname for WordPress's MySQL database. |
| `WORDPRESS_DB_USER` | `${{MySQL.MYSQLUSER}}` | No | Username for WordPress's MySQL database. |
| `WORDPRESS_DB_PASSWORD` | `${{MySQL.MYSQLPASSWORD}}` | No | Password for WordPress's MySQL database. |
| `WORDPRESS_DB_NAME` | `${{MySQL.MYSQLDATABASE}}` | No | Database name for WordPress's content. |
| `WORDPRESS_DB_PORT` | `${{MySQL.MYSQLPORT}}` | No | Port for WordPress's MySQL database. |
| `PORT` | `80` | No | Port Railway routes external traffic to. Must be an explicit Railway variable — Apache inside the official WordPress image always listens on port 80 internally and isn't configurable to read a dynamic port variable, so this project's usual "Dockerfile-only default isn't enough" lesson applies here for a different underlying reason than other templates (a hardcoded app port, not a missing one). |

### `MySQL` Variables (Railway's standard managed database plugin)

**Important, confirmed live via the actual composer screenshot (not the CLI, which flattens references into resolved strings and hides this):** Railway's MySQL plugin exposes two layers of variables. The no-underscore ones (`MYSQLDATABASE`, `MYSQLPASSWORD`, `MYSQLHOST`, `MYSQLPORT`, `MYSQLUSER`) are compatibility aliases that just template-reference the underscored ones (`MYSQL_DATABASE`, `MYSQL_ROOT_PASSWORD`, etc.) — **never overwrite the alias variables' values, they should stay as `${{MYSQL_DATABASE}}`-style references.** Only add a description to them. The underscored variables underneath are the ones that actually need a real value if the composer shows them as empty.

| Variable | Value | Mark Optional? | Description |
|----------|-------|-----------------|-------------|
| `MYSQL_URL` | Auto-set by Railway's plugin — leave as is | No | Standard connection string. Not directly used by WordPress (which uses the individual `WORDPRESS_DB_*` params instead), but other tools/clients may expect it. |
| `MYSQLHOST` | `${{RAILWAY_PRIVATE_DOMAIN}}` (reference, leave as is) | No | Internal hostname — what `WORDPRESS_DB_HOST` actually connects through. |
| `MYSQLPORT` | `3306` | No | Port MySQL listens on internally. **Verify this is actually filled in, not left as an empty "to be filled by the user" placeholder** — this exact composer glitch has recurred on this project's Umami and NocoDB templates for Postgres. |
| `MYSQLUSER` | `root` (Railway's own default) | No | Database username. |
| `MYSQLDATABASE` | `${{MYSQL_DATABASE}}` (reference — do NOT change to a literal value) | No | Default database name, mirrors `MYSQL_DATABASE` below. |
| `MYSQL_DATABASE` | `railway` (Railway's own default) | **Yes** | The actual database name created on startup — this is the variable that needs a real value if shown empty, not `MYSQLDATABASE` above. |
| `MYSQLPASSWORD` | `${{MYSQL_ROOT_PASSWORD}}` (reference — do NOT change to a literal value) | No | Password for connecting to MySQL, mirrors `MYSQL_ROOT_PASSWORD` below. |
| `MYSQL_ROOT_PASSWORD` | Whatever Railway's plugin actually prefills (typically `${{secret(32, "...")}}`) — **verify live via the composer screenshot, don't assume a specific length**. This exact wrong guess has already happened on multiple other templates in this project. | No | Auto-generated root password for the MySQL server itself. |
| `MYSQL_PUBLIC_URL` | Auto-set by Railway's plugin — leave as is | No | Public/external connection string for reaching this database from outside Railway's network. |

---

## 3. Secrets That Must Use `${{secret()}}`

WordPress itself has no application-level secret variable exposed the way Umami/NocoDB/Typebot have — WordPress generates its own internal authentication salts/keys automatically on first run and stores them in the database, not as an env var. **Do not invent a fake secret variable here** — there genuinely isn't one to add on the WordPress service itself.

| Variable | Template Syntax |
|----------|-----------------|
| `MYSQL_ROOT_PASSWORD` | Whatever Railway's plugin already prefilled (typically `${{secret(32, "...")}}`) — verify live, don't assume a length. `MYSQLPASSWORD` is just a reference to this, not a separate secret. |

---

## 4. Volumes

**Required.** Mount a Railway Volume to `/var/www/html/wp-content` on the `wordpress` service. This is where WordPress stores uploaded media, installed themes, and installed plugins. Without this volume, all of that is lost on every redeploy, even though posts/pages/settings (stored in MySQL) would survive.

---

## 5. Known Troubleshooting

- **Site URL mismatch after a domain change:** WordPress stores its site URL in the database and uses it to generate every internal link. If the Railway domain changes after initial setup (custom domain added later, for example), links, CSS, and images can break, and login can loop. This needs to be fixed from WordPress's own Settings → General (or the `wp_options` table directly for a locked-out instance), not something this template can prevent automatically.
- **Upload failures on a fresh install:** the stock WordPress image ships with PHP's restrictive default `upload_max_filesize` (2MB) and `post_max_size`. This template's Dockerfile raises both to 64MB — if a deployer sees an upload error anyway, confirm the Dockerfile's `conf.d/uploads.ini` addition actually made it into the built image.
- **Apache "AH00534: More than one MPM loaded" crash (confirmed hit on a real deploy, not hypothetical):** the `wordpress:php8.x-apache` image's `mpm_event`/`mpm_worker` modules end up loaded alongside `mpm_prefork` specifically in Railway's runtime, a bug documented by other WordPress deployers on Railway's own community help station. A build-time-only `a2dismod`/`a2enmod` fix (a plain `RUN` step) was tested and did NOT resolve it, something in the container runtime re-enables the conflicting module after build. The working fix redoes the module toggle in the Dockerfile's `CMD`, immediately before `apache2-foreground` actually launches (see `Dockerfile`).
- **Healthcheck path re-verification per WordPress version:** `/wp-admin/install.php` was chosen and confirmed live to return `200` in both install states, but re-confirm this on whatever WordPress version is pinned at publish time if significant time has passed, since core behavior has changed across major versions before.
- **Floating `latest` tag risk:** avoided by pinning `wordpress:7.0.2-php8.3-apache`, verified against Docker Hub's tags API as the current numbered release matching `php8.3-apache`'s push date at authoring time. Re-verify this is still current before publishing if significant time has passed since authoring, WordPress ships security releases fairly often.

---

## 6. Post-Deploy Steps

After the template is published, test-deploy from a fresh Railway account (incognito window) and verify:

1. No "needs configuration" prompts appear for MySQL's auto-injected variables.
2. Both services (`wordpress`, `MySQL`) come online and the app responds with a real `200` at `/wp-admin/install.php`.
3. Open the actual Railway domain in a browser and complete the real first-run setup wizard (site title, admin account, email) — don't just curl the healthcheck endpoint.
4. Upload a real media file larger than 2MB and confirm it succeeds, proving the raised upload limit actually took effect.
5. Install a theme or plugin from the dashboard and confirm it activates successfully, proving `wp-content` write access via the mounted volume works correctly.
