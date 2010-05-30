module LogListener
  def log(message)
    ActiveSupport::Notifications.instrument('sql.data_mapper',
      :name          => 'SQL',
      :sql           => message.query, # TODO think about changing the key to :query
      :start         => message.start,
      :duration      => message.duration,
      :connection_id => self.object_id
    )
    super
  rescue Exception => e
    ::DataMapper.logger.error "[datamapper] #{e.class.name}: #{e.message}: #{message.inspect}}"
  end
end
