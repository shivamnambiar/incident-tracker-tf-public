import json
import boto3
import logging
import os
from datetime import datetime, timezone, timedelta
from boto3.dynamodb.conditions import Key

logger = logging.getLogger()
logger.setLevel(logging.INFO)

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['TABLE_NAME'])

def log(level, message, **kwargs):
    entry = {
        "level": level,
        "message": message,
        "function": "markStaleIncidents",
        "timestamp": datetime.now(timezone.utc).isoformat(),
        **kwargs
    }
    if level == "ERROR":
        logger.error(json.dumps(entry))
    else:
        logger.info(json.dumps(entry))

def lambda_handler(event, context):
    try:
        resp = table.query(
            IndexName='GSI2-status-index',
            KeyConditionExpression=Key('status').eq('open')
        )

        incidents = resp['Items']
        stale_cutoff = datetime.now(timezone.utc) - timedelta(days=7)
        marked_stale = 0

        log("INFO", "Starting stale incident check", totalOpenIncidents=len(incidents))

        for incident in incidents:
            created_at = datetime.fromisoformat(incident['createdAt'])
            
            if created_at < stale_cutoff:
                table.update_item(
                    Key={
                        'PK': incident['PK'],
                        'SK': 'METADATA'
                    },
                    UpdateExpression='SET #s = :s, updatedAt = :u',
                    ExpressionAttributeNames={'#s': 'status'},
                    ExpressionAttributeValues={
                        ':s': 'stale',
                        ':u': datetime.now(timezone.utc).isoformat()
                    }
                )
                log("INFO", "Incident marked stale", incidentId=incident['incidentId'], createdAt=incident['createdAt'])
                marked_stale += 1

        log("INFO", "Stale incident check complete", markedStale=marked_stale)

        return {
            'statusCode': 200,
            'body': json.dumps({'markedStale': marked_stale})
        }
    except Exception as e:
        log("ERROR", "Failed to mark stale incidents", error=str(e))
        raise e