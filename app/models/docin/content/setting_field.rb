class Docin::Content::SettingField < Cms::Content::SettingField

  menu :gp_article_relation do
    add_item :gp_article_content_id, :select
    add_item :body_template, :text_area
    add_item :summary_template, :text_area
    add_item :default_state, :radio
  end

  menu :columns do
    add_item :doc_name, :text
    add_item :doc_state, :text
    add_item :title, :text
    add_item :feature_1, :text
    add_item :feed_state, :text
    add_item :display_published_at, :text
    add_item :display_updated_at, :text
    add_item :task_publish_process_at, :text
    add_item :task_close_process_at, :text
    add_item :inquiry_state, :text
    add_item :event_state, :text
    add_item :event_period, :text
    add_item :event_note, :text
    add_item :event_category, :text
    add_item :marker_state, :text
    add_item :marker_sort_no, :text
    add_item :marker_category, :text
    add_item :map_title, :text
    add_item :map_coordinate, :text
    add_item :map_zoom, :text
    add_item :map_marker, :text
    add_item :file_path, :text
    add_item :file_name, :text
    add_item :file_title, :text
    add_item :file_alt_text, :text
    add_item :file_image_resize, :text
    add_item :creator_group_code, :text
    add_item :creator_group_name, :text
    add_item :creator_user_code, :text
    add_item :creator_user_name, :text
  end

  menu :gp_template_relation do
  end

  menu :import do
    add_item :daily_import, :radio
    add_item :auto_closure, :radio
    add_item :import_path, :text
    add_item :import_user_id, :select
    add_item :column_replace, :text_area, lower_text: '対象カラム,値,変換先'
    add_item :category_relation, :text_area, lower_text: '対象カラム,カテゴリ種別'
    add_item :category_relation_type, :radio
    add_item :status_relation, :text_area, lower_text: '値,変換先'
    add_item :attachement_column, :text
    add_item :attachement_directory, :text
    add_item :attachement_directory_import, :radio
    add_item :category_column_regexp, :text
    add_item :uri_base, :text
    add_item :list_image, :text
    add_item :file_doc_id_regexp, :text
  end

end
