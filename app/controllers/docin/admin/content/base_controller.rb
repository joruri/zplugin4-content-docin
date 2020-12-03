class Docin::Admin::Content::BaseController < Cms::Admin::Content::BaseController
  def model
    Docin::Content::Import
  end
end
