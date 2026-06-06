import json
import boto3
import logging
import os
from datetime import datetime, timezone
from boto3.dynamodb.conditions import Key

logger = logging.getLogger()
logger.setLevel(logging.INFO)

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['TABLE_NAME'])

def log(level, message, **kwargs):
    entry = {
        "level": level,
        "message": message,
        "function": "getOpenIncidents",
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

        log("INFO", "Fetched open incidents", count=resp['Count'])

        return {
            'statusCode': 200,
            'headers': {'Content-Type': 'application/json',
                        'Access-Control-Allow-Origin': '*'},
            'body': json.dumps({
                'incidents': resp['Items'],
                'count': resp['Count']
            })
        }
    except Exception as e:
        log("ERROR", "Failed to fetch open incidents", error=str(e))
        return {
            'statusCode': 500,
            'headers': {'Access-Control-Allow-Origin': '*'},
            'body': json.dumps({'error': str(e)})
        }