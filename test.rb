def target_regions() ['us-east-1'] end 

def create_test_stack(stack)
  target_regions().map { |region| puts region }
end

create_test_stack("")
