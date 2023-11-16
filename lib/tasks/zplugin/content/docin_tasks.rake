namespace :zplugin_content_docin do
  namespace :csv do
    desc "Import csv to GpArtcile::Doc"
    task :import => :environment do
      Docin::Content::Import.all.each do |content|
        next if content.setting.import_path.blank? || content.import_creator_user.blank?
        next unless File.exist?(content.setting.import_path)
        Docin::ImportJob.perform_later(content, user: content.import_creator_user, path: content.setting.import_path)
      end
    end
  end
end
