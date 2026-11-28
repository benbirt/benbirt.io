# benbirt.io

The source of [benbirt.io](https://benbirt.io): a one-page static site, built
by [Zola](https://www.getzola.org/) under Bazel and served by GitHub Pages.

## Editing

The copy is Markdown, in [`site/content/_index.md`](site/content/_index.md).
The HTML around it is in [`site/templates/`](site/templates/)
and its styling is [`site/static/style.css`](site/static/style.css).

Under each project heading, the list is its line of links: each item is one
link, and the items are laid out on a single line.

## Writing a post

A post is a Markdown file in [`site/content/blog/`](site/content/blog/);
its file name is its address, so `on-witnesses.md` is published at
`/blog/on-witnesses/`. It starts with:

```toml
+++
title = "On witnesses"
date = 2026-11-20
description = "One sentence, shown in lists of posts, the feed and link previews."
draft = true
+++
```

- **Drafts**: a post with `draft = true` is left out of the site. `bazel run
//site:public -- --drafts` previews it; delete the line to publish.
- **Where posts appear**: on `/blog/`, in the Atom feed at `/atom.xml`, and
  on the front page, where its Markdown has the comment `<!-- blog -->`
  (the five newest). The front page shows no "Blog" heading until there is
  a post.
- **Markdown**: fenced code blocks are highlighted when they name their
  language, and footnotes and tables work. Posts are plain Markdown, with no
  template syntax, so braces need no escaping.
- **Images**: put the file beside the post, in a directory of the post's own:
  `blog/on-witnesses/index.md` with `diagram.png`, referred to as
  `![A diagram](diagram.png)`.

## Building

```sh
bazel build //site:public   # the site, in bazel-bin/site/public
bazel run //site:public     # a live preview of the source tree
```

Both need only Bazel (or Bazelisk), on Linux x86_64 or macOS arm64: Bazel
downloads the pinned Zola release. A weekly workflow
([`update-zola.yml`](.github/workflows/update-zola.yml)) opens a pull request
when Zola has a new release.

## Formatting

```sh
bazel run //tools:format    # formats every file
bazel run //tools:lint      # lints the Bazel files with buildifier
```

CI runs `bazel run //tools:format.check` and `bazel run //tools:lint`. The
formatters and their settings come from
[benbirt/bazel-style](https://github.com/benbirt/bazel-style), a dev
dependency.

## Deploying

Every push to `main` builds the site and deploys it to GitHub Pages
([`pages.yml`](.github/workflows/pages.yml)).

## Analytics

Every page loads [`site/static/analytics.js`](site/static/analytics.js), which
sends one `$pageview` event per load to [PostHog](https://posthog.com/) in its
EU cloud (`eu.i.posthog.com`). Everything automatic in PostHog's SDK is turned
off. It uses cookieless mode, storing nothing in the browser. PostHog's servers
count daily visitors from a hash of IP address and user agent with a salt
discarded each day. Person profiles are off. Events go to a project shared with
`eavesbard.com` and `tlog.benbirt.io`, told apart by host. The project token in
`analytics.js` is public and can only send events.

A visit is not counted when the host is not `benbirt.io`, the browser is
automated (`navigator.webdriver`), Do Not Track is `"1"`, or Global Privacy
Control is on. In those cases PostHog's SDK is not fetched.

`posthog-js` is an npm dependency in [`package.json`](package.json) and
[`pnpm-lock.yaml`](pnpm-lock.yaml), fetched by Bazel through `aspect_rules_js`.
Install scripts are disabled in [`pnpm-workspace.yaml`](pnpm-workspace.yaml).
[`site/BUILD.bazel`](site/BUILD.bazel) copies `dist/module.no-external.js` to
`/posthog.js` with its licence at `/posthog-LICENSE.txt`. That file is about
440 kB. It is the one file in the package that needs no others and loads
nothing from PostHog's servers. The site needs no Node at run time and has no
other JavaScript build step. `bazel run //site:public` serves the source tree
without `/posthog.js`, which does not matter because previews are never
counted.

Dependabot ([`dependabot.yml`](.github/dependabot.yml)) opens weekly pull
requests for `posthog-js`. They are not merged automatically. To change the
version by hand, use the `pnpm` command in [`MODULE.bazel`](MODULE.bazel).

## DNS and email

The domain's DNS records and its email routing (`ben@benbirt.io`) are OpenTofu
configuration in [`infra/`](infra/), run through
[rules_tofu](https://github.com/benbirt/rules_tofu):

```sh
bazel build //infra    # validates the configuration; needs no credentials
infra/run.sh plan      # plans from termina, with the token from KDE Wallet
```

CI plans on pull requests that change `infra/` and applies on pushes to `main`
([`infra.yml`](.github/workflows/infra.yml)). State is in the Cloudflare R2
bucket `benbirt-io-tofu-state`.

One Cloudflare token serves all of it: an account-owned API token,
`benbirt-io-tofu` (Manage account > Account API tokens), with three policies:

| Scope                                 | Permissions                                                                                                                                                        |
| ------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| The `benbirt.io` zone                 | Zone: Read, Zone Settings: Edit (switching Email Routing on), DNS: Edit (records and DNSSEC), Email Routing Rules: Edit, Dynamic URL Redirects: Edit (redirect.tf) |
| The account                           | Email Routing Addresses: Edit                                                                                                                                      |
| The R2 bucket `benbirt-io-tofu-state` | Object Read & Write                                                                                                                                                |

The `cloudflare` provider uses the token as it is. For the state bucket,
[`tools/r2-keys.sh`](tools/r2-keys.sh) derives R2's S3 keys from it by
Cloudflare's rule (the access key ID is the token's ID, the secret the SHA-256
of the token), so there are no separate R2 keys to keep.

The token is the repository secret `CLOUDFLARE_API_TOKEN` (for Actions, and
again for Dependabot, for its provider updates). `infra/run.sh` reads it from
KDE Wallet, where this stores it:

```sh
nix shell nixpkgs#libsecret --command secret-tool store --label="Cloudflare benbirt-io-tofu" service cloudflare token benbirt-io-tofu
```
