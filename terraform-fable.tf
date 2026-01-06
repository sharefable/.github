terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 3.0"
        }
    }
}

provider "aws" {
    region = "us-east-2"
}

resource "aws_eip" "EC2EIP" {
    vpc = true
}

resource "aws_eip" "EC2EIP2" {
    vpc = true
}

resource "aws_subnet" "EC2Subnet" {
    availability_zone = "us-east-2a"
    cidr_block = "172.30.0.0/24"
    vpc_id = "${aws_vpc.EC2VPC2.id}"
    map_public_ip_on_launch = true
}

resource "aws_subnet" "EC2Subnet2" {
    availability_zone = "us-east-2b"
    cidr_block = "172.30.1.0/24"
    vpc_id = "${aws_vpc.EC2VPC2.id}"
    map_public_ip_on_launch = true
}

resource "aws_subnet" "EC2Subnet3" {
    availability_zone = "us-east-2c"
    cidr_block = "172.30.2.0/24"
    vpc_id = "${aws_vpc.EC2VPC2.id}"
    map_public_ip_on_launch = true
}

resource "aws_db_subnet_group" "RDSDBSubnetGroup" {
    description = "Created from the RDS Management Console"
    name = "default-vpc-02ce8a3bd1b811d1d"
    subnet_ids = [
        "subnet-0369e339df7d86f4c",
        "subnet-00c35d279ad906488",
        "subnet-08139797b75cfa561"
    ]
}

resource "aws_s3_bucket" "S3Bucket" {
    bucket = "origin-scdna"
}

resource "aws_vpc" "EC2VPC" {
    cidr_block = "10.32.0.0/16"
    enable_dns_support = true
    enable_dns_hostnames = true
    instance_tenancy = "default"
    tags = {
        Name = "fbl_ecs_vpc-prod"
        env = "prod"
        source = "terraform"
    }
}

resource "aws_security_group" "EC2SecurityGroup" {
    description = "Managed by Terraform"
    name = "fbl_ecs_alb_security_group-prod"
    tags = {
        source = "terraform"
        env = "prod"
    }
    vpc_id = "${aws_vpc.EC2VPC.id}"
    ingress {
        cidr_blocks = [
            "0.0.0.0/0"
        ]
        from_port = 80
        protocol = "tcp"
        to_port = 80
    }
    ingress {
        cidr_blocks = [
            "0.0.0.0/0"
        ]
        from_port = 443
        protocol = "tcp"
        to_port = 443
    }
    egress {
        cidr_blocks = [
            "0.0.0.0/0"
        ]
        from_port = 0
        protocol = "-1"
        to_port = 0
    }
}

resource "aws_security_group" "EC2SecurityGroup2" {
    description = "Managed by Terraform"
    name = "jobs_sg"
    tags = {
        env = "prod"
        source = "terraform"
    }
    vpc_id = "${aws_vpc.EC2VPC.id}"
    ingress {
        security_groups = [
            "${aws_security_group.EC2SecurityGroup.id}"
        ]
        from_port = 8081
        protocol = "tcp"
        to_port = 8081
    }
    egress {
        cidr_blocks = [
            "0.0.0.0/0"
        ]
        from_port = 0
        protocol = "-1"
        to_port = 0
    }
}

resource "aws_security_group" "EC2SecurityGroup3" {
    description = "Managed by Terraform"
    name = "api_sg"
    tags = {
        source = "terraform"
        env = "prod"
    }
    vpc_id = "${aws_vpc.EC2VPC.id}"
    ingress {
        security_groups = [
            "${aws_security_group.EC2SecurityGroup.id}"
        ]
        from_port = 8080
        protocol = "tcp"
        to_port = 8080
    }
    egress {
        cidr_blocks = [
            "0.0.0.0/0"
        ]
        from_port = 0
        protocol = "-1"
        to_port = 0
    }
}

resource "aws_subnet" "EC2Subnet4" {
    availability_zone = "us-east-2a"
    cidr_block = "10.32.2.0/24"
    vpc_id = "${aws_vpc.EC2VPC.id}"
    map_public_ip_on_launch = true
}

resource "aws_subnet" "EC2Subnet5" {
    availability_zone = "us-east-2b"
    cidr_block = "10.32.3.0/24"
    vpc_id = "${aws_vpc.EC2VPC.id}"
    map_public_ip_on_launch = true
}

resource "aws_lb" "ElasticLoadBalancingV2LoadBalancer" {
    name = "fbl-ecs-alb"
    internal = false
    load_balancer_type = "application"
    subnets = [
        "subnet-05547e28548d27c03",
        "subnet-07f06941fb0e4fc51"
    ]
    security_groups = [
        "${aws_security_group.EC2SecurityGroup.id}"
    ]
    ip_address_type = "ipv4"
    access_logs {
        enabled = false
        bucket = ""
        prefix = ""
    }
    idle_timeout = "60"
    enable_deletion_protection = "false"
    enable_http2 = "true"
    enable_cross_zone_load_balancing = "true"
}

resource "aws_lb_listener" "ElasticLoadBalancingV2Listener" {
    load_balancer_arn = "arn:aws:elasticloadbalancing:us-east-2:TODO-AWS-ACC-ID-HERE:loadbalancer/app/fbl-ecs-alb/df76825b96ece91d"
    port = 443
    protocol = "HTTPS"
    ssl_policy = "ELBSecurityPolicy-TLS-1-2-2017-01"
    tags = 
    certificate_arn = "arn:aws:acm:us-east-2:TODO-AWS-ACC-ID-HERE:certificate/7d047421-10a3-467b-90ce-a246f73019f0"
    default_action {
        target_group_arn = "arn:aws:elasticloadbalancing:us-east-2:TODO-AWS-ACC-ID-HERE:targetgroup/tg-noop/28b4a407106fc133"
        type = "forward"
    }
}

resource "aws_lb_listener" "ElasticLoadBalancingV2Listener2" {
    load_balancer_arn = "arn:aws:elasticloadbalancing:us-east-2:TODO-AWS-ACC-ID-HERE:loadbalancer/app/fbl-ecs-alb/df76825b96ece91d"
    port = 80
    protocol = "HTTP"
    tags = 
    default_action {
        target_group_arn = "arn:aws:elasticloadbalancing:us-east-2:TODO-AWS-ACC-ID-HERE:targetgroup/tg-api/905d62c1dbd69d63"
        type = "forward"
    }
}

resource "aws_lb_listener_rule" "ElasticLoadBalancingV2ListenerRule" {
    priority = "100"
    listener_arn = "arn:aws:elasticloadbalancing:us-east-2:TODO-AWS-ACC-ID-HERE:listener/app/fbl-ecs-alb/df76825b96ece91d/32684e4437ee0024"
    condition {
        host_header {
            values = [
                "api.service.*"
            ]
        }
    }
    action {
        type = "forward"
        target_group_arn = "arn:aws:elasticloadbalancing:us-east-2:TODO-AWS-ACC-ID-HERE:targetgroup/tg-api/905d62c1dbd69d63"
        forward {
            target_group = [
                {
                    arn = "arn:aws:elasticloadbalancing:us-east-2:TODO-AWS-ACC-ID-HERE:targetgroup/tg-api/905d62c1dbd69d63"
                    weight = 1
                }
            ]
            stickiness {
                enabled = false
            }
        }
    }
    tags = 
}

resource "aws_lb_listener_rule" "ElasticLoadBalancingV2ListenerRule2" {
    priority = "110"
    listener_arn = "arn:aws:elasticloadbalancing:us-east-2:TODO-AWS-ACC-ID-HERE:listener/app/fbl-ecs-alb/df76825b96ece91d/32684e4437ee0024"
    condition {
        host_header {
            values = [
                "jobs.service.*"
            ]
        }
    }
    action {
        type = "forward"
        target_group_arn = "arn:aws:elasticloadbalancing:us-east-2:TODO-AWS-ACC-ID-HERE:targetgroup/tg-jobs/135ae333ae75194c"
        forward {
            target_group = [
                {
                    arn = "arn:aws:elasticloadbalancing:us-east-2:TODO-AWS-ACC-ID-HERE:targetgroup/tg-jobs/135ae333ae75194c"
                    weight = 1
                }
            ]
            stickiness {
                enabled = false
            }
        }
    }
    tags = 
}

resource "aws_security_group" "EC2SecurityGroup4" {
    description = "launch-wizard-1 created 2023-07-05T19:05:34.665Z"
    name = "peering-test-sc"
    tags = {}
    vpc_id = "${aws_vpc.EC2VPC.id}"
    ingress {
        cidr_blocks = [
            "TODO-xxx.xxx.xxx.xxx/xx"
        ]
        from_port = 22
        protocol = "tcp"
        to_port = 22
    }
    egress {
        cidr_blocks = [
            "0.0.0.0/0"
        ]
        from_port = 0
        protocol = "-1"
        to_port = 0
    }
}

resource "aws_lb_target_group" "ElasticLoadBalancingV2TargetGroup" {
    health_check {
        interval = 30
        path = "/health"
        port = "traffic-port"
        protocol = "HTTP"
        timeout = 5
        unhealthy_threshold = 3
        healthy_threshold = 3
        matcher = "200"
    }
    port = 80
    protocol = "HTTP"
    target_type = "ip"
    vpc_id = "${aws_vpc.EC2VPC.id}"
    name = "tg-jobs"
}

resource "aws_lb_target_group" "ElasticLoadBalancingV2TargetGroup2" {
    health_check {
        interval = 30
        path = "/health"
        port = "traffic-port"
        protocol = "HTTP"
        timeout = 5
        unhealthy_threshold = 3
        healthy_threshold = 3
        matcher = "200"
    }
    port = 80
    protocol = "HTTP"
    target_type = "ip"
    vpc_id = "${aws_vpc.EC2VPC.id}"
    name = "tg-api"
}

resource "aws_lb_target_group" "ElasticLoadBalancingV2TargetGroup3" {
    health_check {
        interval = 30
        path = "/health"
        port = "traffic-port"
        protocol = "HTTP"
        timeout = 5
        unhealthy_threshold = 3
        healthy_threshold = 3
        matcher = "200"
    }
    port = 80
    protocol = "HTTP"
    target_type = "ip"
    vpc_id = "${aws_vpc.EC2VPC.id}"
    name = "tg-noop"
}

resource "aws_network_interface" "EC2NetworkInterface" {
    description = "ELB app/fbl-ecs-alb/df76825b96ece91d"
    private_ips = [
        "10.32.3.110"
    ]
    subnet_id = "subnet-05547e28548d27c03"
    source_dest_check = true
    security_groups = [
        "${aws_security_group.EC2SecurityGroup.id}"
    ]
}

resource "aws_network_interface" "EC2NetworkInterface2" {
    description = "arn:aws:ecs:us-east-2:TODO-AWS-ACC-ID-HERE:attachment/ebbbd6a1-d6c5-47c9-8698-dce4fd2e3423"
    private_ips = [
        "10.32.1.157"
    ]
    subnet_id = "subnet-0405a07b2606069a4"
    source_dest_check = true
    security_groups = [
        "${aws_security_group.EC2SecurityGroup2.id}"
    ]
}

resource "aws_network_interface" "EC2NetworkInterface3" {
    description = "Interface for NAT Gateway nat-09f6bb26330f4e5bb"
    private_ips = [
        "10.32.3.92"
    ]
    subnet_id = "subnet-05547e28548d27c03"
    source_dest_check = false
}

resource "aws_network_interface" "EC2NetworkInterface4" {
    description = "RDSNetworkInterface"
    private_ips = [
        "172.30.0.169"
    ]
    subnet_id = "subnet-08139797b75cfa561"
    source_dest_check = true
    security_groups = [
        "sg-056e1d2ed6cf94375"
    ]
}

resource "aws_network_interface" "EC2NetworkInterface5" {
    description = "RDSNetworkInterface"
    private_ips = [
        "172.30.0.101"
    ]
    subnet_id = "subnet-08139797b75cfa561"
    source_dest_check = true
    security_groups = [
        "sg-056e1d2ed6cf94375"
    ]
}

resource "aws_network_interface" "EC2NetworkInterface6" {
    description = "ELB app/fbl-ecs-alb/df76825b96ece91d"
    private_ips = [
        "10.32.2.185"
    ]
    subnet_id = "subnet-07f06941fb0e4fc51"
    source_dest_check = true
    security_groups = [
        "${aws_security_group.EC2SecurityGroup.id}"
    ]
}

resource "aws_network_interface" "EC2NetworkInterface7" {
    description = "RDSNetworkInterface"
    private_ips = [
        "172.30.0.216"
    ]
    subnet_id = "subnet-08139797b75cfa561"
    source_dest_check = true
    security_groups = [
        "sg-056e1d2ed6cf94375"
    ]
}

resource "aws_network_interface" "EC2NetworkInterface8" {
    description = "arn:aws:ecs:us-east-2:TODO-AWS-ACC-ID-HERE:attachment/71594511-f1cd-4009-b952-da5bf693154f"
    private_ips = [
        "10.32.0.6"
    ]
    subnet_id = "subnet-0a1fd5928388ce79c"
    source_dest_check = true
    security_groups = [
        "${aws_security_group.EC2SecurityGroup3.id}"
    ]
}

resource "aws_network_interface" "EC2NetworkInterface9" {
    description = "Interface for NAT Gateway nat-0b49b7e9c57a8c4a5"
    private_ips = [
        "10.32.2.130"
    ]
    subnet_id = "subnet-07f06941fb0e4fc51"
    source_dest_check = false
}

resource "aws_eip_association" "EC2EIPAssociation" {
    allocation_id = "eipalloc-0f257fcb8583cfe85"
    network_interface_id = "eni-0c805835c4ef7de95"
    private_ip_address = "10.32.3.110"
}

resource "aws_eip_association" "EC2EIPAssociation2" {
    allocation_id = "eipalloc-039cac542a059a480"
    network_interface_id = "eni-0c49228dffaf1a063"
    private_ip_address = "10.32.2.130"
}

resource "aws_eip_association" "EC2EIPAssociation3" {
    allocation_id = "eipalloc-0b761837ffeda6ed5"
    network_interface_id = "eni-0b850d201c16cdda0"
    private_ip_address = "10.32.2.185"
}

resource "aws_eip_association" "EC2EIPAssociation4" {
    allocation_id = "eipalloc-0ac3a61963a987a0a"
    network_interface_id = "eni-09f920de0afb05c36"
    private_ip_address = "10.32.3.92"
}

resource "aws_ecs_cluster" "ECSCluster" {
    name = "fbl_cluster-prod"
}

resource "aws_ecs_service" "ECSService" {
    name = "jobs"
    cluster = "arn:aws:ecs:us-east-2:TODO-AWS-ACC-ID-HERE:cluster/fbl_cluster-prod"
    load_balancer {
        target_group_arn = "arn:aws:elasticloadbalancing:us-east-2:TODO-AWS-ACC-ID-HERE:targetgroup/tg-jobs/135ae333ae75194c"
        container_name = "jobs"
        container_port = 8081
    }
    desired_count = 1
    launch_type = "FARGATE"
    platform_version = "LATEST"
    task_definition = "${aws_ecs_task_definition.ECSTaskDefinition.arn}"
    deployment_maximum_percent = 200
    deployment_minimum_healthy_percent = 100
    iam_role = "arn:aws:iam::TODO-AWS-ACC-ID-HERE:role/aws-service-role/ecs.amazonaws.com/AWSServiceRoleForECS"
    network_configuration {
        assign_public_ip = "DISABLED"
        security_groups = [
            "${aws_security_group.EC2SecurityGroup2.id}"
        ]
        subnets = [
            "subnet-0a1fd5928388ce79c",
            "subnet-0405a07b2606069a4"
        ]
    }
    health_check_grace_period_seconds = 0
    scheduling_strategy = "REPLICA"
}

resource "aws_ecs_service" "ECSService2" {
    name = "api"
    cluster = "arn:aws:ecs:us-east-2:TODO-AWS-ACC-ID-HERE:cluster/fbl_cluster-prod"
    load_balancer {
        target_group_arn = "arn:aws:elasticloadbalancing:us-east-2:TODO-AWS-ACC-ID-HERE:targetgroup/tg-api/905d62c1dbd69d63"
        container_name = "api"
        container_port = 8080
    }
    desired_count = 1
    launch_type = "FARGATE"
    platform_version = "LATEST"
    task_definition = "${aws_ecs_task_definition.ECSTaskDefinition2.arn}"
    deployment_maximum_percent = 200
    deployment_minimum_healthy_percent = 100
    iam_role = "arn:aws:iam::TODO-AWS-ACC-ID-HERE:role/aws-service-role/ecs.amazonaws.com/AWSServiceRoleForECS"
    network_configuration {
        assign_public_ip = "DISABLED"
        security_groups = [
            "${aws_security_group.EC2SecurityGroup3.id}"
        ]
        subnets = [
            "subnet-0a1fd5928388ce79c",
            "subnet-0405a07b2606069a4"
        ]
    }
    health_check_grace_period_seconds = 0
    scheduling_strategy = "REPLICA"
}

resource "aws_ecs_task_definition" "ECSTaskDefinition" {
    container_definitions = "[{\"name\":\"jobs\",\"image\":\"TODO-AWS-ACC-ID-HERE.dkr.ecr.ap-southeast-1.amazonaws.com/sqs-jobs:2.0.16\",\"cpu\":256,\"memory\":512,\"portMappings\":[{\"containerPort\":8081,\"hostPort\":8081,\"protocol\":\"tcp\"}],\"essential\":true,\"environment\":[],\"mountPoints\":[],\"volumesFrom\":[],\"secrets\":[{\"name\":\"APP_ENV\",\"valueFrom\":\"arn:aws:ssm:us-east-2:TODO-AWS-ACC-ID-HERE:parameter/prod.api.APP_ENV\"},{\"name\":\"SQS_Q_NAME\",\"valueFrom\":\"arn:aws:ssm:us-east-2:TODO-AWS-ACC-ID-HERE:parameter/prod.api.SQS_Q_NAME\"},{\"name\":\"SQS_Q_REGION\",\"valueFrom\":\"arn:aws:ssm:us-east-2:TODO-AWS-ACC-ID-HERE:parameter/prod.api.SQS_Q_REGION\"},{\"name\":\"DB_CONN_URL\",\"valueFrom\":\"arn:aws:ssm:us-east-2:TODO-AWS-ACC-ID-HERE:parameter/prod.api.DB_CONN_URL\"},{\"name\":\"DB_USER\",\"valueFrom\":\"arn:aws:ssm:us-east-2:TODO-AWS-ACC-ID-HERE:parameter/prod.api.DB_USER\"},{\"name\":\"DB_PWD\",\"valueFrom\":\"arn:aws:ssm:us-east-2:TODO-AWS-ACC-ID-HERE:parameter/prod.api.DB_PWD\"},{\"name\":\"DB_DB\",\"valueFrom\":\"arn:aws:ssm:us-east-2:TODO-AWS-ACC-ID-HERE:parameter/prod.api.DB_DB\"},{\"name\":\"ANALYTICS_DB_CONN_URL\",\"valueFrom\":\"arn:aws:ssm:us-east-2:TODO-AWS-ACC-ID-HERE:parameter/prod.fable-analytics.ANALYTICS_DB_CONN_URL\"},{\"name\":\"ANALYTICS_DB_NAME\",\"valueFrom\":\"arn:aws:ssm:us-east-2:TODO-AWS-ACC-ID-HERE:parameter/prod.fable-analytics.ANALYTICS_DB_NAME\"},{\"name\":\"ANALYTICS_DB_USER\",\"valueFrom\":\"arn:aws:ssm:us-east-2:TODO-AWS-ACC-ID-HERE:parameter/prod.fable-analytics.ANALYTICS_DB_USER\"},{\"name\":\"ANALYTICS_DB_PWD\",\"valueFrom\":\"arn:aws:ssm:us-east-2:TODO-AWS-ACC-ID-HERE:parameter/prod.fable-analytics.ANALYTICS_DB_PWD\"},{\"name\":\"MAILCHIP_SERVER_PREFIX\",\"valueFrom\":\"arn:aws:ssm:us-east-2:TODO-AWS-ACC-ID-HERE:parameter/prod.api.MAILCHIP_SERVER_PREFIX\"},{\"name\":\"MAILCHIMP_API_KEY\",\"valueFrom\":\"arn:aws:ssm:us-east-2:TODO-AWS-ACC-ID-HERE:parameter/prod.api.MAILCHIMP_API_KEY\"},{\"name\":\"ETS_REGION\",\"valueFrom\":\"arn:aws:ssm:us-east-2:TODO-AWS-ACC-ID-HERE:parameter/prod.api.ETS_REGION\"},{\"name\":\"TRANSCODER_PIPELINE_ID\",\"valueFrom\":\"arn:aws:ssm:us-east-2:TODO-AWS-ACC-ID-HERE:parameter/prod.api.TRANSCODER_PIPELINE_ID\"},{\"name\":\"API_SERVER_ENDPOINT\",\"valueFrom\":\"arn:aws:ssm:us-east-2:TODO-AWS-ACC-ID-HERE:parameter/prod.api.API_SERVER_ENDPOINT\"},{\"name\":\"COBALT_API_KEY\",\"valueFrom\":\"arn:aws:ssm:us-east-2:TODO-AWS-ACC-ID-HERE:parameter/prod.api.COBALT_API_KEY\"},{\"name\":\"SLACK_FABLE_BOT_BOT_USER_TOKEN\",\"valueFrom\":\"arn:aws:ssm:us-east-2:TODO-AWS-ACC-ID-HERE:parameter/prod.api.SLACK_FABLE_BOT_BOT_USER_TOKEN\"},{\"name\":\"SMART_LEAD_API_KEY\",\"valueFrom\":\"arn:aws:ssm:us-east-2:TODO-AWS-ACC-ID-HERE:parameter/prod.api.SMART_LEAD_API_KEY\"},{\"name\":\"AUTH0_AUDIENCES\",\"valueFrom\":\"arn:aws:ssm:us-east-2:TODO-AWS-ACC-ID-HERE:parameter/prod.api.AUTH0_AUDIENCES\"},{\"name\":\"AUTH0_ISSUER_URL\",\"valueFrom\":\"arn:aws:ssm:us-east-2:TODO-AWS-ACC-ID-HERE:parameter/prod.api.AUTH0_ISSUER_URL\"},{\"name\":\"ANTHORIPC_KEY\",\"valueFrom\":\"arn:aws:ssm:us-east-2:TODO-AWS-ACC-ID-HERE:parameter/prod.api.ANTHORIPC_KEY\"},{\"name\":\"OPENAI_KEY\",\"valueFrom\":\"arn:aws:ssm:us-east-2:TODO-AWS-ACC-ID-HERE:parameter/prod.api.OPENAI_KEY\"},{\"name\":\"AWS_ASSET_FILE_S3_BUCKET\",\"valueFrom\":\"arn:aws:ssm:us-east-2:TODO-AWS-ACC-ID-HERE:parameter/prod.api.AWS_ASSET_FILE_S3_BUCKET\"},{\"name\":\"AWS_ASSET_FILE_S3_BUCKET_REGION\",\"valueFrom\":\"arn:aws:ssm:us-east-2:TODO-AWS-ACC-ID-HERE:parameter/prod.api.AWS_ASSET_FILE_S3_BUCKET_REGION\"}],\"logConfiguration\":{\"logDriver\":\"awslogs\",\"options\":{\"awslogs-group\":\"jobs\",\"awslogs-create-group\":\"true\",\"awslogs-region\":\"us-east-2\",\"awslogs-stream-prefix\":\"jobs\"}},\"systemControls\":[]}]"
    family = "jobs-prod"
    task_role_arn = "arn:aws:iam::TODO-AWS-ACC-ID-HERE:role/ecs_task_role_for_service-jobs-prod"
    execution_role_arn = "arn:aws:iam::TODO-AWS-ACC-ID-HERE:role/ecsTaskExecutionRole"
    network_mode = "awsvpc"
    requires_compatibilities = [
        "FARGATE"
    ]
    cpu = "256"
    memory = "512"
}

resource "aws_ecs_task_definition" "ECSTaskDefinition2" {
    container_definitions = "[{\"name\":\"api\",\"image\":\"TODO-AWS-ACC-ID-HERE.dkr.ecr.ap-southeast-1.amazonaws.com/fable-api:1.3.29\",\"cpu\":1024,\"memory\":2048,\"portMappings\":[{\"containerPort\":8080,\"hostPort\":8080,\"protocol\":\"tcp\"}],\"essential\":true,\"environment\":[],\"mountPoints\":[],\"volumesFrom\":[],\"secrets\":[{\"name\":\"APP_ENV\",\"valueFrom\":\"arn:aws:ssm:us-east-2:TODO-AWS-ACC-ID-HERE:parameter/prod.api.APP_ENV\"},{\"name\":\"DB_USER\",\"valueFrom\":\"arn:aws:ssm:us-east-2:TODO-AWS-ACC-ID-HERE:parameter/prod.api.DB_USER\"},{\"name\":\"DB_PWD\",\"valueFrom\":\"arn:aws:ssm:us-east-2:TODO-AWS-ACC-ID-HERE:parameter/prod.api.DB_PWD\"},{\"name\":\"DB_CONN_URL\",\"valueFrom\":\"arn:aws:ssm:us-east-2:TODO-AWS-ACC-ID-HERE:parameter/prod.api.DB_CONN_URL\"},{\"name\":\"ASSET_BUCKET_NAME\",\"valueFrom\":\"arn:aws:ssm:us-east-2:TODO-AWS-ACC-ID-HERE:parameter/prod.api.ASSET_BUCKET_NAME\"},{\"name\":\"AWS_S3_REGION\",\"valueFrom\":\"arn:aws:ssm:us-east-2:TODO-AWS-ACC-ID-HERE:parameter/prod.api.AWS_S3_REGION\"},{\"name\":\"AWS_S3_ENDPOINT\",\"valueFrom\":\"arn:aws:ssm:us-east-2:TODO-AWS-ACC-ID-HERE:parameter/prod.api.AWS_S3_ENDPOINT\"},{\"name\":\"AWS_FIREHOSE_REGION\",\"valueFrom\":\"arn:aws:ssm:us-east-2:TODO-AWS-ACC-ID-HERE:parameter/prod.api.AWS_FIREHOSE_REGION\"},{\"name\":\"AWS_FIREHOSE_STREAM_PREFIX\",\"valueFrom\":\"arn:aws:ssm:us-east-2:TODO-AWS-ACC-ID-HERE:parameter/prod.api.AWS_FIREHOSE_STREAM_PREFIX\"},{\"name\":\"CB_API_KEY\",\"valueFrom\":\"arn:aws:ssm:us-east-2:TODO-AWS-ACC-ID-HERE:parameter/prod.api.CB_API_KEY\"},{\"name\":\"CB_SITE_NAME\",\"valueFrom\":\"arn:aws:ssm:us-east-2:TODO-AWS-ACC-ID-HERE:parameter/prod.api.CB_SITE_NAME\"},{\"name\":\"COBALT_API_KEY\",\"valueFrom\":\"arn:aws:ssm:us-east-2:TODO-AWS-ACC-ID-HERE:parameter/prod.api.COBALT_API_KEY\"},{\"name\":\"ANALYTICS_DB_CONN_URL\",\"valueFrom\":\"arn:aws:ssm:us-east-2:TODO-AWS-ACC-ID-HERE:parameter/prod.fable-analytics.ANALYTICS_DB_CONN_URL\"},{\"name\":\"ANALYTICS_DB_USER\",\"valueFrom\":\"arn:aws:ssm:us-east-2:TODO-AWS-ACC-ID-HERE:parameter/prod.fable-analytics.ANALYTICS_DB_USER\"},{\"name\":\"ANALYTICS_DB_PWD\",\"valueFrom\":\"arn:aws:ssm:us-east-2:TODO-AWS-ACC-ID-HERE:parameter/prod.fable-analytics.ANALYTICS_DB_PWD\"},{\"name\":\"HUBSPOT_CLIENT_SECRET\",\"valueFrom\":\"arn:aws:ssm:us-east-2:TODO-AWS-ACC-ID-HERE:parameter/prod.api.HUBSPOT_CLIENT_SECRET\"}],\"logConfiguration\":{\"logDriver\":\"awslogs\",\"options\":{\"awslogs-group\":\"api\",\"awslogs-create-group\":\"true\",\"awslogs-region\":\"us-east-2\",\"awslogs-stream-prefix\":\"api\"}},\"systemControls\":[]}]"
    family = "api-prod"
    task_role_arn = "arn:aws:iam::TODO-AWS-ACC-ID-HERE:role/ecs_task_role_for_service-api"
    execution_role_arn = "arn:aws:iam::TODO-AWS-ACC-ID-HERE:role/ecsTaskExecutionRole"
    network_mode = "awsvpc"
    requires_compatibilities = [
        "FARGATE"
    ]
    cpu = "1024"
    memory = "2048"
}

resource "aws_s3_bucket" "S3Bucket2" {
    bucket = "app.production.todo-example-domain.com"
}

resource "aws_s3_bucket" "S3Bucket3" {
    bucket = "usr-events"
}

resource "aws_s3_bucket" "S3Bucket4" {
    bucket = "ccd1.proxyfable.com"
}

resource "aws_s3_bucket" "S3Bucket5" {
    bucket = "app.todo-example-domain.com"
}

resource "aws_s3_bucket" "S3Bucket6" {
    bucket = "origin.scdna.todo-example-domain.com"
}

resource "aws_s3_bucket_policy" "S3BucketPolicy" {
    bucket = "app.staging.todo-example-domain.com"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"PublicReadGetObject\",\"Effect\":\"Allow\",\"Principal\":\"*\",\"Action\":\"s3:GetObject\",\"Resource\":\"arn:aws:s3:::app.staging.todo-example-domain.com/*\"}]}"
}

resource "aws_s3_bucket_policy" "S3BucketPolicy2" {
    bucket = "${aws_s3_bucket.S3Bucket5.id}"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"PublicReadGetObject\",\"Effect\":\"Allow\",\"Principal\":\"*\",\"Action\":\"s3:GetObject\",\"Resource\":\"arn:aws:s3:::app.todo-example-domain.com/*\"}]}"
}

resource "aws_s3_bucket_policy" "S3BucketPolicy3" {
    bucket = "${aws_s3_bucket.S3Bucket2.id}"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"PublicReadGetObject\",\"Effect\":\"Allow\",\"Principal\":\"*\",\"Action\":\"s3:GetObject\",\"Resource\":\"arn:aws:s3:::app.production.todo-example-domain.com/*\"}]}"
}

resource "aws_s3_bucket_policy" "S3BucketPolicy4" {
    bucket = "${aws_s3_bucket.S3Bucket4.id}"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"PublicReadGetObject\",\"Effect\":\"Allow\",\"Principal\":\"*\",\"Action\":\"s3:*Object\",\"Resource\":\"arn:aws:s3:::ccd1.proxyfable.com/*\"}]}"
}

resource "aws_s3_bucket_policy" "S3BucketPolicy5" {
    bucket = "${aws_s3_bucket.S3Bucket6.id}"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"PublicReadGetObject\",\"Effect\":\"Allow\",\"Principal\":\"*\",\"Action\":\"s3:GetObject\",\"Resource\":\"arn:aws:s3:::origin.scdna.todo-example-domain.com/*\"}]}"
}

resource "aws_s3_bucket_policy" "S3BucketPolicy6" {
    bucket = "${aws_s3_bucket.S3Bucket.id}"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"PublicReadGetObject\",\"Effect\":\"Allow\",\"Principal\":\"*\",\"Action\":\"s3:GetObject\",\"Resource\":\"arn:aws:s3:::origin-scdna/*\"}]}"
}

resource "aws_db_instance" "RDSDBInstance" {
    identifier = "api-prod"
    allocated_storage = 400
    instance_class = "db.m5.large"
    engine = "mysql"
    username = "admin"
    password = "REPLACEME"
    backup_window = "06:47-07:17"
    backup_retention_period = 7
    availability_zone = "us-east-2a"
    maintenance_window = "thu:05:01-thu:05:31"
    multi_az = false
    engine_version = "8.0.42"
    auto_minor_version_upgrade = true
    license_model = "general-public-license"
    publicly_accessible = true
    storage_type = "gp2"
    port = 3306
    storage_encrypted = true
    kms_key_id = "arn:aws:kms:us-east-2:TODO-AWS-ACC-ID-HERE:key/b273ce0b-4de8-4fe3-98fb-8356a5618a0f"
    copy_tags_to_snapshot = true
    monitoring_interval = 60
    iam_database_authentication_enabled = false
    deletion_protection = true
    db_subnet_group_name = "default-vpc-02ce8a3bd1b811d1d"
    vpc_security_group_ids = [
        "sg-056e1d2ed6cf94375"
    ]
    max_allocated_storage = 1000
}

resource "aws_db_instance" "RDSDBInstance2" {
    identifier = "prod-analytics"
    allocated_storage = 200
    instance_class = "db.t3.micro"
    engine = "postgres"
    username = "root"
    password = "REPLACEME"
    backup_window = "09:08-09:38"
    backup_retention_period = 1
    availability_zone = "us-east-2a"
    maintenance_window = "mon:05:41-mon:06:11"
    multi_az = false
    engine_version = "16.8"
    auto_minor_version_upgrade = true
    license_model = "postgresql-license"
    publicly_accessible = true
    storage_type = "gp2"
    port = 5432
    storage_encrypted = true
    kms_key_id = "arn:aws:kms:us-east-2:TODO-AWS-ACC-ID-HERE:key/b273ce0b-4de8-4fe3-98fb-8356a5618a0f"
    copy_tags_to_snapshot = true
    monitoring_interval = 0
    iam_database_authentication_enabled = false
    deletion_protection = false
    db_subnet_group_name = "default-vpc-02ce8a3bd1b811d1d"
    vpc_security_group_ids = [
        "sg-056e1d2ed6cf94375"
    ]
    max_allocated_storage = 1000
}

resource "aws_db_instance" "RDSDBInstance3" {
    identifier = "fable-app"
    allocated_storage = 50
    instance_class = "db.t3.micro"
    engine = "mysql"
    username = "admin"
    password = "REPLACEME"
    backup_window = "07:04-07:34"
    backup_retention_period = 7
    availability_zone = "us-east-2a"
    maintenance_window = "mon:04:43-mon:05:13"
    multi_az = false
    engine_version = "8.0.42"
    auto_minor_version_upgrade = true
    license_model = "general-public-license"
    publicly_accessible = true
    storage_type = "gp2"
    port = 3306
    storage_encrypted = true
    kms_key_id = "arn:aws:kms:us-east-2:TODO-AWS-ACC-ID-HERE:key/b273ce0b-4de8-4fe3-98fb-8356a5618a0f"
    copy_tags_to_snapshot = true
    monitoring_interval = 0
    iam_database_authentication_enabled = false
    deletion_protection = false
    db_subnet_group_name = "default-vpc-02ce8a3bd1b811d1d"
    vpc_security_group_ids = [
        "sg-056e1d2ed6cf94375"
    ]
    max_allocated_storage = 1000
}

resource "aws_vpc" "EC2VPC2" {
    cidr_block = "172.30.0.0/16"
    enable_dns_support = true
    enable_dns_hostnames = true
    instance_tenancy = "default"
    tags = {
        Name = "mysql"
    }
}

resource "aws_vpc_peering_connection" "EC2VPCPeeringConnection" {
    tags = {
        source = "terraform"
        env = "prod"
    }
    peer_vpc_id = "${aws_vpc.EC2VPC2.id}"
    peer_owner_id = "TODO-AWS-ACC-ID-HERE"
    peer_region = "us-east-2"
    vpc_id = "${aws_vpc.EC2VPC.id}"
}

resource "aws_subnet" "EC2Subnet6" {
    availability_zone = "us-east-2a"
    cidr_block = "10.32.0.0/24"
    vpc_id = "${aws_vpc.EC2VPC.id}"
    map_public_ip_on_launch = false
}

resource "aws_subnet" "EC2Subnet7" {
    availability_zone = "us-east-2b"
    cidr_block = "10.32.1.0/24"
    vpc_id = "${aws_vpc.EC2VPC.id}"
    map_public_ip_on_launch = false
}

resource "aws_nat_gateway" "EC2NatGateway" {
    subnet_id = "subnet-05547e28548d27c03"
    tags = {
        env = "prod"
        source = "terraform"
    }
    allocation_id = "eipalloc-0ac3a61963a987a0a"
}

resource "aws_nat_gateway" "EC2NatGateway2" {
    subnet_id = "subnet-07f06941fb0e4fc51"
    tags = {
        env = "prod"
        source = "terraform"
    }
    allocation_id = "eipalloc-039cac542a059a480"
}

resource "aws_internet_gateway" "EC2InternetGateway" {
    tags = {
        env = "prod"
        Name = "fbl_igw-prod"
        source = "terraform"
    }
    vpc_id = "${aws_vpc.EC2VPC.id}"
}

resource "aws_internet_gateway" "EC2InternetGateway2" {
    tags = {}
    vpc_id = "${aws_vpc.EC2VPC2.id}"
}

resource "aws_route" "EC2Route" {
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = "igw-03773c6f4262e548e"
    route_table_id = "rtb-07b819ea9989ee4e1"
}

resource "aws_route" "EC2Route2" {
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = "igw-05bb8e37d499a1b17"
    route_table_id = "rtb-0a9c469ee7f83835d"
}

resource "aws_vpc_dhcp_options" "EC2DHCPOptions" {
    domain_name = "us-east-2.compute.internal"
    tags = {}
}

resource "aws_vpc_dhcp_options_association" "EC2VPCDHCPOptionsAssociation" {
    dhcp_options_id = "dopt-08711b37360245a4a"
    vpc_id = "${aws_vpc.EC2VPC2.id}"
}

resource "aws_route" "EC2Route3" {
    destination_cidr_block = "${aws_vpc.EC2VPC2.cidr_block}"
    vpc_peering_connection_id = "pcx-0a77d13d1305a910f"
    route_table_id = "rtb-07b819ea9989ee4e1"
}

resource "aws_route" "EC2Route4" {
    destination_cidr_block = "${aws_vpc.EC2VPC.cidr_block}"
    vpc_peering_connection_id = "pcx-0a77d13d1305a910f"
    route_table_id = "rtb-0a9c469ee7f83835d"
}

resource "aws_route_table" "EC2RouteTable" {
    vpc_id = "${aws_vpc.EC2VPC.id}"
    tags = {}
}

resource "aws_route_table" "EC2RouteTable2" {
    vpc_id = "${aws_vpc.EC2VPC.id}"
    tags = {
        source = "terraform"
        env = "prod"
    }
}

resource "aws_route_table" "EC2RouteTable3" {
    vpc_id = "${aws_vpc.EC2VPC.id}"
    tags = {
        source = "terraform"
        env = "prod"
    }
}

resource "aws_route_table" "EC2RouteTable4" {
    vpc_id = "${aws_vpc.EC2VPC2.id}"
    tags = {}
}

resource "aws_route" "EC2Route5" {
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = "nat-0b49b7e9c57a8c4a5"
    route_table_id = "rtb-08c4f0c1a015f0d3c"
}

resource "aws_route" "EC2Route6" {
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = "nat-09f6bb26330f4e5bb"
    route_table_id = "rtb-07a49b6c086c80281"
}

resource "aws_route_table_association" "EC2SubnetRouteTableAssociation" {
    route_table_id = "rtb-08c4f0c1a015f0d3c"
    subnet_id = "subnet-0a1fd5928388ce79c"
}

resource "aws_route_table_association" "EC2SubnetRouteTableAssociation2" {
    route_table_id = "rtb-07a49b6c086c80281"
    subnet_id = "subnet-0405a07b2606069a4"
}

resource "aws_cloudfront_distribution" "CloudFrontDistribution" {
    aliases = [
        "${aws_s3_bucket.S3Bucket5.id}"
    ]
    origin {
        custom_origin_config {
            http_port = 80
            https_port = 443
            origin_keepalive_timeout = 5
            origin_protocol_policy = "http-only"
            origin_read_timeout = 30
            origin_ssl_protocols = [
                "SSLv3",
                "TLSv1",
                "TLSv1.1",
                "TLSv1.2"
            ]
        }
        domain_name = "app.production.todo-example-domain.com.s3-website.us-east-2.amazonaws.com"
        origin_id = "app.production.todo-example-domain.com.s3.us-east-2.amazonaws.com"
        
        origin_path = ""
    }
    default_cache_behavior {
        allowed_methods = [
            "HEAD",
            "GET",
            "OPTIONS"
        ]
        compress = true
        smooth_streaming  = false
        target_origin_id = "app.production.todo-example-domain.com.s3.us-east-2.amazonaws.com"
        viewer_protocol_policy = "redirect-to-https"
    }
    custom_error_response {
        error_caching_min_ttl = 2592000
        error_code = 403
        response_code = "200"
        response_page_path = "/index.html"
    }
    custom_error_response {
        error_caching_min_ttl = 2592000
        error_code = 404
        response_code = "200"
        response_page_path = "/index.html"
    }
    comment = "prod - app.todo-example-domain.com"
    price_class = "PriceClass_All"
    enabled = true
    viewer_certificate {
        acm_certificate_arn = "arn:aws:acm:us-east-1:TODO-AWS-ACC-ID-HERE:certificate/4f1ea6ce-752f-40e4-8156-4ffd18c1dc18"
        cloudfront_default_certificate = false
        minimum_protocol_version = "TLSv1.2_2021"
        ssl_support_method = "sni-only"
    }
    restrictions {
        geo_restriction {
            restriction_type = "none"
        }
    }
    web_acl_id = "arn:aws:wafv2:us-east-1:TODO-AWS-ACC-ID-HERE:global/webacl/CreatedByCloudFront-7dcc4ee4-477b-461a-816b-57bdd9ea72fd/da758d3a-5e30-44c7-aa7d-f3b054118262"
    http_version = "http2"
    is_ipv6_enabled = true
}

resource "aws_cloudfront_distribution" "CloudFrontDistribution2" {
    aliases = [
        "scdna.todo-example-domain.com"
    ]
    origin {
        domain_name = "origin-scdna.s3.us-east-2.amazonaws.com"
        origin_id = "origin.scdna.todo-example-domain.com.s3.us-east-2.amazonaws.com"
        
        origin_path = ""
        s3_origin_config {
            origin_access_identity = ""
        }
    }
    default_cache_behavior {
        allowed_methods = [
            "HEAD",
            "GET",
            "OPTIONS"
        ]
        compress = true
        smooth_streaming  = false
        target_origin_id = "origin.scdna.todo-example-domain.com.s3.us-east-2.amazonaws.com"
        viewer_protocol_policy = "redirect-to-https"
    }
    comment = "prod - cdn for data files - app.todo-example-domain.com"
    price_class = "PriceClass_All"
    enabled = true
    viewer_certificate {
        acm_certificate_arn = "arn:aws:acm:us-east-1:TODO-AWS-ACC-ID-HERE:certificate/4f1ea6ce-752f-40e4-8156-4ffd18c1dc18"
        cloudfront_default_certificate = false
        minimum_protocol_version = "TLSv1.2_2021"
        ssl_support_method = "sni-only"
    }
    restrictions {
        geo_restriction {
            restriction_type = "none"
        }
    }
    http_version = "http2"
    is_ipv6_enabled = true
}

resource "aws_cloudfront_distribution" "CloudFrontDistribution3" {
    aliases = [
        "als.todo-example-domain.com"
    ]
    origin {
        custom_origin_config {
            http_port = 80
            https_port = 443
            origin_keepalive_timeout = 5
            origin_protocol_policy = "http-only"
            origin_read_timeout = 30
            origin_ssl_protocols = [
                "SSLv3",
                "TLSv1",
                "TLSv1.1",
                "TLSv1.2"
            ]
        }
        domain_name = "fbl-ecs-alb-1400647219.us-east-2.elb.amazonaws.com"
        origin_id = "fbl-ecs-alb-1400647219.us-east-2.elb.amazonaws.com"
        
        origin_path = ""
    }
    default_cache_behavior {
        allowed_methods = [
            "HEAD",
            "DELETE",
            "POST",
            "GET",
            "OPTIONS",
            "PUT",
            "PATCH"
        ]
        compress = true
        smooth_streaming  = false
        target_origin_id = "fbl-ecs-alb-1400647219.us-east-2.elb.amazonaws.com"
        viewer_protocol_policy = "allow-all"
    }
    comment = "analytics log service - prod"
    price_class = "PriceClass_All"
    enabled = true
    viewer_certificate {
        acm_certificate_arn = "arn:aws:acm:us-east-1:TODO-AWS-ACC-ID-HERE:certificate/4f1ea6ce-752f-40e4-8156-4ffd18c1dc18"
        cloudfront_default_certificate = false
        minimum_protocol_version = "TLSv1.2_2021"
        ssl_support_method = "sni-only"
    }
    restrictions {
        geo_restriction {
            restriction_type = "none"
        }
    }
    http_version = "http2"
    is_ipv6_enabled = true
}

resource "aws_sqs_queue" "SQSQueue" {
    delay_seconds = "0"
    max_message_size = "262144"
    message_retention_seconds = "86400"
    receive_wait_time_seconds = "20"
    visibility_timeout_seconds = "900"
    name = "tour_app_queue"
    redrive_policy = "{\"deadLetterTargetArn\":\"arn:aws:sqs:us-east-2:TODO-AWS-ACC-ID-HERE:tour_app_queue-DLQ\",\"maxReceiveCount\":3}"
}

resource "aws_sqs_queue" "SQSQueue2" {
    delay_seconds = "0"
    max_message_size = "262144"
    message_retention_seconds = "259200"
    receive_wait_time_seconds = "0"
    visibility_timeout_seconds = "900"
    name = "tour_app_queue-DLQ"
}

resource "aws_ssm_parameter" "SSMParameter" {
    name = "prod.api.API_SERVER_ENDPOINT"
    type = "String"
    value = "https://api.service.todo-example-domain.com"
}

resource "aws_ssm_parameter" "SSMParameter2" {
    name = "prod.api.AUTH0_ISSUER_URL"
    type = "String"
    value = "https://TODO-example-domain.us.auth0.com/"
}

resource "aws_ssm_parameter" "SSMParameter3" {
    name = "prod.api.CB_SITE_NAME"
    type = "String"
    value = "TODO:VALUE_HERE"
}

resource "aws_ssm_parameter" "SSMParameter4" {
    name = "prod.api.AWS_S3_ENDPOINT"
    type = "String"
    value = "https://s3.us-east-2.amazonaws.com"
}

resource "aws_ssm_parameter" "SSMParameter5" {
    name = "prod.api.COBALT_API_KEY"
    type = "String"
    value = "TODO:VALUE_HERE"
}

resource "aws_ssm_parameter" "SSMParameter6" {
    name = "prod.api.DB_PWD"
    type = "String"
    value = "TODO:VALUE_HERE"
}

resource "aws_ssm_parameter" "SSMParameter7" {
    name = "prod.api.OPENAI_KEY"
    type = "String"
    value = "TODO:VALUE_HERE"
}

resource "aws_ssm_parameter" "SSMParameter8" {
    name = "prod.api.TRANSCODER_PIPELINE_ID"
    type = "String"
    value = "TODO:VALUE_HERE"
}

resource "aws_ssm_parameter" "SSMParameter9" {
    name = "prod.api.SQS_Q_NAME"
    type = "String"
    value = "tour_app_queue"
}

resource "aws_ssm_parameter" "SSMParameter10" {
    name = "prod.api.AUTH0_AUDIENCES"
    type = "String"
    value = "https://api.service.todo-example-domain.com"
}

resource "aws_ssm_parameter" "SSMParameter11" {
    name = "prod.api.AWS_FIREHOSE_REGION"
    type = "String"
    value = "ap-southeast-1"
}

resource "aws_ssm_parameter" "SSMParameter12" {
    name = "prod.fable-analytics.AWS_S3_ATHENA_OUTPUT_BUCKET"
    type = "String"
    value = "mics-singpr"
}

resource "aws_ssm_parameter" "SSMParameter13" {
    name = "prod.api.DB_CONN_URL"
    type = "String"
    value = "TODO:VALUE_HERE"
}

resource "aws_ssm_parameter" "SSMParameter14" {
    name = "prod.api.DB_DB"
    type = "String"
    value = "fable_tour_app"
}

resource "aws_ssm_parameter" "SSMParameter15" {
    name = "prod.api.MAILCHIMP_API_KEY"
    type = "String"
    value = "TODO:VALUE_HERE"
}

resource "aws_ssm_parameter" "SSMParameter16" {
    name = "prod.api.SLACK_FABLE_BOT_BOT_USER_TOKEN"
    type = "String"
    value = "TODO:VALUE_HERE"
}

resource "aws_ssm_parameter" "SSMParameter17" {
    name = "prod.fable-analytics.ANALYTICS_DB_PWD"
    type = "String"
    value = "TODO:VALUE_HERE"
}

resource "aws_ssm_parameter" "SSMParameter18" {
    name = "prod.fable-analytics.AWS_ATHENA_REGION"
    type = "String"
    value = "ap-southeast-1"
}

resource "aws_ssm_parameter" "SSMParameter19" {
    name = "prod.api.APP_ENV"
    type = "String"
    value = "prod"
}

resource "aws_ssm_parameter" "SSMParameter20" {
    name = "prod.api.ANTHORIPC_KEY"
    type = "String"
    value = "TODO:ANTHROPIC_EMAIL_ID_VALUE_HERE|TODO:ANTHROPIC_API_KEY_VALUE_HERE"
}

resource "aws_ssm_parameter" "SSMParameter21" {
    name = "prod.fable-analytics.AWS_GLUE_REGION"
    type = "String"
    value = "ap-southeast-1"
}

resource "aws_ssm_parameter" "SSMParameter22" {
    name = "prod.api.ASSET_BUCKET_NAME"
    type = "String"
    value = "${aws_s3_bucket.S3Bucket.id}"
}

resource "aws_ssm_parameter" "SSMParameter23" {
    name = "prod.fable-analytics.AWS_S3_ATHENA_OUTPUT_ROOT_DIR"
    type = "String"
    value = "athena-query-result"
}

resource "aws_ssm_parameter" "SSMParameter24" {
    name = "prod.api.AWS_ASSET_FILE_S3_BUCKET"
    type = "String"
    value = "${aws_s3_bucket.S3Bucket.id}"
}

resource "aws_ssm_parameter" "SSMParameter25" {
    name = "prod.api.AWS_FIREHOSE_STREAM_PREFIX"
    type = "String"
    value = "prod_ueds_"
}

resource "aws_ssm_parameter" "SSMParameter26" {
    name = "prod.api.HUBSPOT_CLIENT_SECRET"
    type = "String"
    value = "TODO:VALUE_HERE"
}

resource "aws_ssm_parameter" "SSMParameter27" {
    name = "prod.api.AWS_S3_REGION"
    type = "String"
    value = "us-east-2"
}

resource "aws_ssm_parameter" "SSMParameter28" {
    name = "prod.api.DB_USER"
    type = "String"
    value = "TODO:VALUE_HERE"
}

resource "aws_ssm_parameter" "SSMParameter29" {
    name = "prod.fable-analytics.ANALYTICS_DB_USER"
    type = "String"
    value = "TODO:VALUE_HERE"
}

resource "aws_ssm_parameter" "SSMParameter30" {
    name = "prod.fable-analytics.AWS_GLUE_USER_ASSIGN_CRAWLER_NAME"
    type = "String"
    value = "user_assign_prod"
}

resource "aws_ssm_parameter" "SSMParameter31" {
    name = "prod.api.AWS_ASSET_FILE_S3_BUCKET_REGION"
    type = "String"
    value = "us-east-2"
}

resource "aws_ssm_parameter" "SSMParameter32" {
    name = "prod.api.CB_API_KEY"
    type = "String"
    value = "TODO:VALUE_HERE"
}

resource "aws_ssm_parameter" "SSMParameter33" {
    name = "prod.api.ETS_REGION"
    type = "String"
    value = "ap-south-1"
}

resource "aws_ssm_parameter" "SSMParameter34" {
    name = "prod.api.MAILCHIP_SERVER_PREFIX"
    type = "String"
    value = "TODO:VALUE_HERE"
}

resource "aws_ssm_parameter" "SSMParameter35" {
    name = "prod.api.SMART_LEAD_API_KEY"
    type = "String"
    value = "TODO:VALUE_HERE"
}

resource "aws_ssm_parameter" "SSMParameter36" {
    name = "prod.api.SQS_Q_REGION"
    type = "String"
    value = "us-east-2"
}

resource "aws_ssm_parameter" "SSMParameter37" {
    name = "prod.fable-analytics.ANALYTICS_DB_CONN_URL"
    type = "String"
    value = "TODO:VALUE_HERE"
}

resource "aws_ssm_parameter" "SSMParameter38" {
    name = "prod.fable-analytics.ANALYTICS_DB_NAME"
    type = "String"
    value = "fable_analytics"
}

resource "aws_ssm_parameter" "SSMParameter39" {
    name = "prod.fable-analytics.AWS_GLUE_CRAWLER_NAME"
    type = "String"
    value = "prod"
}

resource "aws_ssm_parameter" "SSMParameter40" {
    name = "prod.fable-analytics.AWS_GLUE_DB_NAME"
    type = "String"
    value = "prod_analytics_raw"
}
