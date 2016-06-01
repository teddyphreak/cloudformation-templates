require 'aws-sdk'

require_relative 'defaults'

def aws_regions
  regions = Aws.partition('aws').regions.
    collect { |r| r.name }
  if block_given?
    regions.collect { |r| yield r }
  else
    regions 
  end
end

def aws_test_regions(test_regions=defaults.test.regions)
  regions = aws_regions.
    reject  { |r| !test_regions.include?(r)  }
  if block_given?
    regions.collect { |r| yield r }
  else
    regions
  end
end
