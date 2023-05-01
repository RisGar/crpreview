require "./clibs/archive"

module Crpreview
  class Archive
    alias Status = LibArchive::ArchiveStatus

    getter archive : LibArchive::Archive*
    getter archive_entry : LibArchive::ArchiveEntry*

    def initialize(filename : String)
      @archive = LibArchive.archive_read_new
      @archive_entry = uninitialized LibArchive::ArchiveEntry*

      LibArchive.archive_read_support_filter_all(@archive)
      LibArchive.archive_read_support_format_all(@archive)

      r = LibArchive.archive_read_open_filename(@archive, filename.to_unsafe, 10240) # TODO: blocksize?
      raise "ERROR: Couldn't open specified archive" if r != Status::ARCHIVE_OK
    end

    def print : String
      string = ""
      while LibArchive.archive_read_next_header(@archive, pointerof(@archive_entry)) == Status::ARCHIVE_OK
        string = string + String.new(LibArchive.archive_entry_pathname_utf8(@archive_entry)) + "\n"
      end
      string
    end

    def close : Void
      LibArchive.archive_read_free(@archive)
    end
  end
end
