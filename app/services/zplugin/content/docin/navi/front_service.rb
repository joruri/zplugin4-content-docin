class Zplugin::Content::Docin::Navi::FrontService < Core::Navi::BaseService
  class Builder < Builder
    def nodes
      [root_node]
    end

    def root_node
      Core::Navi::Node.new(
        id: ROOT_ID,
        title: @plugin.title,
        link_url: { action: :index }
      )
    end
  end
end
