require 'test_helper'

class TextRecordTest < ActiveSupport::TestCase
  test "should not save text record without tag id" do
    text_record = TextRecord.new

    assert_not text_record.save, "Saved the text record without a tag id"
  end
end
