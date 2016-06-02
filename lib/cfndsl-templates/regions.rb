require 'aws-sdk'

require_relative 'defaults'

def aws_regions
  Aws.partition('aws').regions .collect { |r| yield r }
end

def aws_region_names
  if block_given?
    aws_regions { |r| yield r.name }
  else
    aws_regions.collect { |r| r.name }
  end
end

def aws_test_regions
  (aws_regions { |r| r })
    .reject { |r| !aws_test_region_names.include?(r.name) }
    .collect { |r| yield r }
end

def aws_test_region_names(test_regions=defaults.test.regions)
  if block_given?
    test_regions.collect { |r| yield r }
  else
    test_regions
  end
end
