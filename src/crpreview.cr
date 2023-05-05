require "./image"
require "./archive"

# Main module for all code parsing input, processing files or binding to libraries.
module Crpreview
  extend self

  if ARGV.size <= 0
    exit 1
  end

  file = ARGV[0]

  VERSION = "0.2.0"
  USAGE   = "usage: crpreview [-v|--version] [-h|--help] [file]"

  case file
  when "-h" || "--help"
    print USAGE
    exit
  when "-v" || "--version"
    puts "crpreview #{VERSION}"
    puts "Copyright (C) 2023 Rishab Garg"
    puts "Licensed under the EUPL-1.2"
    exit
  end

  if !File.exists?(file)
    puts "ERROR: File does not exist."
    puts USAGE
    exit 1
  end

  # Overrides for endings not covered by mime-type
  case file
  when /.tar.lrz$/
    print archive(file)
    exit
  when /.md$/
    # print `glow "#{file}"` -> Fix glow showing without colours
    print `bat -pp --color always --wrap character --  "#{file}"`
    exit
  end

  type = `file -b --mime-type "#{file}"`

  case type
  when /^image/ # Images
    print image(file)
  when /inode\/directory/ # Directories
    print `exa -a --color=always --group-directories-first --icons "#{file}"`
  when /x-tar$|x-7z-compressed$|zip$|x-bzip$|x-bzip2$|gzip$|x-xz$|zstd$|x-lzip$/ # Archives
    print archive(file)
  when /application\/pdf/ # PDFs
    print pdf(file)
  when /application\/octet-stream/ # Binaries
    print "binary data"
  else # Others (text, etc.)
    print `bat -pp --color always --wrap character -- "#{file}"`
  end
end
