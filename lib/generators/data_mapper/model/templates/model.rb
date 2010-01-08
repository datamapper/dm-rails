class <%= class_name %><%= " < #{parent_class_name.classify}" unless parent_class_name.blank? %>
  include DataMapper::Resource

  property :id, Serial
<% property_attributes.each do |attribute| -%>
  property :<%= attribute.name %>, <%= attribute.type.to_s.classify %>
<% end -%>
<% reference_attributes.each do |attribute| -%>
  belongs_to :<%= attribute.name %>
<% end -%>
<% if options[:timestamps] -%>
  timestamps :at
<% end -%>
end
