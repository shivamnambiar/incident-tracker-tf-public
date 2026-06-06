import json
import boto3
import uuid
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
        "function": "createIncident",
        "timestamp": datetime.now(timezone.utc).isoformat(),
        **kwargs
    }
    if level == "ERROR":
        logger.error(json.dumps(entry))
    else:
        logger.info(json.dumps(entry))

def lambda_handler(event, context):
    try:
        body = json.loads(event.get('body') or '{}')
        claims = (event.get('requestContext', {})
                      .get('authorizer', {})
                      .get('jwt', {})
                      .get('claims', {}))
        created_by = claims.get('email') or claims.get('sub', 'unknown')

        inc_id = str(uuid.uuid4())
        now = datetime.now(timezone.utc).isoformat()

        table.put_item(Item={
            'PK': f'INCIDENT#{inc_id}',
            'SK': 'METADATA',
            'incidentId': inc_id,
            'title': body.get('title', ''),
            'description': body.get('description', ''),
            'severity': body.get('severity', 'medium'),
            'status': 'open',
            'assignedUser': body.get('assignedUser', ''),
            'createdBy': created_by,
            'createdAt': now,
            'updatedAt': now,
        })

        log("INFO", "Incident created", incidentId=inc_id, createdBy=created_by, severity=body.get('severity', 'medium'))

        return {
            'statusCode': 201,
            'headers': {'Content-Type': 'application/json',
                        'Access-Control-Allow-Origin': '*'},
            'body': json.dumps({'incidentId': inc_id})
        }
    except Exception as e:
        log("ERROR", "Failed to create incident", error=str(e))
        return {
            'statusCode': 500,
            'headers': {'Access-Control-Allow-Origin': '*'},
            'body': json.dumps({'error': str(e)})
        }
#