<!-- <p align="center">
<img src="./icon.png" alt="SHSearchBar" height="128" width="128">
</p> -->

# ASC - App Store Connect API

[![Twitter](https://img.shields.io/twitter/follow/blackjacxxx?label=%40Blackjacxxx)](https://twitter.com/blackjacx)
[![Swift Package Index](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FBlackjacx%2FAssist%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/Blackjacx/Assist)
[![Platform](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FBlackjacx%2FAssist%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/Blackjacx/Assist)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://github.com/Blackjacx/Assist/blob/develop/LICENSE?raw=true)
<img alt="Xcode 12.0+" src="https://img.shields.io/badge/Xcode-12.0%2B-blue.svg"/>
<a href="https://www.paypal.me/STHEROLD"><img alt="Donate" src="https://img.shields.io/badge/Donate-PayPal-blue.svg"/></a>

App Store Connect API access using your private API key. The tool is in an early stage but already quite versatile 🥳

> ⚠️ Currently this repository contains a collection of command line tools. This is the reason why it is called "Assist". But in future I want to focus on the App Store Connect API here.

## General

You can quickly try it out by using [Mint](https://github.com/yonaskolb/Mint). Just install it with [Homebrew](https://brew.sh/) via `brew install mint`. Then you can run each command by letting mint automatically clone and install it. Just prefix each command below with `mint run git@github.com:Blackjacx/Assist.git`, e.g.:

```shell
$ mint run git@github.com:Blackjacx/Assist.git asc groups -g <group_name>
```

## Authentication

Authentication is handled by the tool itself. The only thing needed is your private API key. Generate one at [App Store Connect account](https://appstoreconnect.apple.com/access/api) and execute the following command which will just store the exact parameters you provide in the user defaults. 

```shell
asc api-keys register -n "name" -k "key-id" -i "issuer-id" -p "path-to-private-key-file"
```

> ⚠️ No key generation performed here. The JWT is just generated on demand when using this tool. If you have multiple keys registered the tool will ask you which one you want to use.

## Sub Commands

Executing one of the following sub commands is as easy as appending it with its parameters to the base command:

```shell
# list all registered API keys
asc api-keys list

# register API key for specific team
asc api-keys register -n "name" -k "key-id" -i "issuer-id" -p "path-to-private-key-file"

# delete API key for specific team
asc api-keys delete -k "key-id"



# list is the default 
asc groups                                

# list only groups with a specific name
asc groups -g "group-name"



# list apps of your team
asc apps



# add beta tester to all groups matching `group-name`
asc beta-testers add -e "john@doe.com" -n "John" -l "Doe" -g "group-name"

# add beta tester to all groups matching all specified group names
asc beta-testers add -e "john@doe.com" -n "John" -l "Doe" -g "group-name-1" -g "group-name-2"



# delete beta tester from all groups found
asc beta-testers delete -e "john@doe.com"



# lists all your teams apps with their live version or if not live with their current status
asc app-store-versions
```

### `api-keys`

```
OVERVIEW: Lists, registers and deletes App Store Connect API keys on your Mac.

USAGE: asc api-keys <subcommand>

OPTIONS:
  --version               Show the version.
  -h, --help              Show help information.

SUBCOMMANDS:
  list (default)          List locally stored App Store Connect API keys keys.
  register                Registers App Store Connect API keys locally.
  delete                  Delete locally stored App Store Connect API keys.

  See 'asc help api-keys <subcommand>' for detailed help.
```

### `beta-testers`

```
OVERVIEW: Manage people who can install and test prerelease builds.

USAGE: asc beta-testers <subcommand>

OPTIONS:
  --version               Show the version.
  -h, --help              Show help information.

SUBCOMMANDS:
  list (default)          Find and list beta testers for all apps, builds, and
                          beta groups.
  invite                  Send or resend an invitation to a beta tester to test
                          specified apps.
  add                     Create a beta tester assigned to a group, a build, or
                          an app.
  delete                  Remove a beta tester's ability to test all or
                          specific apps.

  See 'asc help beta-testers <subcommand>' for detailed help.

```

### `groups`

```
OVERVIEW: Manage groups of beta testers that have access to one or more builds.

USAGE: asc groups <subcommand>

OPTIONS:
  --version               Show the version.
  -h, --help              Show help information.

SUBCOMMANDS:
  list (default)          Find and list beta testers for all apps, builds, and beta groups.

  See 'asc help groups <subcommand>' for detailed help.
```

### `apps`

```
OVERVIEW: Manage your apps in App Store Connect.

USAGE: asc apps <subcommand>

OPTIONS:
  --version               Show the version.
  -h, --help              Show help information.

SUBCOMMANDS:
  list (default)          Find and list apps added in App Store Connect.

  See 'asc help apps <subcommand>' for detailed help.

```

### `app-store-versions`

```
OVERVIEW: Manage versions of your app that are available in App Store.

USAGE: asc app-store-versions <subcommand>

OPTIONS:
  --version               Show the version.
  -h, --help              Show help information.

SUBCOMMANDS:
  list (default)          Get a list of all App Store versions of an app across
                          all platforms.

  See 'asc help app-store-versions <subcommand>' for detailed help.

```

## Contribution

- If you found a **bug**, please open an **issue**.
- If you have a **feature request**, please open an **issue**.
- If you want to **contribute**, please submit a **pull request**.

## Author

[Stefan Herold](mailto:stefan.herold@gmail.com) • 🐦 [@Blackjacxxx](https://twitter.com/Blackjacxxx)

## License

ASC is available under the MIT license. See the [LICENSE](LICENSE) file for more info.