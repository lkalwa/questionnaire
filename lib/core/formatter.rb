module Questionnaire
  class Formatter

    NON_FIELD_OPTIONS = [:title_tag, :section_tag]

    class << self
      include ActionView::Helpers

      def create_form_body(object, key, fields, form)
        output = content_tag(Questionnaire.title_tag, I18n.t(:"questionnaires.#{key}.label"))
        fields.keys.each do |section|
          next if fields[section].nil?
          output << content_tag(Questionnaire.section_tag, I18n.t(:"questionnaires.#{key}.#{section}.label"))
          fields[section].each_pair do |section_field, field_options|
            output << field_with_options(form, object, key, section_field, section, field_options)
          end
        end
        output << form.button(:submit)
        output.html_safe
      end

      def field_with_options(form, object, key, field, section, field_options)
        if displayed? object, field_options
          form.input field.to_sym, field_attributes.merge!(html_options(field, object, key, section, field_options))
        end
      end

      def displayed?(object, field_options)
        field_options.is_a?(Hash) && field_options.has_key?("only") ? object.send(:"#{field_options['only']}?") : true
      end

      # grabs elements defined in gem initializer file, select getters, check if them are't
      # TODO convert to oneliner returning hash
      def field_attributes
        methods = Questionnaire.instance_methods.select { |m| m.to_s !~ /=/ } - NON_FIELD_OPTIONS
        methods.inject({}) do |memo, method|
          memo[method] = Questionnaire.send(method.to_sym)
          memo
        end
      end

      def html_options(field, object, key, section, options)
        {required: false}.tap do |h|
          h[:as] = options["as"].to_sym if options.is_a?(Hash) && options.has_key?("as")
          h[:label] = I18n.t(:"questionnaires.#{key}.#{section}.#{field}")
        end
      end
    end
  end
end
