class Docin::ImportPolicy < ApplicationPolicy
  chain Cms::Coactors::Designer::ContentPolicy
end
