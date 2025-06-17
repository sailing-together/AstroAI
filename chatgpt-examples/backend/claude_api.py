import boto3
import json

def call_claude(prompt: str) -> str:
    client = boto3.client('bedrock-runtime', region_name='us-east-1')

    request_body = {
        "anthropic_version": "bedrock-2023-05-31",
        "max_tokens": 1000,
        "temperature": 0.7,
        "messages": [
            {"role": "user", "content": prompt}
        ]
    }

    response = client.invoke_model(
        modelId='anthropic.claude-3-sonnet-20240229-v1:0',
        contentType='application/json',
        accept='application/json',
        body=json.dumps(request_body)
    )

    result = json.loads(response['body'].read())
    output = result['content'][0]['text']
    return output

