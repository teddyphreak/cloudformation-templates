def validate_template(body)
  aws_test_region_names do |region|
    cloudformation = Aws::CloudFormation::Client.new(region: region)
    cloudformation.validate_template({ template_body: body })
  end
end
