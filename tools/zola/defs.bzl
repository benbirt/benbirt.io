"""Rules for building a Zola site."""

def _zola_site_impl(ctx):
    out = ctx.actions.declare_directory(ctx.label.name)

    # The site root is the config's directory. Zola wants a real directory
    # tree, so each input is copied to its place under a temporary root.
    site_root = ctx.file.config.short_path.rpartition("/")[0]
    prefix = site_root + "/" if site_root else ""
    copies = ctx.actions.args()
    for f in [ctx.file.config] + ctx.files.srcs:
        if not f.short_path.startswith(prefix):
            fail("%s is not under the site root, %s" % (f.short_path, site_root or "the workspace root"))
        copies.add(f)
        copies.add(f.short_path[len(prefix):])

    ctx.actions.run_shell(
        outputs = [out],
        inputs = [ctx.file.config] + ctx.files.srcs,
        tools = [ctx.executable._zola],
        arguments = [copies],
        command = """
set -euo pipefail
root="$(mktemp -d)"
trap 'rm -rf "$root"' EXIT
while (($#)); do
  mkdir -p "$root/$(dirname "$2")"
  cp -L "$1" "$root/$2"
  shift 2
done
"{zola}" --root "$root" build --force --output-dir "{out}"
""".format(
            out = out.path,
            zola = ctx.executable._zola.path,
        ),
        mnemonic = "ZolaBuild",
        progress_message = "Building Zola site %{label}",
    )

    # `bazel run` previews the source tree, so that edits show up as they are
    # saved. Zola serves on port 1111, or on a free port if that one is taken,
    # and prints the address. Its copy of the static files goes to a temporary
    # directory, to keep it out of the source tree.
    serve = ctx.actions.declare_file(ctx.label.name + "_serve.sh")
    ctx.actions.write(
        output = serve,
        is_executable = True,
        content = """#!/usr/bin/env bash
set -euo pipefail
zola="$PWD/{zola}"
out="$(mktemp -d)"
trap 'rm -rf "$out"' EXIT
"$zola" --root "$BUILD_WORKSPACE_DIRECTORY/{root}" serve --force --output-dir "$out" "$@"
""".format(
            root = site_root or ".",
            zola = ctx.executable._zola_for_run.short_path,
        ),
    )

    return [DefaultInfo(
        files = depset([out]),
        executable = serve,
        runfiles = ctx.runfiles(files = [ctx.executable._zola_for_run]),
    )]

zola_site = rule(
    implementation = _zola_site_impl,
    doc = """Builds a Zola site into a directory of static files.

`bazel build` produces the directory. `bazel run` serves a live preview of
the source tree, which rebuilds as files change.
""",
    executable = True,
    attrs = {
        "config": attr.label(
            allow_single_file = [".toml"],
            mandatory = True,
            doc = "The site's config.toml. Its directory is the site root.",
        ),
        "srcs": attr.label_list(
            allow_files = True,
            doc = "Everything else under the site root: content, templates, static files.",
        ),
        "_zola": attr.label(
            default = "//tools/zola",
            executable = True,
            cfg = "exec",
            allow_single_file = True,
        ),
        "_zola_for_run": attr.label(
            default = "//tools/zola",
            executable = True,
            cfg = "target",
            allow_single_file = True,
        ),
    },
)
