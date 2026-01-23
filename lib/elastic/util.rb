module Elastic
  module Util
    # Helper method to return a copy of the object when functions are called without `!`, so the
    # object is not mutated.
    def method_copy(name, *params)
      esql = clone
      esql.instance_variable_set('@query', esql.instance_variable_get('@query').clone)
      esql.send("#{name}!", *params)
      esql
    end

    # Helper to build the String for the simpler functions.
    # These are of the form 'key.upcase value' like 'DROP value'
    # If metadata has been set, it needs to be added to FROM. There's a possibility there'll be more
    # special cases like this in the future, they can be added here.
    def build_string_query
      @query.map do |k, v|
        if k == :from && !@metadata.empty?
          "#{k.upcase} #{v} METADATA #{@metadata.join(', ')}"
        elsif k && (v == '' || v.nil?)
          k.upcase
        else
          "#{k.upcase} #{v}"
        end
      end.join(' | ')
    end
  end
end
