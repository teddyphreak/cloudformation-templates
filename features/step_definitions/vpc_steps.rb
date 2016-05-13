Given(/^template "([^"]*)"$/) do |input|
  @template_body = File.read(input)
end

When(/^the template is deployed with stack name "([^"]*)"$/) do |stack_name|
  test_regions = ['us-east-1']
  @error = ""
  @start,@complete,@status = false, false, false
  @success = 
    Aws.partition('aws').regions.
    reject  { |r| !test_regions.include?(r.name)  }.
    collect { |r| r.name }.
    collect do |region|
      stack_name = "#{stack_name}-#{region}"
      cloudformation = Aws::CloudFormation::Client.new(region: region)
      begin
        id = cloudformation.create_stack({
          stack_name: stack_name,
          template_body: @template_body
        })
        @start = true
        cloudformation.wait_until(:stack_create_complete, { stack_name: stack_name })
        @complete = true
        cloudformation.describe_stacks({ stack_name: stack_name }).stacks[0].stack_status == 'CREATE_COMPLETE'
        @status = true
      rescue Exception => e
        false
        @error = e.message
      ensure 
        cloudformation.delete_stack({stack_name: stack_name})
      end
    end
  puts @success
end

Then(/^aws cloudformation create\-stack should succeed$/) do
  expect(@start).to be true
  expect(@complete).to be true
  expect(@status).to be true
  expect(@error).to eq("")
  expect(@success.all?).to be true
end

