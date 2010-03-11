module Rails
  module DataMapper

    module I18nSupport
      # Set the i18n scope to overwrite ActiveModel.
      def i18n_scope #:nodoc:
        :data_mapper
      end
    end

  end
end
