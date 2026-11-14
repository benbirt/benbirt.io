# benbirt.io

The source of [benbirt.io](https://benbirt.io): a one-page static site, built
by [Zola](https://www.getzola.org/) under Bazel and served by GitHub Pages.

## Editing

The copy is Markdown, in [`site/content/_index.md`](site/content/_index.md).
The page's HTML frame is [`site/templates/index.html`](site/templates/index.html)
and its styling is [`site/static/style.css`](site/static/style.css).

Under each project heading, the first paragraph is the description and the
second is the line of links.

## Building

```sh
bazel build //site:public   # the site, in bazel-bin/site/public
bazel run //site:serve      # live preview at http://127.0.0.1:1111
```

Bazel downloads the pinned Zola release; nothing else needs installing. To
update Zola, see the comment in [`MODULE.bazel`](MODULE.bazel).

## Deploying

Every push to `main` builds the site and deploys it to GitHub Pages
([`pages.yml`](.github/workflows/pages.yml)).

## Follow-ups

1. Send mail as `ben@benbirt.io` from Gmail (receiving is forwarded by
   Cloudflare Email Routing; sending needs its own setup).
2. A writing section.
