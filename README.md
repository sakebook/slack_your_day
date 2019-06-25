# slack_your_day

- Random choice users from user group in Slack

![image](https://raw.githubusercontent.com/sakebook/slack_your_day/master/art/sample.png)

## Requirements
- Firebase plan Flame or Blaze (Not Spark!)
- Slack Outgoing WebHooks

## Setup

```sh
$ git clone https://github.com/sakebook/slack_your_day
$ cd slack_your_day
$ firebase init
$ cd functions
$ firebase functions:config:set secret.token="xoxp-XXXXXXXXXXXXXXXX"
```

## Build

```sh
$ pub run build_runner build --output=build
$ firebase serve --only functions
```

## Deploy
```sh
$ pub run build_runner build --output=build
$ firebase deploy --only functions
```