class Zplugin::Content::Docin::FrontPolicy < ApplicationPolicy
  include Sys::Base::RootPolicy

  def install?
    true
  end

  def uninstall?
    true
  end
end
