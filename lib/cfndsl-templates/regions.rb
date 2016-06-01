def aws_regions
  regions = Aws.partition('aws').regions.
    collect { |r| r.name }
  if block_given?
    regions.collect { |r| yield r }
  else
    regions 
  end
end

def aws_test_regions(test_regions=['us-east-1'])
  regions = aws_regions.
    reject  { |r| !test_regions.include?(r)  }
  if block_given?
    regions.collect { |r| yield r }
  else
    regions
  end
end
