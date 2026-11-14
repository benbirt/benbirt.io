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
    return [DefaultInfo(files = depset([out]))]

zola_site = rule(
    implementation = _zola_site_impl,
    doc = "Builds a Zola site into a directory of static files.",
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
    },
)

def _zola_serve_impl(ctx):
    launcher = ctx.actions.declare_file(ctx.label.name + ".sh")
    ctx.actions.write(
        output = launcher,
        is_executable = True,
        content = """#!/usr/bin/env bash
set -euo pipefail
exec "{zola}" --root "$BUILD_WORKSPACE_DIRECTORY/{package}" serve "$@"
""".format(
            package = ctx.label.package,
            zola = ctx.executable._zola.short_path,
        ),
    )
    return [DefaultInfo(
        executable = launcher,
        runfiles = ctx.runfiles(files = [ctx.executable._zola]),
    )]

zola_serve = rule(
    implementation = _zola_serve_impl,
    doc = "Serves this package's Zola site from the source tree, rebuilding on change.",
    executable = True,
    attrs = {
        "_zola": attr.label(
            default = "//tools/zola",
            executable = True,
            cfg = "target",
            allow_single_file = True,
        ),
    },
)
