class Zplugin::Content::Docin::Tool::Link
  HTML_FILE_EXTS = ["", ".htm", ".html", ".shtml", ".php", ".asp", ".jsp"]
  attr_accessor :cdoc, :tag, :attr, :url, :after_url,
                :filename, :title, :alt, :ext, :file_path,
                :message

  def url_changed?
    @url.to_s != @after_url.to_s
  end
end
