# guiosoft-scripts

Automation scripts for every day

[![CodeQL](https://github.com/guionardo/guiosoft-scripts/actions/workflows/codeql-analysis.yml/badge.svg)](https://github.com/guionardo/guiosoft-scripts/actions/workflows/codeql-analysis.yml)
[![Shell Lint](https://github.com/guionardo/guiosoft-scripts/actions/workflows/shell.yml/badge.svg)](https://github.com/guionardo/guiosoft-scripts/actions/workflows/shell.yml)
[![New release](https://github.com/guionardo/guiosoft-scripts/actions/workflows/new_release.yml/badge.svg)](https://github.com/guionardo/guiosoft-scripts/actions/workflows/new_release.yml)

## Generic updater

Add this aliases to your .bashrc (or equivalent)

```
alias update="curl -s https://raw.githubusercontent.com/guionardo/guiosoft-scripts/main/install.sh | sudo bash -s"
alias sudo="sudo "
```

You can run this:

```bash
update vscode
```

![vscode](docs/vscode.gif)


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
| vscode | 1.74.3 | 2023-01-10 | [November 2022 Recovery 3](https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64) |
| dbeaver | 22.3.2 | 2023-01-08 | [22.3.2](https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb) |
| golang | 1.19.5 | 2023-01-22 | [1.19.5](https://golang.org/dl/go1.19.5.linux-amd64.tar.gz) |

[versions.json updated @ 2023-01-22 12:48:04.606053](versions.json)
