+++
+++

# Ben Birt

I'm a software engineer in London. I've spent more than fifteen years building
infrastructure: mostly at Google, with a spell in between as head of
engineering at Dataform, a data engineering startup that Google Cloud acquired
in 2020. I now work on privacy engineering at Google DeepMind.

I'm most interested in systems that enforce transparency, reproducibility and
hermeticity: systems that don't need implicit trust, but whose claims are
falsifiable.

[ben@benbirt.io](mailto:ben@benbirt.io) ·
[GitHub](https://github.com/benbirt) ·
[LinkedIn](https://www.linkedin.com/in/ben-birt)

## Transparency

### Private AI Compute transparency log

I designed and launched the binary transparency log behind Google's Private AI
Compute, including its use of third-party witnesses. The log and its witnesses
conform to the [C2SP](https://c2sp.org/) specifications, such as
[tlog-tiles](https://c2sp.org/tlog-tiles) and
[tlog-witness](https://c2sp.org/tlog-witness), and I contribute to those
specifications: I wrote [tlog-list](https://c2sp.org/tlog-list).

I delivered [a talk](https://youtu.be/cloZmGllJSg) at the
[2026 transparency.dev summit](https://transparency.dev/summit2026/), covering
Google's transparency log witnessing programme.

### git-ratchet

git-ratchet enforces forward-only protection for Git branches and immutability
for Git tags. The protected repository contains a transparency log whose
entries map branches and tags to commits, so rewritten history cannot be
hidden from a downstream verifier of the repository.

I delivered [a talk](https://youtu.be/DR0x9t9jzLU) at the
[2026 transparency.dev summit](https://transparency.dev/summit2026/). (Slides
available [here](https://project-oak.github.io/git-ratchet/transparency-dev-summit-2026.html).)

- [Code](https://github.com/project-oak/git-ratchet)

### git-witness

A witness for git-ratchet logs. It uses the standard C2SP
[tlog-witness](https://c2sp.org/tlog-witness) protocol, but uses GitHub issues
as the underlying HTTP transport.

- [Code](https://github.com/benbirt/git-witness)

### tlog-viewer

A static transparency log viewer which performs cryptographic verification in
the browser.

- [Open it](https://benbirt.github.io/tlog-viewer/)
- [Code](https://github.com/benbirt/tlog-viewer)

## Reproducible builds

### rules_tofu

Bazel rules for OpenTofu. Configuration becomes ordinary build targets:
building validates it, testing runs its `tofu test` tests, and running plans
and applies it, with providers and the `tofu` binary pinned and fetched by
Bazel.

- [Code](https://github.com/benbirt/rules_tofu)
- [Bazel Central Registry](https://registry.bazel.build/modules/rules_tofu)

### song-of-time

A fully reproducible Nix configuration for my own machines, covering both
NixOS and macOS. It includes various home-grown tools, such as automated
deployment of new configuration pulled directly from GitHub, with built-in
health checks.

- Private for now.

## Data tooling

### Dataform

An open-source framework for managing SQL data pipelines in BigQuery. I led
engineering at the Dataform startup, and continued as technical lead after
Dataform was acquired by Google Cloud.

- [Code](https://github.com/dataform-co/dataform)

## Other

### Eavesbard

Hands-off ambient music for tabletop role-playing sessions.

- [Open it](https://eavesbard.com/)
- [Code](https://github.com/benbirt/eavesbard)

### The Hollow Isle

A top-down action game that runs in the browser, inspired by my love of the
Zelda series.

- [Play it](https://benbirt.github.io/2dRPG/)
- [Code](https://github.com/benbirt/2dRPG)
