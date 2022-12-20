# guiosoft-scripts

Automation scripts for every day

[![CodeQL](https://github.com/guionardo/guiosoft-scripts/actions/workflows/codeql-analysis.yml/badge.svg)](https://github.com/guionardo/guiosoft-scripts/actions/workflows/codeql-analysis.yml)
[![Shell Lint](https://github.com/guionardo/guiosoft-scripts/actions/workflows/shell.yml/badge.svg)](https://github.com/guionardo/guiosoft-scripts/actions/workflows/shell.yml)
[![Package Versions](https://github.com/guionardo/guiosoft-scripts/actions/workflows/package-versions.yml/badge.svg)](https://github.com/guionardo/guiosoft-scripts/actions/workflows/package-versions.yml)
[![New release](https://github.com/guionardo/guiosoft-scripts/actions/workflows/new_release.yml/badge.svg)](https://github.com/guionardo/guiosoft-scripts/actions/workflows/new_release.yml)

## Generic updater

Add this alias to your .bashrc (or equivalent)

```
alias update="bash <(curl -s https://raw.githubusercontent.com/guionardo/guiosoft-scripts/main/install.sh)"
```

You can run this:

```bash
update vscode
```


## Install (update) golang (for debian, ubuntu, etc)

```bash
bash <(curl -s https://raw.githubusercontent.com/guionardo/guiosoft-scripts/main/install_golang.sh)
```

![install-golang](docs/install_golang.gif)

## Install vscode

```bash
bash <(curl -s https://raw.githubusercontent.com/guionardo/guiosoft-scripts/main/install_vscode.sh)
```

## Install dbeaver

```bash
bash <(curl -s https://raw.githubusercontent.com/guionardo/guiosoft-scripts/main/install_dbeaver.sh)
```

## Software Versions

| Name | Version | Date | Release |
|------|---------|------|---------|
| vscode | 1.74.2 | 2022-12-20 | [November 2022 Recovery 2](https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64) |
| dbeaver | 22.3.0 | 2022-12-08 | [22.3.0](https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb) |
| golang | 1.19.4 | 2022-12-20 | [1.19.4](https://golang.org/dl/go1.19.4.linux-amd64.tar.gz) |

[versions.json updated @ 2022-12-20 20:08:28.726617](versions.json)
