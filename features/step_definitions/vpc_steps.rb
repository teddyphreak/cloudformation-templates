Given(/^template "([^"]*)"$/) do |input|
  @template_body = File.read(input)
end

Then(/^aws cloudformation validate\-template should succeed$/) do
  expect { validate_template(@template_body) }.not_to raise_exception
end

Then(/^aws cloudformation create\-stack should succeed$/) do
  expect(create_stack('test-vpc', @template_body)).to eq(['CREATE_COMPLETE'])
end
