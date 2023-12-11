def _tree_artifact_impl(ctx):
    directory = ctx.actions.declare_directory(ctx.attr.name + "_tree")

    ctx.actions.run_shell(
        inputs = [],
        outputs = [directory],
        command = """
for i in {{1..{size}}}; do
  echo 'Dummy Content $i' > {path}/dummy_file_$i
done
""".format(
            size = ctx.attr.size,
            path = directory.path,
        ),
    )

    if ctx.attr.runfiles_only:
        runfiles = ctx.runfiles(files = [directory])
        return [
            DefaultInfo(
                runfiles = runfiles,
            ),
        ]

    return [
        DefaultInfo(
            files = depset([directory]),
        ),
    ]

tree_artifact = rule(
    implementation = _tree_artifact_impl,
    attrs = {
        "size": attr.int(),
        "runfiles_only": attr.bool(),
    },
)

def tree_test(name, directories, files_per_directory, runfiles_only = False):
    data = []
    for i in range(directories):
        tree_name = "%s_%s" % (name, i)
        tree_artifact(name = tree_name, size = files_per_directory, runfiles_only = runfiles_only)
        data.append(tree_name)

    native.sh_test(name = name, data = data, srcs = [":test.sh"])
