class DateTimeInput < SimpleForm::Inputs::DateTimeInput
  def input(wrapper_options)
    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)
    merged_input_options[:class] << :datetimepicker
    merged_input_options[:value] = I18n.l(@options[:selected], format: :datetimepicker)
    "#{@builder.text_field(attribute_name, merged_input_options)}".html_safe
  end
end