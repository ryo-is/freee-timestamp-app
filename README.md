# freee_time_stamp

This app is attendance recording app for '人事労務Freee'

## Environment

1. Dounload Flutter -> https://docs.flutter.dev/get-started/install
2. Install dependencies

```
$ fultter pub get
```

3. create  `.env.development`

```
$ cp .env.sample .env.development
```

4. Set env values

Invoke get login user API
https://developer.freee.co.jp/reference/hr/reference#operations-tag-ログインユーザ

```
CLIENT_ID=
CLIENT_SECRET=
COMPANY_ID=
EMPLOYEE_ID=
```

1. Install extentions for VS Code -> https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter
2. Run Debug
   1. Run -> Start Debugging
   2. Select 'Dart&Flutter'

## Create FreeeAPI

1. Create Application -> https://developer.freee.co.jp/startguide/starting-api
   1. The permissions required by the app are '\[人事労務\] 打刻 参照' & '\[人事労務\] 打刻 更新'
2. Get AccessToken & RefereshToken -> https://developer.freee.co.jp/reference

## Build

Run the command below

```
$ flutter build macos (or windows)
```