module Questionnaire
  module FieldsHelper

    #yields section name and fields of section
    def questionnaire_fields questionnaire
      Parser.load_fields(questionnaire).each do |section_name, section_body|
        yield section_name, section_body
      end
    end

    # returns array with fields from given questionnaire
    def questionnaire_field_names questionnaire
      Questionnaire::Parser.load_fields(questionnaire).values.inject([]) do  |memo, section_fields|
        section_fields.keys.each { |e| memo << e.to_sym }
        memo.flatten
      end
    end

    #returns array with fields with its options for given questionnaire and section
    def stepped_questionnaire_fields_with_options questionnaire, section
      Questionnaire::Parser.load_fields(questionnaire.to_s).fetch(section.to_s)
    end

    #returns array with fields from given questionnaire and section
    def stepped_questionnaire_fields questionnaire, *section_names
      section_names.inject([]) do |memo, section_name|
        memo << Parser.load_fields(questionnaire).fetch(section_name.to_s).keys
        memo.flatten
      end
    end

    #yields section name and field for given questionnaire and section(s)
    def stepped_questionnaire_fields_with_section questionnaire, *section_names
      section_names.each do |section_name|
        Parser.load_fields(questionnaire).fetch(section_name.to_s).keys.each do |field_name|
          yield section_name, field_name
        end
      end
    end

    #returns array with sections of given questionnaire
    def questionnaire_sections questionnaire
      Parser.load_fields(questionnaire).keys
    end

    #returns section containing passed field
    def field_section questionnaire, field
      Questionnaire::Parser.load_fields(questionnaire).find { |section, fields| fields.include?(field) }.first
    end
  end

  module ModelHelper
    
    def self.extended(base)
      base.send(:extend, Questionnaire::FieldsHelper)
    end
    
    def create_model_fields
      questionnaire_fields(name.underscore.to_sym) do |section, section_body|
        section_body.each_pair do |field, options|
          key field.to_sym, options && options.has_key?("type") ? options["type"].constantize : String 
          self.attr_accessible << field.to_sym
        end
      end 
    end
  end

  module FormHelper

    def questionnaire(key, object, options={})
      fields = Parser.load_fields(key)
      simple_form_for(object, options) do |f|
        f.simple_fields_for object.send(key.to_s.singularize.to_sym) do |sf|
          Formatter.create_form_body(object, key, fields, sf)
        end
      end
    end

    def questionnaire_field_displayed? object, field_options
      Formatter.displayed?(object, field_options)
    end
  end
end

ActionView::Base.send :include, Questionnaire::FormHelper
ActionView::Base.send :include, Questionnaire::FieldsHelper

