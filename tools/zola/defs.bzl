"""Rules for building a Zola site."""

def _zola_site_impl(ctx):
    out = ctx.actions.declare_directory(ctx.label.name)
    config_dir = ctx.file.config.dirname

    # Zola wants a real directory tree, so copy the sandbox's symlinks into one.
    ctx.actions.run_shell(
        outputs = [out],
        inputs = [ctx.file.config] + ctx.files.srcs,
        tools = [ctx.executable._zola],
        command = """
set -euo pipefail
root="$(mktemp -d)"
trap 'rm -rf "$root"' EXIT
cp -RL "{config_dir}/." "$root/"
"{zola}" --root "$root" build --force --output-dir "{out}"
""".format(
            config_dir = config_dir,
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
            root = config_dir,
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
