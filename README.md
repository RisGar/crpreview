# crpreview

Preview script made for the [lf file manager](https://github.com/gokcehan/lf). May work with other terminal file manageres after some configuration.

## Previews

| File type    | Tool               |
| ------------ | ------------------ |
| archives[^1] | `tar (libarchive)` |
| markdown     | `glow`             |
| images       | `chafa`            |
| pdf          | `pdftoppm`         |
| text         | `bat`              |

[^1]: Supported formats: `tar`, `7-zip`, `zip`, `bzip`,`bzip2`, `gunzip`, `xz`, `zstd`, `lzip`, `lrzip`

## Requirements

- \*nix sytem or WSL2

## Installation

1. Build the executable using `make``
2. Copy the path to this working directory on your system`

## Usage

Add the following lines to your `lfrc`:

```conf
set previewer /path/to/crpreview/bin/crpreview
map i $ /path/to/crpreview/bin/crpreview $f | less -R
```

## Development

### Required C Libraries

- chafa
- imagemagick
- glib2

## Contributing

1. Fork it (<https://github.com/your-github-user/crpreview/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Rishab Garg](https://github.com/your-github-user) - creator and maintainer

## Special Thanks To

- [GuardKenzie](https://github.com/GuardKenzie) - Maintainer of [chafa.py](https://github.com/GuardKenzie/chafa.py), which my `MagickWand` bindings are based on
