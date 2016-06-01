require 'aws-sdk'
require 'cfndsl-templates/regions'

def create_stack(name, body, cleanup = true)
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
      cloudformation.delete_stack({stack_name: name}) if cleanup
    end
  end
end

def deploy_stack(name, file)
  create_stack(name, File.read(file), false)
end

def validate_template(body)
  aws_test_regions do |region|
    cloudformation = Aws::CloudFormation::Client.new(region: region)
    cloudformation.validate_template({ template_body: body })
  end
end
