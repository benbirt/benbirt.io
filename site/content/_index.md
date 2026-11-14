+++
+++

# Ben Birt

I'm a software engineer in London. I've spent more than fifteen years building
infrastructure: mostly at Google, with a spell in between as head of
engineering at Dataform, a data startup that Google Cloud acquired in 2020.
I now work on privacy engineering at Google DeepMind.

What interests me most is building systems whose claims you can check and
don't have to take on trust: transparency logs, reproducible builds and
hermetic tooling.

[ben@benbirt.io](mailto:ben@benbirt.io) ·
[GitHub](https://github.com/benbirt) ·
[LinkedIn](https://www.linkedin.com/in/ben-birt)

## Transparency

### Private AI Compute transparency log

I designed and launched the binary transparency log behind Google's Private AI
Compute, including its use of third-party witnesses. The talk covers Google's
transparency log witnessing programme.

[Talk](https://youtu.be/cloZmGllJSg)

### git-ratchet

Forward-only protection for Git branches and tags. Each repository carries its
own transparency log, so rewritten history and moved tags cannot be hidden
afterwards.

[Code](https://github.com/project-oak/git-ratchet) ·
[Talk](https://youtu.be/DR0x9t9jzLU) ·
[Slides](https://project-oak.github.io/git-ratchet/transparency-dev-summit-2026.html)

### git-witness

A witness for git-ratchet logs that runs entirely on GitHub. Checkpoints
arrive as issues and cosignatures go back as comments, speaking the standard
C2SP tlog-witness protocol.

[Code](https://github.com/benbirt/git-witness)

### tlog-viewer

A static viewer for transparency logs that verifies what it shows, in the
browser.

[Open it](https://benbirt.github.io/tlog-viewer/) ·
[Code](https://github.com/benbirt/tlog-viewer)

## Reproducible builds

### rules_tofu

Bazel rules for OpenTofu. Configuration becomes ordinary build targets:
building validates it, testing runs its `tofu test` tests, and running plans
and applies it, with providers and the `tofu` binary pinned and fetched by
Bazel.

[Code](https://github.com/benbirt/rules_tofu) ·
[Bazel Central Registry](https://registry.bazel.build/modules/rules_tofu)

### song-of-time

A fully reproducible Nix configuration for my own machines, covering both
NixOS and macOS.

Private for now.

## Data tooling

### Dataform

An open-source framework for managing SQL data pipelines in BigQuery. I led
its engineering at the startup, and then at Google Cloud after the
acquisition.

[Code](https://github.com/dataform-co/dataform)

## Other

### Eavesbard

Hands-off ambient music for tabletop role-playing sessions.

[Open it](https://eavesbard.com/) ·
[Code](https://github.com/benbirt/eavesbard)

### The Hollow Isle

A Zelda-like top-down action game that runs in the browser.

[Play it](https://benbirt.github.io/2dRPG/) ·
[Code](https://github.com/benbirt/2dRPG)
