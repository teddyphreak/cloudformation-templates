require 'aws-sdk'

<<<<<<< Updated upstream
<<<<<<< Updated upstream
require_relative 'regions'
=======
=======
>>>>>>> Stashed changes
def aws_region_az()
  aws_regions.inject({}) { |h, region|
    ec2 = Aws::EC2::Client.new(region: region)
    h[region] = ec2.describe_availability_zones.collect { |x| x.zone.name }
    h
  }
end

def region_az(region)
    ec2 = Aws::EC2::Client.new(region: region)
    ec2.describe_availability_zones.collect { |x| x.zone.name }
end

def aws_az()
  aws_regions.flat_map { |x| region_az(x) }
end
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
