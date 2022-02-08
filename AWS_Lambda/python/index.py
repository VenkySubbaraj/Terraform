import boto3
from botocore.exceptions import ClientError


AMI = 'ami-03fa4afc89e4a8a09'
#INSTANCE_TYPE = 't2.micro'
#KEY_NAME = 'VenkatTomcat'
REGION = 'ap-south-1'

#ec2 = boto3.client('ec2', region_name=REGION)

def lambda_handler(event, context):
    ec2 = boto3.client('ec2', region_name=REGION)
    instance=ec2.run_instances(
            ImageId=AMI,
            MinCount=1,
            MaxCount=1,
            InstanceType='t2.micro',
            KeyName='VenkatTomcat'
            )
    print ("New instance created:")
    instance_id = instance['Instances'][0]['InstanceId']
    print (instance_id)
    #ec2.create_tags(Resources=['instance_id'], Tags=[{'Key':'Name', 'Value':'Lambda_function'}])
    return instance_id

