import json
import boto3
import logging
import os
from datetime import datetime, timezone

logger = logging.getLogger()
logger.setLevel(logging.INFO)

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['TABLE_NAME'])

def log(level, message, **kwargs):
    entry = {
        "level": level,
        "message": message,
        "function": "deleteIncident",
        "timestamp": datetime.now(timezone.utc).isoformat(),
        **kwargs
    }
    if level == "ERROR":
        logger.error(json.dumps(entry))
    else:
        logger.info(json.dumps(entry))

def lambda_handler(event, context):
    try:
        incident_id = event.get('pathParameters', {}).get('id')
        claims = (event.get('requestContext', {})
                      .get('authorizer', {})
                      .get('jwt', {})
                      .get('claims', {}))
        current_user = claims.get('email') or claims.get('sub', 'unknown')

        existing = table.get_item(Key={
            'PK': f'INCIDENT#{incident_id}',
            'SK': 'METADATA'
        })

        item = existing.get('Item')
        if not item:
            log("INFO", "Incident not found", incidentId=incident_id, user=current_user)
            return {
                'statusCode': 404,
                'headers': {'Access-Control-Allow-Origin': '*'},
                'body': json.dumps({'error': 'Incident not found'})
            }

        if item.get('createdBy') != current_user:
            log("INFO", "Unauthorized delete attempt", incidentId=incident_id, user=current_user, owner=item.get('createdBy'))
            return {
                'statusCode': 403,
                'headers': {'Access-Control-Allow-Origin': '*'},
                'body': json.dumps({'error': 'You can only delete your own incidents'})
            }

        table.delete_item(Key={
            'PK': f'INCIDENT#{incident_id}',
            'SK': 'METADATA'
        })

        log("INFO", "Incident deleted", incidentId=incident_id, deletedBy=current_user)

        return {
            'statusCode': 200,
            'headers': {'Access-Control-Allow-Origin': '*'},
            'body': json.dumps({'message': 'Incident deleted'})
        }
    except Exception as e:
        log("ERROR", "Failed to delete incident", error=str(e))
        return {
            'statusCode': 500,
            'headers': {'Access-Control-Allow-Origin': '*'},
            'body': json.dumps({'error': str(e)})
        }