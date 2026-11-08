

Given('the following session exists:') do |table|
    table.hashes.each do |attrs|
        Session.create!(
          id: attrs['id'],
          question_set_id: attrs['question_set_id'],
          host_id: attrs['host_id'],
          code: attrs['code'],
          status: attrs['status'].presence || 'active',
          summary: {}
        )
    end
end

Given('the following question set exists:') do |table|
    table.hashes.each do |question_set|
        QuestionSet.create!(question_set)
    end
end

Given('the following questions exist:') do |table|
    table.hashes.each do |question|
        Question.create!(question)
    end
end

Given('the following choices exist:') do |table|
    table.hashes.each do |choice|
        Choice.create!(choice)
    end
end

Given('the following users exist:') do |table|
    table.hashes.each do |attrs|
        password = attrs['password'].presence || 'password123'
        User.create!(
          id: attrs['id'],
          name: attrs['name'],
          email: attrs['email'],
          role: attrs['role'],
          password: password,
          password_confirmation: password
        )
    end
end

Given('I am in session {int}') do |session_id|
    visit session_path(session_id)
end

When('I am on question {int}') do |question_id|
    visit question_path(question_id)
end

When('I am user {int}') do |user_id|
    visit user_path(user_id)
end

When('I select choice {string}') do |string|
    find(:xpath, "//input[@value='#{string}']").set(true)
end

Then('I should see {string}') do |string|
    expect(page).to have_content(string)
end

Then('I should not see {string}') do |string|
    expect(page).not_to have_content(string)
end