# Evolution API
- Change API Key during set up
- Token: 1BFCC7C13D3B-4E59-9A0F-A99422A5E874

 
## Instal community nodes

## Whatsapp

- https://geekbydefault.co/settings/community-nodes
- n8n-nodes-evolution-api

### Set node

```
{
  "chat_id": null,
  "instance_name": null,
  "apikey": null,
  "server_url": null,
  "message": null
}

```

### HTTP Request node URL

From the Evolution API Documentation - [LINK](https://www.postman.com/agenciadgcode/evolution-api/request/ubhuf1u/send-text?tab=body)


```
{{ $('Edit Fields').item.json.server_url }}/message/sendText/{{ $('Edit Fields').item.json.instance_name }}
```
- Header Parameters:
```
apikey:{{ $('Edit Fields').item.json.apikey }}

```

- Body:
```
{
  "number": "{{ $('Edit Fields').item.json.chat_id }}",
  "text": "{{ $json.output }}",
  "delay": 2000
}
```