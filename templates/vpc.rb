CloudFormation {

  Description("vpc template")

  Parameter(:serverAccess) {
    Type("String")
    Default("0.0.0.0/0")
    MinLength(9)
    MaxLength(18)
    AllowedPattern("(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})/(\\d{1,2})")
    ConstraintDescription("must be a valid CIDR range of the form x.x.x.x/x.")
  }

  Mapping(:subnetMap, {
    :VPC => { :CIDR => "172.16.0.0/22" },
    :P   => { :CIDR => "172.16.0.0/24" },
    :Q   => { :CIDR => "172.16.1.0/24" },
    :A   => { :CIDR => "172.16.2.0/24" },
    :B   => { :CIDR => "172.16.3.0/24" }
  })

  Output(:vpcId, Ref(:vpc))
  Output(:sgWebId, Ref(:sgWeb))
  Output(:sgBastionId, Ref(:sgBastion))

  EC2_VPC(:vpc) {
    CidrBlock(FnFindInMap(:subnetMap, :VPC, :CIDR))
    addTag(:role, "networking")
  }
  
  EC2_InternetGateway(:internetGateway) {
    addTag(:role, "networking")
  }

  EC2_VPCGatewayAttachment(:internetGatewayAttachment) {
    VpcId(Ref(:vpc))
    InternetGatewayId(Ref(:internetGateway))
  }

  EC2_RouteTable(:publicTable) {
    VpcId(Ref(:vpc))
    addTag(:role, "networking")
  }

  EC2_Route(:defaultRoute) {
    DependsOn(:internetGateway)
    RouteTableId(Ref(:publicTable))
    DestinationCidrBlock("0.0.0.0/0")
    GatewayId(Ref(:internetGateway))
  }

  publicSubnets = [:P, :Q].inject({}) { |h, pub|
    h[pub] = {
      :subnet => "subnet#{pub}",
      :natGateway => "subnet#{pub}NatGateway",
      :natGatewayEIP => "subnet#{pub}NatGatewayEIP",
      :routeTable => :publicTable,
      :routeTableAssociation => "subnet#{pub}Table"
    }
    h
  }

  publicSubnets.each do |subnet, attributes|

    EC2_Subnet(attributes[:subnet]) {
      VpcId(Ref(:vpc))
      CidrBlock(FnFindInMap(:subnetMap, x, "CIDR"))
      addTag(:role, "networking")
    }

    EC2_SubnetRouteTableAssociation(attributes[:routeTableAssociation]) {
      SubnetId(Ref(subnet))
      RouteTableId(Ref(attributes[:publicTable]))
    }

    EC2_EIP(natGatewayEip) {
      DependsOn(:vpc)
      Domain("vpc")
    }

    EC2_NatGateway(attributes[:natGateway]) {
      AllocationId(FnGetAtt(attributes(:natGatewayEip), "AllocationId"))
      SubnetId(Ref(attributes[:subnet]))
    }

  end
  EC2_SecurityGroup(:sgBastion) {
    GroupDescription("security group for admin access")
    VpcId(Ref(:vpc))
    addTag(:role, "networking")
    SecurityGroupIngress(
      [
        { "IpProtocol" => "tcp", "FromPort" => 22, "ToPort" => 22, "CidrIp" => Ref(:serverAccess) },
        { "IpProtocol" => "icmp", "FromPort" => 8, "ToPort" => "-1", "CidrIp" => Ref(:serverAccess) },
      ]
    )
  }

  EC2_SecurityGroup(:sgWeb) {
    GroupDescription("security group for web access")
    VpcId(Ref(:vpc))
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
