class MoveNameToNameTranslation < ActiveRecord::Migration
  def up
    Tag.find_each do |tag|
      unless tag.name.nil?
        nameTranslation = NameTranslation.create(:text => tag.name, :lang_code => 'de')
        unless nameTranslation.nil?
          tag.original_name = nameTranslation
          tag.save!
        end
      end
    end
  end

  def down

  end
end
