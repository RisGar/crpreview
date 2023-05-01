# crpreview

[![GH Build](https://github.com/RisGar/crpreview/actions/workflows/make.yml/badge.svg)](https://github.com/RisGar/crpreview/actions/workflows/make.yml) [![Cirrus CI Build](https://api.cirrus-ci.com/github/RisGar/crpreview.svg?task=FreeBSD)](https://cirrus-ci.com/github/RisGar/crpreview/master)

Preview script for the [lf file manager](https://github.com/gokcehan/lf) and the terminal.

## Features

`crpreview` can preview files of the following formats:

| File type    | Tool                    |
| ------------ | ----------------------- |
| archives[^1] | `tar (libarchive)`      |
| markdown     | `glow`                  |
| images       | `chafa` + `imagemagick` |
| pdf          | `pdftoppm`              |
| text         | `bat`                   |

[^1]: Supported formats: `tar`, `7-zip`, `zip`, `bzip`,`bzip2`, `gunzip`, `xz`, `zstd`, `lzip`, `lrzip`

## Requirements

Any of the above mentioned preview tools you wish to use.

## Installation

### MacOS

Install directly from my brew tap:

```console
$ brew install RisGar/tap/crpreview
```

### FreeBSD

Install the dependencies:

```console
$ pkg install crystal shards chafa imagemagick7 libarchive
```

Download the [lastest FreeBSD build archive from Cirrus CI](https://api.cirrus-ci.com/v1/artifact/github/RisGar/crpreview/FreeBSD/bin.zip) and add it to a directory in your `$PATH`.

### Ubuntu

Install the dependencies:

```console
$ sudo apt-get install libchafa-dev libmagickwand-dev libarchive-dev
```

Download the [lastest Ubuntu build archive from GitHub](https://nightly.link/RisGar/crpreview/workflows/make/master) and add it to a directory in your `$PATH`.

### From source (Other Unix systems)

1. Build the executable using `make``
2. Copy the path to this working directory on your system`
3. Install `libchafa`, `libmagickwand`, and `libarchive` and ensure `$CC` or `pkg-config` can access them.

## Usage

Add the following lines to your `lfrc`:

```conf
set previewer /path/to/crpreview/bin/crpreview
map i $ /path/to/crpreview/bin/crpreview $f | less -R
```

Make sure to install the required decompressors for `libarchive` to list archive contents.

## Development

### Required Libraries

- chafa
- imagemagick (MagickWand)
- glib2

## Contributing

1. Fork it (<https://github.com/your-github-user/crpreview/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Rishab Garg](https://github.com/your-github-user) - creator and maintainer
