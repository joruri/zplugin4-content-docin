class Zplugin::Content::Docin::Tool::LinkProcessor
  attr_reader :body, :after_body, :clinks

  def initialize(content)
    @content = content
    @site = content.site
  end

  def list_image(doc)
    return self if doc.list_image.blank?
    filename = doc.list_image
    file = doc.files.find_by(title: filename)
    if file.present?
      doc.update_columns(list_image: file.name)
    end
    return self
  end

  def sublink(cdoc)
    @body = cdoc.body.dup
    @after_body = cdoc.body.dup
    @clinks = []
    site_url = cdoc.site_url
    #host = cdoc.site_url.split('/')[0]

    html = Nokogiri::HTML.fragment(@body)
    html.xpath("./a[@href]|.//a[@href]|./area[@href]|.//area[@href]|./img[@src]|.//img[@src]").each do |e|
      clink = Zplugin::Content::Docin::Tool::Link.new
      clink.cdoc = cdoc
      clink.tag = e.name
      clink.attr = ['a', 'area'].include?(e.name) ? 'href' : 'src'
      clink.title = e.inner_text.presence || e['title']
      clink.alt = e['alt']
      clink.url = e[clink.attr].to_s.dup
      clink.after_url = clink.url.dup

      url = clink.url
      next if url.blank?

      uri = normalize_url(url)
      next if uri.blank?
      #next if uri.host != host

      extname = File.extname(uri.path).downcase
      extname = '' if extname !~ /\A\.[0-9a-z]+\z/

      if extname.in?(Zplugin::Content::Docin::Tool::Link::HTML_FILE_EXTS)
        convert_doc_link(uri, clink)
      elsif extname.present?
        convert_file_link(cdoc, uri, clink)
      end

      if clink.url_changed?
        @clinks << clink
        e[clink.attr] = clink.after_url
        e['class'] = "iconFile icon#{clink.ext.capitalize}" if clink.tag == 'a' && clink.filename.present?
        e['onclick'] = e['onclick'].to_s.dup.gsub(clink.url, clink.after_url) if e.attributes['onclick']
      end
    end

    html.xpath("./img[@srcset]|.//img[@srcset]|./source[@srcset]|.//source[@srcset]").each do |e|
      next if e['srcset'].blank?

      urls = e['srcset'].to_s.dup
      urls.split(',').each do |src|
        clink = Zplugin::Content::Docin::Tool::Link.new
        clink.cdoc = cdoc
        clink.tag = e.name
        clink.attr = 'srcset'
        clink.title = e.inner_text.presence || e['title']
        clink.alt = e['alt']
        clink.url = src.strip.split(' ')[0]
        clink.after_url = clink.url.dup

        url = clink.url
        next if url.blank?

        uri = normalize_url(url)
        next if uri.blank?
        #next if uri.host != host

        convert_file_link(uri, clink)

        if clink.url_changed?
          @clinks << clink
          e['srcset'] = e['srcset'].gsub(clink.url, clink.after_url)
        end
      end
    end

    doc = cdoc.latest_doc
    return self unless doc

    processed_file_ids = []

    doc.body = @after_body = html.inner_html

    doc.keep_display_updated_at = true
    doc.in_ignore_accessibility_check = '1'
    doc.in_ignore_link_check = '1'
    GpArticle::Doc.record_timestamps = false
    unless doc.save
      #
    end
    GpArticle::Doc.record_timestamps = true

    return self
  end

private

  def normalize_url(url)
    uri = Addressable::URI.parse(url)
    uri.path = '/' unless uri.path
    uri
  rescue => e
    warn_log e
    nil
  end

  def convert_doc_link(uri, clink)
    #return if uri.scheme == 'http' || uri.scheme == 'https'
    query = uri.query.present? ? "?#{uri.query}" : ""
    path = "#{uri.path}#{query}"
    #escaped_path = Addressable::URI.unescape("#{uri.host}#{uri.path}")
    # 他記事へのリンク
    linked_cdoc = Zplugin::Content::Docin::Doc.in_site(@site).where(uri_path: path).first
    # 他記事へのリンク(index.html補完)
    if !linked_cdoc && uri.path[-1] == '/'
      linked_cdoc = Zplugin::Content::Docin::Doc.in_site(@site).where(uri_path: "#{path}index.html").first
    end
    # 他記事へのリンク(.html補完)
    if !linked_cdoc && (!uri.path.include?('.') || uri.path[-4..-1] == '.htm' )
      linked_cdoc = Zplugin::Content::Docin::Doc.in_site(@site).where(uri_path: "#{path}.html").first
    end

    if linked_cdoc
      clink.after_url = linked_cdoc.doc_public_uri
      clink.after_url += '#' + uri.fragment if uri.fragment
    end
  rescue => e
    warn_log e
  end

  def convert_file_link(cdoc, uri, clink)
    filename = File.basename(uri.path)
    denc_filename = Addressable::URI.unescape(filename)
    doc = cdoc.latest_doc
    return if doc.blank?
    file = doc.files.find_by(title: denc_filename)
    if file.present?
      clink.after_url = "file_contents/#{file.name}"
    else
      if @content.setting.file_doc_id_regexp.present?
        doc_id = uri.path.to_s.gsub(/#{@content.file_doc_id_regexp}/, '\1')
        return if doc_id.blank?
        other_doc = doc.content.docs.find_by(name: doc_id)
        return if other_doc.blank?
        file = other_doc.files.find_by(title: denc_filename)
        if file.present?
          clink.after_url = "#{other_doc.public_uri}file_contents/#{file.name}"
        end
      end
    end
  end

end
