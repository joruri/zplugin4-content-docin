namespace :zplugin_content_docin do
  namespace :csv do
    desc "Import csv to GpArtcile::Doc(CONTENT_ID=int)"
    task :import => :environment do
      contents = ENV['CONTENT_ID'].present? ? Docin::Content::Import.where(id: ENV['CONTENT_ID']) : Docin::Content::Import
      contents.all.each do |content|
        next if content.setting.import_path.blank? || content.import_creator_user.blank?
        next unless content.daily_import?
        next unless File.exist?(content.setting.import_path)
        Docin::ImportJob.perform_later(content, user: content.import_creator_user, path: content.setting.import_path)
      end
    end

    desc "Import csv to GpArtcile::Doc(once)(CONTENT_ID=int)"
    task :import_once => :environment do
      contents = ENV['CONTENT_ID'].present? ? Docin::Content::Import.where(id: ENV['CONTENT_ID']) : Docin::Content::Import
      contents.all.each do |content|
        next if content.setting.import_path.blank? || content.import_creator_user.blank?
        next unless File.exist?(content.setting.import_path)
        Docin::ImportJob.perform_later(content, user: content.import_creator_user, path: content.setting.import_path)
      end
    end

  end
end
