CloudFormation {

  Description("vpc template")

  Parameter("serverAccess") {
    Type("String")
    Default("0.0.0.0/0")
    MinLength(9)
    MaxLength(18)
    AllowedPattern("(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})/(\\d{1,2})")
    ConstraintDescription("must be a valid CIDR range of the form x.x.x.x/x.")
  }

  Mapping("subnetMap", {
    :VPC => { :CIDR => "172.16.0.0/22" },
    :A   => { :CIDR => "172.16.0.0/24" },
    :B   => { :CIDR => "172.16.1.0/24" },
    :C   => { :CIDR => "172.16.2.0/24" }
  })

  Output(:vpcId, Ref("vpc"))
  Output(:sgWebId, Ref("sgWeb"))
  Output(:sgBastionId, Ref("sgBastion"))

  EC2_VPC("vpc") {
    CidrBlock(FnFindInMap("subnetMap", "VPC", "CIDR"))
    addTag(:role, "networking")
  }

  [:A, :B, :C].each do |subnet|
    EC2_Subnet("subnet#{subnet}") {
      VpcId(Ref("vpc"))
      CidrBlock(FnFindInMap("subnetMap", subnet, "CIDR"))
      addTag(:role, "networking")
    }
  end

  EC2_SecurityGroup("sgBastion") {
    GroupDescription("security group for admin access")
    VpcId(Ref("vpc"))
    addTag(:role, "networking")
    SecurityGroupIngress(
      [
        { "IpProtocol" => "tcp", "FromPort" => 22, "ToPort" => 22, "CidrIp" => Ref("serverAccess") },
        { "IpProtocol" => "icmp", "FromPort" => 8, "ToPort" => "-1", "CidrIp" => Ref("serverAccess") },
      ]
    )
    SecurityGroupEgress([])
  }

  EC2_SecurityGroup("sgWeb") {
    GroupDescription("security group for web access")
    VpcId(Ref("vpc"))
    addTag(:role, "networking")
    SecurityGroupIngress(
      [
        { "IpProtocol" => "tcp", "FromPort" => 22, "ToPort" => 22, "SourceSecurityGroupId" => Ref("sgBastion") },
        { "IpProtocol" => "icmp", "FromPort" => 8, "ToPort" => "-1", "SourceSecurityGroupId" => Ref("sgBastion") },
        { "IpProtocol" => "tcp", "FromPort" => 80, "ToPort" => "80", "CidrIp" => "0.0.0.0/0" },
        { "IpProtocol" => "tcp", "FromPort" => 443, "ToPort" => 443, "CidrIp" => "0.0.0.0/0" }
      ]
    )
  }

}
