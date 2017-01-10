module Puppet::Parser::Functions
  newfunction(:index_of, :type => :rvalue, :doc => <<-EOS
    returns the index of a string variable in an array
    index_of(array,string)
EOS
  ) do |arguments|

    raise(Puppet::ParseError, "index_of(): Wrong number of arguments given (#{arguments.size} for 2)") if arguments.size != 2

    array = arguments.shift

    unless array.is_a?(Array)
      raise(Puppet::ParseError, 'index_of(): Requires array to work with')
    end

    searchItem = arguments.shift

    if not searchItem or searchItem.empty?
      raise(Puppet::ParseError, 'index_of(): You must provide a string to search for')
    end

    result = -1
    i = 0 
    array.each do |val|
      if val == searchItem
        result = i
      end
      i += 1
    end
    return result
  end
end
