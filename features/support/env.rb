require 'aws-sdk'

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

def create_stack(name, body)
  aws_test_regions do |region|
    cloudformation = Aws::CloudFormation::Client.new(region: region)
    begin
      id = cloudformation.create_stack({
        stack_name: name,
        template_body: body
      })
      cloudformation.wait_until(:stack_create_complete, { stack_name: name })
      status = cloudformation.describe_stacks({ stack_name: name }).stacks[0].stack_status
      if block_given?
        yield cloudformation
      else
        status
      end
    rescue Exception => e
      e.message
    ensure 
      cloudformation.delete_stack({stack_name: name})
    end
  end
end

def validate_template(body)
  aws_test_regions do |region|
    cloudformation = Aws::CloudFormation::Client.new(region: region)
    cloudformation.validate_template({ template_body: body })
  end
end
