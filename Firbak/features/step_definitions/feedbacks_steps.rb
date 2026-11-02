

Given('the following session exists:') do |table|
    table.hashes.each do |session|
        Session.create(session)
    end
end

Given('the following question set exists:') do |table|
    table.hashes.each do |question_set|
        QuestionSet.create(question_set)
    end
end

Given('the following questions exist:') do |table|
    table.hashes.each do |question|
        Question.create(question)
    end
end

Given('the following choices exist:') do |table|
    table.hashes.each do |choice|
        Choice.create(choice)
    end
end

Given('the following users exist:') do |table|
    table.hashes.each do |user|
        User.create(user)
    end
end

Given('I am in session {int}') do |Integer|
    visit session_path(Integer)
end

When('I am on question {int}') do |Integer|
    visit question_path(Integer)
end

When('I am user {int}') do |Integer|
    visit user_path(Integer)
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