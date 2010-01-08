migration <%= migration_number.to_i %>, :<%= migration_file_name %> do
  up do
    create_table :<%= table_name %> do
      column :id, Serial
<% property_attributes.each do |attribute| -%>
      column :<%= attribute.name %>, <%= attribute.type.to_s.classify %>
<% end -%>
<% reference_attributes.each do |attribute| -%>
      column :<%= attribute.name %>_id, Integer
<% end -%>
<% if options[:timestamps] %>
      column :created_at, DateTime
      column :updated_at, DateTime
<% end -%>
    end
  end

  down do
    drop_table :<%= table_name %>
  end
end
