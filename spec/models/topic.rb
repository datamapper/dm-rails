module Rails; module DataMapper; module Models
  class Topic
    include ::DataMapper::Resource
    include ::Rails::DataMapper::MultiparameterAttributes

    property :id, Serial
    property :last_read, Date
    property :written_on, Time
    property :updated_at, DateTime
  end
end; end; end
