# Assist

Assistive tools for software development.

## General

You can quickly try my tools by using [Mint](https://github.com/yonaskolb/Mint). Just install it using [Homebrew](https://brew.sh/) via `brew install mint`. Then you can run each command by letting mint automaticaly clone and install it:

```shell
$ mint run git@github.com:Blackjacx/Assist.git asc -t "Bearer <token>" -g <group_name>
```

## Authentication

Generate a private key on your [App Store Connect account](https://appstoreconnect.apple.com/access/api). Then use e.g. [this script](https://github.com/Blackjacx/Scripts/blob/master/jwt.rb) to derive your JWT token:

```shell
$ jwt.rb <key> <key_id> <issuer_id>
```

## ASC - App Store Connect CLI

This neat tool is able to access the App Store Connect using just the JWT token generated from the private API key. The tool is capable of the following functionality:

### Beta Groups

List id's of all beta groups:

```shell
$ asc -t "Bearer <token>"
```

List id's of beta groups by name:

```shell
$ asc -t "Bearer <token>" -g <group_name>
```