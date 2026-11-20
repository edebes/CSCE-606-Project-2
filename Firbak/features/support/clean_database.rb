# Start every Cucumber run from an empty test database.
# RSpec's before(:all) blocks leave rows behind, which clash with the ids
# in our feature tables (e.g. "UNIQUE constraint failed: users.id").
DatabaseCleaner.clean_with(:truncation)