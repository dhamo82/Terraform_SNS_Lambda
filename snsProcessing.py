from datetime import datetime
import boto3
account_id = boto3.client('sts').get_caller_identity()["Account"]
s3 = boto3.resource('s3')
def lambda_handler(event, context):
    record = event['Records'][0]['Sns']
    message = record['Message']
    subject = record['Subject']
    print("Subject: %s" % subject)
    print("Message: %s" % message)
    s3.Object(f"sns-lab-bucket-{account_id}", subject).put(Body=message)
    return "SUCCESS"
