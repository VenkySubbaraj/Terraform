import boto3
import json

def lambda_handler(event, context):
    client = boto3.client('emr', region_name='ap-south-1')
    response = client.run_job_flow(
        Name = "Bototestcluster",
        ReleaseLabel = 'emr-6.3.0',
        Instances= {
            'MasterInstanceType': 'c4.large',
            'KeepJobFlowAliveWhenNoSteps': True,
            'InstanceCount':1,
            'TerminationProtected': False,
            'Ec2KeyName': 'VenkatTomcat'
        },
        # VisibileToAllUsers = True,
        Applications=[{'Name': 'Spark'}],
        ServiceRole = 'EMR_EC2_DefaultRole',
        JobFlowRole = 'EMR_EC2_DefaultRole'
    )
    
            
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }




