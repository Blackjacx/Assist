<!-- <p align="center">
<img src="./icon.png" alt="SHSearchBar" height="128" width="128">
</p> -->

<h1 align="center">Assist</h1>

<p align="center">
  <a href="https://twitter.com/blackjacxxx"><img alt="Twitter Follow" src="https://img.shields.io/twitter/follow/blackjacxxx?label=%40Blackjacxxx"/></a>
  <img alt="Xcode 11.0+" src="https://img.shields.io/badge/Xcode-11.0%2B-blue.svg"/>
  <img alt="Swift 5.2+" src="https://img.shields.io/badge/Swift-5.3%2B-orange.svg"/>
  <a href="https://github.com/Blackjacx/SHSearchBar/blob/develop/LICENSE?raw=true">
    <img alt="License" src="https://img.shields.io/cocoapods/l/SHSearchBar.svg?style=flat"/>
  </a>
  <a href="https://www.paypal.me/STHEROLD"><img alt="Donate" src="https://img.shields.io/badge/Donate-PayPal-blue.svg"/></a>
</p>

Assistive command line tools (listed below), implemented in Swift.

## General

You can quickly try each tool using [Mint](https://github.com/yonaskolb/Mint). Just install it with [Homebrew](https://brew.sh/) via `brew install mint`. Then you can run each command by letting mint automatically clone and install it. Just prefix each command below with `mint run git@github.com:Blackjacx/Assist.git`, e.g.:

```shell
$ mint run git@github.com:Blackjacx/Assist.git asc groups -g <group_name>
```

## Authentication

Generate a private key on your [App Store Connect account](https://appstoreconnect.apple.com/access/api). Then make sure to specify the following environment variables which the script uses:

```shell
# The absolute path to your Key file with the ending .p8
ASC_AUTH_KEY=""
# The key ID obtained from App Store Connect
ASC_AUTH_KEY_ID=""
# The issuer ID obtained from App Store Connect
ASC_AUTH_KEY_ISSUER_ID=""
```

The tool uses the [Swift-JWT](https://github.com/IBM-Swift/Swift-JWT) package to generate and sign the access token.

## Tools

### ASC - App Store Connect CLI

Access the App Store Connect API using just the JWT generated from the private API key. The tool is capable of the following functionality:

#### Beta Groups

By calling `asc groups [id | attributes | name]` you can list the respective properties of the found groups.

##### List all beta group IDs

```shell
$ asc groups
```

##### List beta group IDs by name

```shell
$ asc groups -g <group_name>
```

#### Apps

By calling `asc groups [id | attributes | name | bundleId | locale]` you can list the respective properties of the found apps.

##### List all app IDs

```shell
$ asc apps
```

#### BetaTesters

##### List beta testers by firstName, lastName and/or email

```shell
$ asc asc beta-testers list [-f "John"] [-l "Doe"] [-e "john@doe.com"]
```

##### Add beta tester to one or more groups

```shell
$ asc asc beta-testers add -f "John" -l "Doe" -e "john@doe.com" -g <"gid1" "gid2" "gid3">
```

##### Delete beta tester from one or more groups

```shell
$ asc asc beta-testers delete -e "john@doe.com" -g <"gid1" "gid2" "gid3">
```

##### Add App Store Connect User to one or more groups

coming soon...

##### Remove App Store Connect User from one or more groups

coming soon...