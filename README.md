# crpreview

[![GH Build](https://github.com/RisGar/crpreview/actions/workflows/make.yml/badge.svg)](https://github.com/RisGar/crpreview/actions/workflows/make.yml) [![Cirrus CI Build](https://api.cirrus-ci.com/github/RisGar/crpreview.svg?task=FreeBSD)](https://cirrus-ci.com/github/RisGar/crpreview/master)

Previews files and directories in the terminal. Built work with the [lf file manager](https://github.com/gokcehan/lf).

## Features

`crpreview` can preview the following formats:

| File type    | Tool         |
| ------------ | ------------ |
| archives[^1] | `libarchive` |
| markdown     | `glow`       |
| images       | `chafa`      |
| pdf          | `qlmanage`   |
| text         | `bat`        |
| directories  | `eza`        |

[^1]: Supported formats: `tar`, `7-zip`, `zip`, `bzip`, `bzip2`, `gunzip`, `xz`, `zstd`, `lzip`, `lrzip`

## Requirements

All of the above mentioned preview tools which you want to use.

## Installation

### MacOS

Install directly from my brew tap:

```console
$ brew install RisGar/tap/crpreview
```

## Usage

Add the following lines to your `lfrc`:

```conf
set previewer /path/to/crpreview/bin/crpreview
map i $ /path/to/crpreview/bin/crpreview $f | less -R
```

Make sure to install the required decompressors for `libarchive` to list archive contents.

## Contributing

1. Fork it (<https://github.com/RisGar/crpreview/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Rishab Garg](https://github.com/RisGar) - creator and maintainer
