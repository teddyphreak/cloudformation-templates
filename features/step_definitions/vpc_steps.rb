Given(/^template "([^"]*)"$/) do |input|
  @template = input
end

Then(/^aws cloudformation validate\-template should succeed$/) do
  expect { validate_template(File.read(@template)) }.not_to raise_exception
end

Then(/^aws cloudformation create\-stack should succeed$/) do
  expect(test_stack('test-vpc', @template)).to eq(['CREATE_COMPLETE'])
end
