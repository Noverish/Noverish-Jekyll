---
layout: post
title:  "Kotlin과 Firebase를 사용하여 Android에 푸쉬 알림 보내기 - 서버편"
date:   2018-01-07 16:49:19 +0900
description: Template description
image: 'http://noverish.me/blog/assets/img/logos/kotlin-firebase.jpg'
category: 'android'
tags:
- android
- kotlin
- firebase
- fcm
twitter_text: template twitter_text
---

### 1\. FCM Server Side 설명

이제 Firebase 콘솔이 아니라 다른 방법으로 푸쉬 알림을 보내는 방법에 대해 설명하도록 하겠습니다.    
다음과 같은 방법이 있습니다.

1. Firebase Admin Node.js SDK 사용하기
1. FCM HTTP v1 API (새로 나온 HTTP Request 방법)
1. Legacy HTTP protocol (예전에 사용하던 HTTP Request 방법)
1. Legacy XMPP Protocol

여기서는 2번 방법을 사용해 보도록 하겠습니다.

### 2\. Firebase Cloud Messaging 켜기

![image002](../images{{ page.id }}/002.jpg)
[Google Cloud 콘솔](https://console.cloud.google.com/)로 들어갑니다.
위와 같이 프로젝트가 `FCMExample`로 되어 있는지 확인하고 만약에 아니라면 프로젝트 이름을 클릭합니다.

![image003](../images{{ page.id }}/003.jpg)
`FCMExample`를 클릭하고 프로젝트를 열립니다.

<img src="../images{{ page.id }}/004.jpg" width="400">
위와 같이 클릭합니다.

![image005](../images{{ page.id }}/005.jpg)
`ENABLE APIS AND SERVICES`를 클릭합니다.

![image006](../images{{ page.id }}/006.jpg)
`Firebase Cloud Messaging`을 입력합니다.

![image007](../images{{ page.id }}/007.jpg)
`Firebase Cloud Messaging`을 클릭합니다.

![image008](../images{{ page.id }}/008.jpg)
`ENABLE`을 클릭합니다.

![image009](../images{{ page.id }}/009.jpg)
위와 같은 화면이 나오면 성공입니다.

### 3\. HTTP Request Authentication

![image000](../images{{ page.id }}/000.jpg)
[Firebase 콘솔](https://console.firebase.google.com)로 들어가서 설정 - `SERVICE ACCOUNTS` - `GENERATE NEW PRIVATE KEY`를 누릅니다.

<img src="../images{{ page.id }}/001.jpg" width="500">
`GENERATE KEY`를 누릅니다.

![image010](../images{{ page.id }}/010.jpg)
아까 받은 json 파일을 통해 HTTP Request에 쓰일 access key를 찾아야 합니다.
찾는 방법은 위와 같이 3개가 있는데 우리는 Python으로 하도록 하겠습니다.

```shell
pip install --upgrade google-api-python-client
```
위의 명령어로 google-api-python-client를 설치합니다.

```python
from oauth2client.service_account import ServiceAccountCredentials

scopes = ['https://www.googleapis.com/auth/firebase.messaging']

def _get_access_token():
    credentials = ServiceAccountCredentials.from_json_keyfile_name('service-account.json', scopes)
    access_token_info = credentials.get_access_token()
    return access_token_info.access_token
```
위와 같은 코드로 access_token을 알아냅니다.

### 4\. HTTP Request 보내기

저는 HTTP Request를 Postman으로 보냈습니다.
자유롭게 원하시는 방법으로 보내셔도 됩니다.

정확한 HTTP Request의 내용는 다음과 같습니다.

![image011](../images{{ page.id }}/011.jpg)
![image012](../images{{ page.id }}/012.jpg)

```
method = POST

headers = {
  "Authorization": "Bearer " + 아까 그 access_key,
  "Content-Type": "application/json; UTF-8",
}

body = {
    "message": {
        "token":"기기의 token 값",
        "notification": {
            "body": "This is an FCM notification message!",
            "title": "FCM Message"
        }
    }
}
```

위와 같이 HTTP Request를 하시면 성공적으로 앱에 푸쉬 알림이 도착합니다.
