# Railway Template Composer Checklist — WordPress

Apply these settings in the Railway template composer when generating the template from the project.

**Expected services this template deploys:** `wordpress` (the app), `MySQL`. **Verify against the actual live service name once deployed** — Railway auto-assigns a random adjective-noun name to GitHub-connected services, so `wordpress` below is a placeholder until confirmed live via `railway status --json`.

**SEO note (applies to every future template, not just this one):** when generating the template, set the **Title field to just `WordPress`**, plain name only. Railway derives the marketplace URL slug directly from this field, and a decorated title like `WordPress [Updated Jul '26]` produces a long, messy slug that hurts search ranking. See `SKILL.md`'s Title section for the full rule.

---

## 1. Healthcheck Settings

### `wordpress` (app service)
- **Healthcheck Path:** `/wp-login.php` — always returns a real page (the login form) whether or not setup is complete, unlike `/` which redirects to the first-run installer on a fresh deploy. Verify empirically on first real deploy since WordPress's exact redirect behavior can vary by version.
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

| Variable | Value | Mark Optional? | Description |
|----------|-------|-----------------|-------------|
| `MYSQL_URL` | Auto-set by Railway's plugin — leave as is | No | Standard connection string. Not directly used by WordPress (which uses the individual `WORDPRESS_DB_*` params instead), but other tools/clients may expect it. |
| `MYSQLHOST` | Auto-set by Railway's plugin — leave as is | No | Internal hostname — what `WORDPRESS_DB_HOST` actually connects through. |
| `MYSQLPORT` | `3306` | No | Port MySQL listens on internally. **Verify this is actually filled in, not left as an empty "to be filled by the user" placeholder** — this exact composer glitch has recurred on this project's Umami and NocoDB templates for Postgres, verify it doesn't also happen for MySQL. |
| `MYSQLUSER` | `root` (Railway's own default) | No | Database username. |
| `MYSQLDATABASE` | `railway` (Railway's own default) | **Yes** | Default database name created on startup. |
| `MYSQLPASSWORD` | Whatever Railway's plugin actually prefills — **verify live via the composer screenshot, don't assume a specific length**. This exact wrong guess has already happened on multiple other templates in this project. | No | Auto-generated password. |
| `MYSQL_ROOT_PASSWORD` | Same as `MYSQLPASSWORD` — verify live | No | Root password for the MySQL server itself. |

---

## 3. Secrets That Must Use `${{secret()}}`

WordPress itself has no application-level secret variable exposed the way Umami/NocoDB/Typebot have — WordPress generates its own internal authentication salts/keys automatically on first run and stores them in the database, not as an env var. **Do not invent a fake secret variable here** — there genuinely isn't one to add on the WordPress service itself.

| Variable | Template Syntax |
|----------|-----------------|
| `MYSQLPASSWORD` | Whatever Railway's plugin already prefilled — verify live, don't assume a length |

---

## 4. Volumes

**Required.** Mount a Railway Volume to `/var/www/html/wp-content` on the `wordpress` service. This is where WordPress stores uploaded media, installed themes, and installed plugins. Without this volume, all of that is lost on every redeploy, even though posts/pages/settings (stored in MySQL) would survive.

---

## 5. Known Troubleshooting

- **Site URL mismatch after a domain change:** WordPress stores its site URL in the database and uses it to generate every internal link. If the Railway domain changes after initial setup (custom domain added later, for example), links, CSS, and images can break, and login can loop. This needs to be fixed from WordPress's own Settings → General (or the `wp_options` table directly for a locked-out instance), not something this template can prevent automatically.
- **Upload failures on a fresh install:** the stock WordPress image ships with PHP's restrictive default `upload_max_filesize` (2MB) and `post_max_size`. This template's Dockerfile raises both to 64MB — if a deployer sees an upload error anyway, confirm the Dockerfile's `conf.d/uploads.ini` addition actually made it into the built image.
- **Healthcheck path may need re-verification per WordPress version:** `/wp-login.php` was chosen because it reliably returns a real page whether or not first-run setup is complete, but confirm this is still true on whatever WordPress version is pinned at publish time, since redirect behavior has changed across major versions before.
- **Floating `latest` tag risk:** avoided by pinning `wordpress:7.0.2-php8.3-apache`, verified against Docker Hub's tags API as the current numbered release matching `php8.3-apache`'s push date at authoring time. Re-verify this is still current before publishing if significant time has passed since authoring, WordPress ships security releases fairly often.

---

## 6. Post-Deploy Steps

After the template is published, test-deploy from a fresh Railway account (incognito window) and verify:

1. No "needs configuration" prompts appear for MySQL's auto-injected variables.
2. Both services (`wordpress`, `MySQL`) come online and the app responds with a real `200` at `/wp-login.php`.
3. Open the actual Railway domain in a browser and complete the real first-run setup wizard (site title, admin account, email) — don't just curl the healthcheck endpoint.
4. Upload a real media file larger than 2MB and confirm it succeeds, proving the raised upload limit actually took effect.
5. Install a theme or plugin from the dashboard and confirm it activates successfully, proving `wp-content` write access via the mounted volume works correctly.
