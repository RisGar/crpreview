require "./image"
require "./archive"

# Parses the input and forwards it to the correct previewer.
module Crpreview
  extend self
  include Archive
  include Image

  exit 1 if ARGV.size <= 0

  VERSION = "0.2.0"
  USAGE   = "usage: crpreview [-v|--version] [-h|--help] [FILE]"
  FILE    = ARGV[0]

  case FILE
  when "-h" || "--help"
    print USAGE
    exit
  when "-v" || "--version"
    puts "crpreview #{VERSION}"
    puts "Copyright (C) 2023 Rishab Garg"
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
    # print `glow "#{FILE}"` -> Fix glow showing without colours
    print `bat -pp --color always --wrap character --  "#{FILE}"`
    exit
  end

  type = `FILE -b --mime-type "#{FILE}"`

  case type
  when /^image/ # Images
    print image(FILE)
  when /inode\/directory/ # Directories
    print `exa -a --color=always --group-directories-first --icons "#{FILE}"`
  when /x-tar$|x-7z-compressed$|zip$|x-bzip$|x-bzip2$|gzip$|x-xz$|zstd$|x-lzip$/ # Archives
    print archive(FILE)
  when /application\/pdf/ # PDFs
    print pdf(FILE)
  when /application\/octet-stream/ # Binaries
    print "binary data"
  else # Others (text, etc.)
    print `bat -pp --color always --wrap character -- "#{FILE}"`
  end
end
