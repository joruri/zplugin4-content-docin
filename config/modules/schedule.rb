every :day, at: '0:00 am' do
  rake "#{Zplugin::Content::Docin::Engine.engine_name}:csv:import"
end
