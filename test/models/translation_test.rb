require 'test_helper'

class TranslationTest < ActiveSupport::TestCase
  test "should not save translation without text record id" do
    translation = Translation.new

    assert_not translation.save, "Saved the translation without a text record id"
  end
end
