class String
  def is_singular?
    self.pluralize != self and self.singularize == self
  end
end

class ActiveRecord::Base

  attr_accessor :human_var, :test

  def self.humanizable(method)
    define_method :human do
      @human_var ||= HumanApi::Human.new(:access_token => self.send(method.to_sym))
    end
  end
end
