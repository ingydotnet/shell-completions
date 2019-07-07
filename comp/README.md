This directory contains the specs for the CompleteShell completion framework.

See: https://github.com/complete-shell/complete-shell

To use these completions with CompleteShell, just run this command:
```
complete-shell config search-list + https://github.com/ingydotnet/shell-completions/blob/master/comp/complete-shell.tsv
```

For more details see:
https://github.com/complete-shell/complete-shell/wiki/Using-Third-Party-compdefs

## Rebuild Instructions

These .comp files are converted from the shell-completions `specs/*` files.

To regenerate them, run this from the top directory:
```
rm -f comp/*.comp comp/*.tsv
make comp
```

You will want to have the latest version of CompleteShell enabled to generate
the search index file.
