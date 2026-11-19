+++
+++

# Ben Birt

I'm a software engineer in London. I've spent over fifteen years building
infrastructure, mostly at Google, with a spell in between as head of
engineering at Dataform, a data engineering startup acquired by Google Cloud
in 2020. I now work on privacy engineering at Google DeepMind.

I'm most interested in systems that enforce transparency, reproducibility and
hermeticity: systems that don't need implicit trust, but whose claims are
falsifiable.

[ben@benbirt.io](mailto:ben@benbirt.io) ·
[GitHub](https://github.com/benbirt) ·
[LinkedIn](https://www.linkedin.com/in/ben-birt)

<!-- blog -->

## Transparency

### Private AI Compute transparency log

I designed and launched the binary transparency log behind Google's Private AI
Compute, including its use of third-party witnesses. The log and witnesses
conform to [C2SP](https://c2sp.org/) specifications such as
[tlog-tiles](https://c2sp.org/tlog-tiles) and
[tlog-witness](https://c2sp.org/tlog-witness). I also contribute to C2SP and
wrote [tlog-list](https://c2sp.org/tlog-list).

I delivered [a talk](https://youtu.be/cloZmGllJSg) at the
[2026 transparency.dev summit](https://transparency.dev/summit2026/), covering
Google's transparency log witnessing programme.

### git-ratchet

git-ratchet enforces forward-only protection for Git branches and immutability
for tags. The repository contains a transparency log mapping branches and tags
to commits, so rewritten history cannot be hidden from a downstream verifier.

I delivered [a talk](https://youtu.be/DR0x9t9jzLU) on it at the
[2026 transparency.dev summit](https://transparency.dev/summit2026/)
([slides](https://project-oak.github.io/git-ratchet/transparency-dev-summit-2026.html)).

- [Code](https://github.com/project-oak/git-ratchet)

### git-witness

A witness for git-ratchet logs. It uses the standard C2SP
[tlog-witness](https://c2sp.org/tlog-witness) protocol, with GitHub issues as
the underlying HTTP transport.

- [Code](https://github.com/benbirt/git-witness)

### tlog-viewer

A static transparency log viewer which performs cryptographic verification in
the browser.

- [Open it](https://benbirt.github.io/tlog-viewer/)
- [Code](https://github.com/benbirt/tlog-viewer)

## Reproducible builds

### rules_tofu

Bazel rules for OpenTofu. Configuration becomes ordinary build targets:
`bazel build` validates it, `bazel test` runs `tofu test`, and `bazel run`
plans and applies it. Bazel pins and fetches providers and the `tofu` binary.

- [Code](https://github.com/benbirt/rules_tofu)
- [Bazel Central Registry](https://registry.bazel.build/modules/rules_tofu)

### song-of-time

A fully reproducible Nix configuration for my NixOS and macOS machines. It
includes home-grown tools, such as automated deployment of configuration
pulled directly from GitHub, with health checks.

- Private for now

## Data tooling

### Dataform

An open-source framework for managing SQL data pipelines in BigQuery. I led
engineering at the startup and continued as technical lead after Google Cloud
acquired it.

- [Code](https://github.com/dataform-co/dataform)

## Other

### Eavesbard

Hands-off ambient music for tabletop role-playing sessions.

- [Open it](https://eavesbard.com/)
- [Code](https://github.com/benbirt/eavesbard)

### Flip 7 Scorecard

A scorecard for the card game Flip 7, with a couple of fun extras.

- [Open it](https://flip7.benbirt.io/)
- [Code](https://github.com/benbirt/flip7-scorecard)

### The Hollow Isle

A top-down action game that runs in the browser, inspired by my love of the
Zelda series.

- [Play it](https://benbirt.github.io/2dRPG/)
- [Code](https://github.com/benbirt/2dRPG)
