# TODO: Automated (complete) module typedefs
module Crpreview
  @[Link(ldflags: "`pkg-config --cflags --libs libarchive`")]
  lib LibArchive
    type Archive = Void
    type ArchiveEntry = Void

    enum ArchiveStatus
      ARCHIVE_EOF    =   1
      ARCHIVE_OK     =   0
      ARCHIVE_RETRY  = -10
      ARCHIVE_WARN   = -20
      ARCHIVE_FAILED = -25
      ARCHIVE_FATAL  = -30
    end

    fun archive_read_new : Archive*
    fun archive_read_free(a : Archive*) : ArchiveStatus

    fun archive_read_support_filter_all(Archive*) : ArchiveStatus
    fun archive_read_support_format_all(Archive*) : ArchiveStatus

    fun archive_read_open_filename(a : Archive*, filename : LibC::Char*, block_size : LibC::SizeT) : ArchiveStatus
    fun archive_read_next_header(a : Archive*, archive_entry : ArchiveEntry**) : ArchiveStatus

    fun archive_entry_pathname_utf8(ArchiveEntry*) : LibC::Char*
    fun archive_entry_size(e : ArchiveEntry*) : LibC::SizeT
    fun archive_entry_stat(e : ArchiveEntry*) : LibC::Stat*
  end
end
