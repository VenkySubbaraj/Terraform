import boto3
import os

ec2 = boto3.resource('ec2', region_name="ap-southeast-1")
instance = ec2.create_instance(
        ImageId = "ami-0356b1cd4aa0ee970", 
        MinCount = 1,
        MaxCount = 1,
        InstanceType = 't2.micro',
         KeyName='venkatesh',
          TagSpecifications=[
              {
                   'ResourceType': 'instance',
                    'Tags': [
                        {
                           'Key': 'Name',
                           'Value': 'my-ec2-instance'
                           },
                        ]
                   },
               ]
           )

