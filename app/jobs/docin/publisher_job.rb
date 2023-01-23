class Docin::PublisherJob < ApplicationJob
  queue_as :batch
  queue_with_priority 10

  def perform(doc)
    Cms::PublicateInteractor.call(item: doc)
  end
end
