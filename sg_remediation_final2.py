

import boto3
import botocore
import json
import jmespath
from pprint import pprint



old_cidr = '0.0.0.0/0'
new_cidr = '10.0.0.0/8'
old_ipv6_cidr = '::/0' 
new_ipv6_cidr = 'fe80::a00:0/104'

regions = [
        'us-east-1',
        'us-east-2', 
        'us-west-1',
        'us-west-2',
        'ca-central-1', 
        'eu-central-1', 
        'eu-west-1', 
        'eu-west-2', 
        'eu-west-3', 
        'eu-north-1', 
        'ap-south-1',
        'ap-southeast-1',
        'ap-southeast-2',
        'ap-northeast-1',
        'sa-east-1' 
        ]


###update the Security Groups Rules from 0.0.0.0/0 to 10.0.0.0/8
def update(aws_regions=regions):  
    for region in aws_regions:
        ec2_sg = boto3.client('ec2', region_name=region)
        info = ec2_sg.describe_security_groups()
        print(region)
        for secgrp in info['SecurityGroups']:
            for rules in secgrp["IpPermissions"]:
                for iprange in rules["IpRanges"]:
                    try: 
                        from_port = int(rules["FromPort"])
                        to_port = int(rules["ToPort"])
                        protocol = rules["IpProtocol"]
                        sg_id = secgrp["GroupId"]
                        group_name = secgrp["GroupName"]
                        desc = secgrp["Description"]
                        cidr = iprange["CidrIp"]
                        if to_port == 80:
                            print('Skip: port 80 ')
                            continue
                        elif to_port == 443:
                            print('Skip: port 443')
                            continue
                        elif (to_port != 80 and cidr == old_cidr) or (to_port != 443 and cidr == old_cidr ):
                            data = ("REGION:{}  SECGRP_ID:{}  GROUP:{}  F_PORT:{}  T_PORT:{}  CIDR:{} PROTOCOL:{}" .format(region, sg_id, group_name, from_port, to_port, cidr, protocol))
                            print(data)
                            print(data, file = open(sg_result_summary, 'a+'))
                            with open(sg_result, 'w+') as file:
                                json.dump(info, file, indent=4)
                            add_sg = ec2_sg.authorize_security_group_ingress( #add new security group
                                GroupId = sg_id,
                                IpPermissions=[
                                    {
                                        'FromPort': from_port,
                                        'IpProtocol': protocol,
                                        'IpRanges': [
                                            {
                                                'CidrIp': new_cidr
                                            }
                                        ],
                                        'ToPort': to_port
                                    }
                                ]
                            )
                            del_sg = ec2_sg.revoke_security_group_ingress( #delete old security group
                                GroupId = sg_id,
                                IpPermissions=[
                                    {
                                        'FromPort': from_port,
                                        'IpProtocol': protocol,
                                        'IpRanges': [
                                            {
                                                'CidrIp': old_cidr,
                                            }
                                        ],
                                        'ToPort': to_port
                                    }
                                ]
                            )
                    except Exception as e: 
                        if e == 'botocore.exceptions.ClientError':
                            print('Security group rule does not exist')
                            continue
                        else:
                            print(e)
                            continue
                    

  ###update the IPv6 Security Groups Rules from ::0/0 to fe80::a00:0/104
def update_ipv6(aws_regions=regions): 
   for region in aws_regions:
        ec2_sg = boto3.client('ec2', region_name=region)
        info = ec2_sg.describe_security_groups()
        print(region)
        for  secgrp in info['SecurityGroups']:
            for rules in secgrp["IpPermissions"]:
                for iprange in rules["Ipv6Ranges"]:
                    try: 
                        from_port = int(rules["FromPort"])
                        to_port = int(rules["ToPort"])
                        protocol = rules["IpProtocol"]
                        sg_id = secgrp["GroupId"]
                        group_name = secgrp["GroupName"]
                        desc = secgrp["Description"]
                        cidripv6 = iprange["CidrIpv6"]
                        if to_port == 80:
                            print('Skip: port 80 ')
                            continue
                        elif to_port == 443:
                            print('Skip: port 443')
                            continue
                        elif (to_port != 80 and cidripv6 == old_ipv6_cidr) or (to_port != 443 and cidripv6 == old_ipv6_cidr ):
                            # data = ("SECGRP_ID:{}  GROUP:{}  DESC:{}  F_PORT:{}  T_PORT:{}  CIDR:{} PROTOCOL:{}" .format(sg_id, group_name, desc, from_port, to_port, cidr, protocol))
                            data = ("REGION:{}  SECGRP_ID:{}  GROUP:{}  F_PORT:{}  T_PORT:{}  CIDR:{} PROTOCOL:{}" .format(region, sg_id, group_name, from_port, to_port, cidripv6, protocol))
                            print(data)
                            print(data, file = open(sg_result_summary, 'a+'))
                            with open(sg_result, 'w+') as file:
                                json.dump(info, file, indent=4)
                            add_sg = ec2_sg.authorize_security_group_ingress( #add new IPv6 security group
                                GroupId = sg_id,
                                IpPermissions=[
                                    {
                                        'FromPort': from_port,
                                        'IpProtocol': protocol,
                                        'Ipv6Ranges': [
                                            {
                                                'CidrIpv6': new_ipv6_cidr
                                            }
                                        ],
                                        'ToPort': to_port
                                    }
                                ]
                            )
                            del_sg = ec2_sg.revoke_security_group_ingress( #delete old IPv6 security group rule
                                GroupId = sg_id,
                                IpPermissions=[
                                    {
                                        'FromPort': from_port,
                                        'IpProtocol': protocol,
                                        'Ipv6Ranges': [
                                            {
                                                'CidrIpv6': old_ipv6_cidr,
                                            }
                                        ],
                                        'ToPort': to_port
                                    }
                                ]
                            )
                    except Exception as e: 
                        if e == 'botocore.exceptions.ClientError':
                            print('Security group rule does not exist')
                            continue
                        else:
                            print(e)
                            continue
                   


                ### Reverse change to original state    
def rollback(aws_regions=regions):
    for region in aws_regions:
        ec2_sg = boto3.client('ec2', region_name=region)
        info = ec2_sg.describe_security_groups()
        print(region)
        for secgrp in info['SecurityGroups']:
            for rules in secgrp["IpPermissions"]:
                for iprange in rules["IpRanges"]:
                    try: 
                        from_port = int(rules["FromPort"])
                        to_port = int(rules["ToPort"])
                        protocol = rules["IpProtocol"]
                        sg_id = secgrp["GroupId"]
                        group_name = secgrp["GroupName"]
                        desc = secgrp["Description"]
                        cidr = iprange["CidrIp"]
                        if to_port == 80:
                            print('Skip: port 80 ')
                            continue
                        elif to_port == 443:
                            print('Skip: port 443')
                            continue
                        elif (to_port != 80 and cidr == new_cidr) or (to_port != 443 and cidr == new_cidr ):
                            # print("SECGRP_ID:{}  GROUP:{}  DESC:{}  F_PORT:{}  T_PORT:{}  CIDR:{} PROTOCOL:{}" .format(sg_id, group_name, desc, from_port, to_port, cidr, protocol))
                            data = ("REGION:{}  SECGRP_ID:{}  GROUP:{}  F_PORT:{}  T_PORT:{}  CIDR:{} PROTOCOL:{}" .format(region, sg_id, group_name, from_port, to_port, cidr, protocol))
                            add_sg = ec2_sg.authorize_security_group_ingress(
                                GroupId = sg_id,
                                IpPermissions=[
                                    {
                                        'FromPort': from_port,
                                        'IpProtocol': protocol,
                                        'IpRanges': [
                                            {
                                                'CidrIp': old_cidr
                                            }
                                        ],
                                        'ToPort': to_port
                                    }
                                ]
                            )
                            del_sg = ec2_sg.revoke_security_group_ingress( #ec2_sg.security_group.revoke_ingress(
                                GroupId = sg_id,
                                IpPermissions=[
                                    {
                                        'FromPort': from_port,
                                        'IpProtocol': protocol,
                                        'IpRanges': [
                                            {
                                                'CidrIp': new_cidr,
                                            }
                                        ],
                                        'ToPort': to_port
                                    }
                                ]
                            )
                    except Exception as e: 
                        if e == 'botocore.exceptions.ClientError':
                            print('Security group rule does not exist')
                            continue
                        else:
                            print(e)
                            continue

def rollback_ipv6(aws_regions=regions): 
   for region in aws_regions:
        ec2_sg = boto3.client('ec2', region_name=region)
        info = ec2_sg.describe_security_groups()
        print(region)
        for  secgrp in info['SecurityGroups']:
            for rules in secgrp["IpPermissions"]:
                for iprange in rules["Ipv6Ranges"]:
                    try: 
                        from_port = int(rules["FromPort"])
                        to_port = int(rules["ToPort"])
                        protocol = rules["IpProtocol"]
                        sg_id = secgrp["GroupId"]
                        group_name = secgrp["GroupName"]
                        desc = secgrp["Description"]
                        cidripv6 = iprange["CidrIpv6"]
                        if to_port == 80:
                            print('Skip: port 80 ')
                            continue
                        elif to_port == 443:
                            print('Skip: port 443')
                            continue
                        elif (to_port != 80 and cidripv6 == new_ipv6_cidr) or (to_port != 443 and cidripv6 == new_ipv6_cidr ):
                            data = ("REGION:{}  SECGRP_ID:{}  GROUP:{}  F_PORT:{}  T_PORT:{}  CIDR:{} PROTOCOL:{}" .format(region, sg_id, group_name, from_port, to_port, cidripv6, protocol))
                            print(data)
                            print(data, file = open(sg_result_summary, 'a+'))
                            with open(sg_result, 'w+') as file:
                                json.dump(info, file, indent=4)
                            add_sg = ec2_sg.authorize_security_group_ingress( #add old IPv6 security group
                                GroupId = sg_id,
                                IpPermissions=[
                                    {
                                        'FromPort': from_port,
                                        'IpProtocol': protocol,
                                        'Ipv6Ranges': [
                                            {
                                                'CidrIpv6': old_ipv6_cidr
                                            }
                                        ],
                                        'ToPort': to_port
                                    }
                                ]
                            )
                            del_sg = ec2_sg.revoke_security_group_ingress( #delete new IPv6 security group rule
                                GroupId = sg_id,
                                IpPermissions=[
                                    {
                                        'FromPort': from_port,
                                        'IpProtocol': protocol,
                                        'Ipv6Ranges': [
                                            {
                                                'CidrIpv6': new_ipv6_cidr,
                                            }
                                        ],
                                        'ToPort': to_port
                                    }
                                ]
                            )
                    except Exception as e: 
                        if e == 'botocore.exceptions.ClientError':
                            print('Security group rule does not exist')
                            continue
                        else:
                            print(e)
                            continue


c = 0

while c < 2:
    remediate = (str(input('Enter update or rollback: ')))
    account = (str(input('Enter AWS Account: ')))
    sg_result = f'/Users/kapprey/tmp/{account}/sg_result_{account}.json'
    sg_result_summary = f'/Users/kapprey/tmp/{account}/sg_result_{account}_summary.txt'
    if remediate == 'update':
        update()
        update_ipv6()
        break
    elif remediate == 'rollback':
        rollback()
        rollback_ipv6()
        break
    else:
        print('Please enter correct info.')
        c += 1
        continue

        




