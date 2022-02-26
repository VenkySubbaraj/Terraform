import boto3
import time
import os

AMI = 'ami-03fa4afc89e4a8a09'
REGION = 'ap-south-1'

def lambda_handler(event, context):
    try:
        iam = boto3.client('sts', region_name=REGION)
        account_id = iam.get_caller_identity()['Account']
        print(account_id)
    except:
        print("fails")
        raise
        
    finally:
        print(account_id)
        account = "arn:aws:iam::"+ account_id +":instance-profile/Instance_Profile"
        print(account)
        ec2 = boto3.client('ec2', region_name=REGION)
        instance=ec2.run_instances(
            ImageId=AMI,
            MinCount=1,
            MaxCount=1,
            InstanceType='t2.micro',
            KeyName='VenkatTomcat',
            IamInstanceProfile={
                'Arn':account
            },
            TagSpecifications=[
                {
                    'ResourceType': 'instance',
                    'Tags': [
                        {
                            'Key': 'Name',
                            'Value': 'Lambda'
                        },
                    ]
                },
            ]
            )
        print ("New instance created:")
        instance_id = instance['Instances'][0]['InstanceId']
        print (instance_id)
        return instance_id
