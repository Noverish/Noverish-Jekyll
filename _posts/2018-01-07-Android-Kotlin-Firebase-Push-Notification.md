---
layout: post
title:  "Kotlin과 Firebase를 사용하여 Android에 푸쉬 알림 보내기 - 클라이언트 편"
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

### 1\. Android 프로젝트 생성

![image000](../images{{ page.id }}/000.jpg)
`FCMExample`이라는 이름의 프로젝트를 만듭니다.    
우리는 Kotlin을 사용할 것 이므로 `Include Kotlin support`에 체크를 해야 합니다.    

![image001](../images{{ page.id }}/001.jpg)
Next를 누릅니다.    

![image002](../images{{ page.id }}/002.jpg)
`Empty Activity`를 선택합니다.    

![image003](../images{{ page.id }}/003.jpg)
간단하게 하기 위해 `Backwards Compatibility`를 해제 했습니다.    

### 2\. Firebase 프로젝트 생성

<img src="../images{{ page.id }}/004.jpg" width="500">
[Firebase 콘솔](https://console.firebase.google.com)로 들어가서 `Add Project`를 클릭합니다.    

<img src="../images{{ page.id }}/005.jpg" width="500">
프로젝트 이름을 `FCMExample`이라고 했습니다.    
국가는 한국으로 하고 `Create Project`를 누릅니다.    

<img src="../images{{ page.id }}/006.jpg" width="500">
만들고 나서 나오는 화면에서 `Add Firebase to your Android app`을 클릭합니다.    

<img src="../images{{ page.id }}/007.jpg" width="500">
우리 안드로이드 앱의 package name을 적어줍시다.    

<img src="../images{{ page.id }}/008.jpg" width="500">
`Download google-services.json` 버튼을 눌러 json파일을 다운 받습니다.    

<img src="../images{{ page.id }}/009.jpg" width="500">
이건 뒤에서 설명하므로 넘어갑니다.    
이로써 Firebase에 프로젝트를 생성했습니다.    
이제 안드로이드 스튜디오에서 설정할 차례입니다.

### 3\. Android 프로젝트에서 Firebase 설정

<img src="../images{{ page.id }}/010.jpg" width="500">
다시 안드로이드 스튜디오로 넘어와서 Android 뷰를 Project 뷰로 바꿉니다.    

![image011](../images{{ page.id }}/011.jpg)
아까 다운로드 받은 `google-services.json`파일을 드래그 & 드롭으로 app 폴더에 넣어줍니다.    

![image012](../images{{ page.id }}/012.jpg)
이 창이 뜨면 그냥 OK합니다.    

<img src="../images{{ page.id }}/013.jpg" width="400">
이렇게 성공적으로 json파일이 옮겨진 것을 확인 할 수 있습니다.    

![image014](../images{{ page.id }}/014.jpg)
project level의 `build.gradle` 파일에 위의 사진의 위치에    
`classpath 'com.google.gms:google-services:3.1.0'`을 입력합니다.

![image015](../images{{ page.id }}/015.jpg)
app level의 `build.gralde` 파일 맨 끝에 위의 사진 처럼    
`apply plugin: 'com.google.gmc:google-services'`를 입력합니다.

![image016](../images{{ page.id }}/016.jpg)
그리고 `Sync Now`를 누르면 Firebase 설정은 끝났습니다.    
이제 Firebase Cloud Message 설정을 할 차례입니다.

![image020](../images{{ page.id }}/020.png)
가끔씩 이렇게 빌드가 실패 할 수도 있습니다.
support-annotations 라이브러리가 테스트 앱의 버전과 우리 앱의 버전이 달라서 생기는 문제라고 하는데    

![image021](../images{{ page.id }}/021.png)
테스트 앱의 버전을 강제로 우리 앱에 적용시켜줍니다. (여기선 25.4.0)    
`compile 'com.android.support:support-annotations:25.4.0'`를 위의 사진 처럼 씁니다.    

### 4\. 코드 작성

![image019](../images{{ page.id }}/019.png)
`compile 'com.google.firebase:firebase-messaging:11.8.0'`를 써서 라이브러리를 설치합니다.    

#### MyFirebaseInstanceIDService.kt
```kotlin
package me.noverish.fcmexample

import com.google.firebase.iid.FirebaseInstanceId
import com.google.firebase.iid.FirebaseInstanceIdService

class MyFirebaseInstanceIDService : FirebaseInstanceIdService() {
    override fun onTokenRefresh() {
        val refreshedToken = FirebaseInstanceId.getInstance().token
        println("Refreshed token: " + refreshedToken!!)
    }
}
```
`MainActivity.kt`와 같은 폴더에 `MyFirebaseInstanceIDService.kt`를 만들고 위의 코드를 씁니다.    
위 코드로 인해 기기의 Firebase Token 값이 변하면(생성되면) `onTokenRefresh()`가 실행이 되서 개발자가 처리를 할 수 있게 합니다.
보통은 이 함수에 서버로 token값을 보내는 코드를 넣어서 서버에서 이 토큰 값을 통해 푸쉬 알림을 줍니다.

#### MyFirebaseMessagingService.kt
```kotlin
package me.noverish.fcmexample

import android.app.NotificationManager
import android.content.Context
import android.media.RingtoneManager
import android.support.v4.app.NotificationCompat
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage

class MyFirebaseMessagingService : FirebaseMessagingService() {
    override fun onMessageReceived(remoteMessage: RemoteMessage?) {
        if (remoteMessage!!.notification != null) {
            sendNotification(remoteMessage.notification!!.body!!)
        }
    }

    private fun sendNotification(messageBody: String) {
        val defaultSoundUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
        val notificationBuilder = NotificationCompat.Builder(this)
                .setSmallIcon(R.mipmap.ic_launcher_round)
                .setContentTitle("FCM Message")
                .setContentText(messageBody)
                .setSound(defaultSoundUri)

        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.notify(0, notificationBuilder.build())
    }
}
```
같은 위치에 `MyFirebaseMessagingService.kt`를 만들고 위의 코드를 씁니다.    
위의 코드는 푸쉬 알림을 받으면 그에 대한 처리를 하는 코드 입니다.
푸쉬 알림이 오면 `onMessageReceived()`함수가 실행이 되고 여기서 `sendNotification()` 함수를 통해 안드로이드 알림을 생성합니다.

#### AndroidManifest.xml
`AndroidManifest.xml`의 `application`태그 안에 아래를 입력합니다.
```xml
<service
    android:name=".MyFirebaseMessagingService">
    <intent-filter>
        <action android:name="com.google.firebase.MESSAGING_EVENT"/>
    </intent-filter>
</service>

<service
    android:name=".MyFirebaseInstanceIDService">
    <intent-filter>
        <action android:name="com.google.firebase.INSTANCE_ID_EVENT"/>
    </intent-filter>
</service>
```

### 5\. Firebase Token 값 확인

![image024](../images{{ page.id }}/024.png)
위의 코드를 전부 작성하고 앱을 실행하면 이렇게 로그 창에 기기 token 값이 생성되서 나옵니다.
기기에 따라 몇 초에서 몇 분정도는 걸릴 수 있습니다.
토큰 값이 생성된 이후에 다시 token값을 알아내려면 `FirebaseInstanceId.getInstance().token`에 접근해서 알아내시면 됩니다.
왜 처음부터 이렇게 안 하고 `onTokenRefresh()` 함수에서 받아내냐면 처음에 앱이 실행 되고 난 뒤에 token값이 생성되기 때문입니다.
따라서 앱을 처음 실행할 때 부터 바로 접근하면 토큰 값은 nil로 되어 있습니다.    
이제 이 토큰 값을 복사 합니다.

### 6\. Firebase Console 에서 푸쉬 알림 보내기

<img src="../images{{ page.id }}/017.png" width="300">
다시 Firebase Console로 돌아가서 `Grow`의 `Notifications`을 클릭합니다.    

![image018](../images{{ page.id }}/018.png)
`SEND YOUR FIRST MESSAGE`를 클릭합니다.    

![image022](../images{{ page.id }}/022.png)    
Message Text에 아무 단어나 적고    
Target을 Single device로 바꾼 뒤 token값을 아까 복사 한 걸 붙여넣습니다.    
그리고 `SEND MESSAGE` 버튼을 누릅니다.

<img src="../images{{ page.id }}/023.jpg" width="300">
그러면 이렇게 성공적으로 푸쉬가 옵니다!
<br>
<br>

물론 실제 서비스 할 때 이렇게 일일히 콘솔로 들어가서 손으로 푸쉬 알림을 보낼 순 없겠죠?    
당연히 Firebase에는 여러가지 방법을 사용해서 푸쉬 알림을 보내는 기능을 제공합니다.    
그럼 다음 포스팅에는 이 방법들을 사용해서 앱에 푸쉬를 보내는 방법을 알려드리도록 하겠습니다.
