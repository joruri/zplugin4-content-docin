class Docin::Navi::ImportsService < Core::Navi::BaseService
  class Builder < Builder
    def nodes
      [root_node]
    end

    def root_node
      Core::Navi::Node.new(
        id: ROOT_ID,
        title: '記事取込',
        link_url: { current_node: ROOT_ID }
      )
    end
  end
end
