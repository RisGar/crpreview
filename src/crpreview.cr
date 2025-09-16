require "./modules/image"
require "./modules/archive"

# Parses the input and forwards it to the correct previewer.
module Crpreview
  extend self
  include Archive
  include Image

  if ARGV.size == 0
    print `eza -aF1 --color=always --group-directories-first --icons`
    exit
  end

  VERSION = "0.2.0"
  USAGE   = "usage: crpreview [-v|--version] [-h|--help] [ |FILE]"
  FILE    = ARGV[0]

  case FILE
  when "-h" || "--help"
    print USAGE
    exit
  when "-v" || "--version"
    puts "crpreview #{VERSION}"
    puts "Copyright (C) #{Time.utc.year} Rishab Garg"
    puts "Licensed under the EUPL-1.2"
    exit
  end

  if !File.exists?(FILE)
    puts "ERROR: File does not exist."
    puts USAGE

    exit 1
  end

  # Overrides for endings not covered by mime-type
  case FILE
  when /.tar.lrz$/
    print archive(FILE)
    exit
  when /.md$/
    print `bat -pp --color always --wrap character -- "#{FILE}"`
    exit
  end

  type = `file -b --mime-type "#{FILE}"`

  case type
  when /inode\/directory/ # Directories
    print `eza -aF1 --color=always --group-directories-first --icons "#{FILE}"`
  when /^image/ # Images
    print image(FILE)
  when /x-tar$|x-7z-compressed$|zip$|x-bzip$|x-bzip2$|gzip$|x-xz$|zstd$|x-lzip$/ # Archives
    print archive(FILE)
  when /application\/pdf/, /^video/ # pdfs & videos
    print ql(FILE)
  when /application\/octet-stream/ # binaries
    print `hexdump -C #{FILE}`
  when /inode\/x-empty/
    print "Empty file"
  else # Others (text, etc.)
    print type
    print `bat -pp --color always --wrap character -- "#{FILE}"`
  end
end # TODO: clear old cache files
