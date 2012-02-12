require "simple_form"

module Questionnaire
  #TODO: investigate why autoload Parser, require ... didnt work
  require   'core/parser'
  require   'core/formatter'
  require   'core/helpers.rb'

  # define global options for fields as a module accessors here, consider using the same names as
  # simple_form does

  # options directly from simple_form
  mattr_accessor :as

  #custom questionnaire options
  mattr_accessor :title_tag
  @@title_tag = :h1

  mattr_accessor :section_tag
  @@section_tag = :h3

  def self.setup
    yield self
  end
end
