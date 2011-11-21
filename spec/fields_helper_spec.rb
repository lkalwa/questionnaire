require 'spec_helper'

class ClassB; extend Questionnaire::FieldsHelper; end

describe Questionnaire::FieldsHelper do
  let(:questionnaire_section) { { "section_name" => { "some_field" => nil, "some_other_field" => nil } } }
  let(:questionnaire_with_two_sections) { questionnaire_section.merge("second_section" => {"second_field" => nil }) }
  let(:questionnaire_fields_to_array) { [:some_field, :some_other_field, :second_field] }

  describe "questionnaire fields" do
    it "should return section_name with set of section fields" do
      Questionnaire::Parser.stub(:load_fields).and_return(questionnaire_section)
      ClassB.questionnaire_fields(questionnaire_section) {|s,b|}.should == questionnaire_section
    end

    it "should return array with section fields regardless section" do
      Questionnaire::Parser.stub(:load_fields).and_return(questionnaire_with_two_sections)
      ClassB.questionnaire_field_names(questionnaire_with_two_sections).should == questionnaire_fields_to_array
    end
  end
end
  