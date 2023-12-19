every :day, at: '4:00 am' do
  rake "#{Zplugin::Content::Docin::Engine.engine_name}:csv:import"
end
