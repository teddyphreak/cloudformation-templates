require 'aws-sdk'

def with_stack(name, body, cleanup = true)
  aws_test_regions do |region|
    cloudformation = Aws::CloudFormation::Client.new(region: region)
    begin
      id = cloudformation.create_stack({
        stack_name: name,
        template_body: body
      })
      cloudformation.wait_until(:stack_create_complete, { stack_name: name })
      stack = cloudformation.describe_stacks({ stack_name: name }).stacks[0]
      if block_given?
        yield cloudformation, stack
      end
    rescue Exception => e
      e.message
    ensure 
      cloudformation.delete_stack({stack_name: name}) if cleanup
    end
  end
end

def deploy_stack(name, file)
  with_stack(name, File.read(file), cleanup = false)
end

def test_stack(name, file)
  with_stack(name, File.read(file), cleanup = true) { |_, stack|
    stack.stack_status
  }
end
