class Docin::ExportCsvJob < ApplicationJob
  def perform(content)
    arel_table = Zplugin::Content::Docin::Doc.arel_table
    items = Zplugin::Content::Docin::Doc
      .in_site(content.site)
      .select(:title, :uri_path, :doc_public_uri, :content_id, :docable_type, :docable_id, :doc_name)
      .where(docable_type: "GpArticle::Doc")
    csv = Docin::Export::DocsInteractor.call(items: items).result
    Util::File.put(content.export_csv_path, data: csv, mkdir: true)
  end
end