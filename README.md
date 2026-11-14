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

Bazel downloads the pinned Zola release; nothing else needs installing. A
weekly workflow ([`update-zola.yml`](.github/workflows/update-zola.yml)) opens
a pull request when Zola has a new release.

## Deploying

Every push to `main` builds the site and deploys it to GitHub Pages
([`pages.yml`](.github/workflows/pages.yml)).
