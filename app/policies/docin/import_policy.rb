class Docin::ImportPolicy < ApplicationPolicy
  chain Cms::Chain::Designer::ContentPolicy
end
