class CreateZpluginContentDocinDocs < ActiveRecord::Migration[5.0]
  def change
    create_table :zplugin_content_docin_docs do |t|
      t.text :uri_path
      t.text :site_url
      t.text :title
      t.datetime :published_at
      t.text :body
      t.integer :content_id
      t.integer :docable_id
      t.string :docable_type
      t.text :doc_name
      t.text :doc_public_uri
      t.string :page_updated_at
      t.string :page_group_code
      t.string :page_published_at
      t.text :page_category_names
      t.index [:content_id], name: :index_zplugin_content_docin_docs_on_content_id
      t.index [:docable_id, :docable_type], name: :index_zplugin_content_docin_docs_on_docable_id_and_docable_type
      t.index [:uri_path], name: :index_zplugin_content_docin_docs_on_uri_path
      t.timestamps
    end
  end
end
