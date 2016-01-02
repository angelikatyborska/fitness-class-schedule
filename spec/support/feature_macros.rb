module FeatureMacros
  def select_by_id(id, options = {})
    field = options[:from]
    option_xpath = "//*[@id='#{field}']/option[#{id}]"
    option_text = find(:xpath, option_xpath).text
    select option_text, from: field
  end

  def select_date(date, options = {})
    field = options[:from]
    select date.year.to_s, from: "#{field}_1i"
    select_by_id date.month, from: "#{field}_2i"
    select_by_id date.day, from: "#{field}_3i"
  end

  def select_time(date, options = {})
    field = options[:from]
    select_date(date, options)
    select date.hour.to_s.rjust(2, '0'), from: "#{field}_4i"
    select date.min.to_s.rjust(2, '0'), from: "#{field}_5i"
  end

  def log_in(user)
    visit root_path
    click_link 'Log in'
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Log in'
    expect(page).to have_content 'Log out'
  end
end