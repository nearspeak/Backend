require 'test_helper'

class TagTest < ActiveSupport::TestCase
  test "should automatic add tag_identifier" do
    tag = Tag.new
    assert tag.save, "Did save the tag"

    assert_not_empty tag.tag_identifier, "Did save the tag without a tag identifier"
  end

  test "should not create a tag with the same tag_identifier" do
    tag1 = Tag.new
    tag1.tag_identifier = '16426D7D-FBFC-4B3F-B6F9-B7126EF6D5A7'
    assert tag1.save, "Did not save the first tag"

    tag2 = Tag.new
    tag2.tag_identifier = '16426D7D-FBFC-4B3F-B6F9-B7126EF6D5A7'
    assert_not tag2.save, "Did save the second tag"
  end
end
