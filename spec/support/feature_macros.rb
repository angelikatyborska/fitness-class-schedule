module FeatureMacros
  def select_by_id(id, options = {})
    field = options[:from]
    option_xpath = "//*[@id='#{field}']/option[#{id}]"
    option_text = find(:xpath, option_xpath).text
    select option_text, from: field
  end

  def select_datetime(date, options = {})
    find("##{ options[:from] }")
    script = "$('##{ options[:from] }').val('#{ I18n.l(date.in_website_time_zone, format: :datetimepicker) }')"
    page.execute_script(script)
  end

  def log_in(user)
    visit root_path
    click_link 'Log In'
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Log In'
    wait_for_ajax
    click_button 'Close'
  end
end