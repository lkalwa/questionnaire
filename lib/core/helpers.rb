module Questionnaire
  module FieldsHelper
    
    def questionnaire_fields questionnaire
      Parser.load_fields(questionnaire).each do |section_name, section_body|
        yield section_name, section_body
      end
    end

    def questionnaire_field_names questionnaire
      Questionnaire::Parser.load_fields(questionnaire).values.inject([]) do  |memo, section_fields|
        section_fields.keys.each { |e| memo << e.to_sym }
        memo.flatten
      end
    end

    def stepped_questionnaire_fields questionnaire, section_name
      Parser.load_fields(questionnaire).fetch(section_name.to_s).keys
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

    def questionnaire(key, object, fields=nil, options={})
      form_fields = Parser.load_fields(key)
      form_fields = form_fields[fields.to_s] if fields
      simple_form_for(object, options) do |f|
        f.simple_fields_for object.send(key.to_s.singularize.to_sym) do |sf|
          Formatter.create_form_body(object, key, form_fields, sf)
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

