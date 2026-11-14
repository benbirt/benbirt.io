# benbirt.io

The source of [benbirt.io](https://benbirt.io): a one-page static site, built
by [Zola](https://www.getzola.org/) under Bazel and served by GitHub Pages.

## Editing

The copy is Markdown, in [`site/content/_index.md`](site/content/_index.md).
The page's HTML frame is [`site/templates/index.html`](site/templates/index.html)
and its styling is [`site/static/style.css`](site/static/style.css).

Under each project heading, the list is its line of links: each item is one
link, and the items are laid out on a single line.

## Building

```sh
bazel build //site:public   # the site, in bazel-bin/site/public
bazel run //site:public     # a live preview of the source tree
```

Both need only Bazel (or Bazelisk), on Linux x86_64 or macOS arm64: Bazel
downloads the pinned Zola release. A weekly workflow
([`update-zola.yml`](.github/workflows/update-zola.yml)) opens a pull request
when Zola has a new release.

## Deploying

Every push to `main` builds the site and deploys it to GitHub Pages
([`pages.yml`](.github/workflows/pages.yml)).

## DNS and email

The domain's DNS records and its email routing (`ben@benbirt.io`) are OpenTofu
configuration in [`infra/`](infra/), run through
[rules_tofu](https://github.com/benbirt/rules_tofu):

```sh
bazel build //infra    # validates the configuration; needs no credentials
infra/run.sh plan      # plans from this computer, with the keys from KDE Wallet
```

CI plans on pull requests that change `infra/` and applies on pushes to `main`
([`infra.yml`](.github/workflows/infra.yml)). State is in the Cloudflare R2
bucket `benbirt-io-tofu-state`.

One Cloudflare token serves all of it: an account-owned API token,
`benbirt-io-tofu` (Manage account > Account API tokens), with three policies:

| Scope | Permissions |
| --- | --- |
| The `benbirt.io` zone | Zone: Read, DNS: Edit, Email Routing Rules: Edit |
| The account | Email Routing Addresses: Edit |
| The R2 bucket `benbirt-io-tofu-state` | Object Read & Write |

The `cloudflare` provider uses the token as it is. For the state bucket,
[`tools/r2-keys.sh`](tools/r2-keys.sh) derives R2's S3 keys from it by
Cloudflare's rule (the access key ID is the token's ID, the secret the SHA-256
of the token), so there are no separate R2 keys to keep.

The workflow reads two repository secrets (and Dependabot secrets of the same
names, for its provider updates). `infra/run.sh` reads the same two values
from KDE Wallet.

| Secret | What it is | In KDE Wallet |
| --- | --- | --- |
| `CLOUDFLARE_API_TOKEN` | The token above | `secret-tool store --label="Cloudflare benbirt-io-tofu" service cloudflare token benbirt-io-tofu` |
| `FORWARD_TO` | The mailbox that `ben@benbirt.io` forwards to | `secret-tool store --label="benbirt.io forward-to" service cloudflare forward-to benbirt.io` |

Two steps are done by hand, once:

- Cloudflare emails the forwarding mailbox a link when its address is first
  applied, and forwards nothing until the link has been followed.
- The repository's custom domain is set in its Pages settings, after the DNS
  records exist.
