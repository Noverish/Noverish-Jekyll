---
layout: post
title:  "낮은 Swift 버전을 쓰는 라이브러리 CocoaPod에서 사용하기"
date:   2018-01-22 19:50:44 +0900
description: Template description
image: 'http://noverish.me/blog/assets/img/logos/swift.jpg'
category: 'ios'
tags:
- swift
- cocoapod
twitter_text: template twitter_text
---

```
  pod 'LibraryName1'
  pod 'LibraryName2'

  post_install do |installer|
      # Your list of targets here.
      myTargets = ['LibraryName1', 'LibraryName2']

      installer.pods_project.targets.each do |target|
          if myTargets.include? target.name
              target.build_configurations.each do |config|
                  config.build_settings['SWIFT_VERSION'] = '3.2'
              end
          end
      end
  end
```

LibraryName1, LibraryName2를 자신이 원하는 라이브러리 이름으로 바꾸면 된다.    
