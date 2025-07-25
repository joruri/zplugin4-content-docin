class Docin::Navi::ImportsService < Core::Navi::BaseService
  def call
    @navi.object_accessor = :current_filter
    @navi.nodes = build
    @navi.current_node_ids = detect_from_current_node_params
  end

  private

  def build
    [root_node]
  end

  def root_node
    Core::Navi::Node.new(
      id: root_id,
      title: 'インポート',
      link_url: { }
    )
  end
end
