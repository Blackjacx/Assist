<!-- <p align="center">
<img src="./icon.png" alt="SHSearchBar" height="128" width="128">
</p> -->

<!-- [![Test](https://github.com/Blackjacx/Assist/actions/workflows/test.yml/badge.svg)](https://github.com/Blackjacx/Assist/actions/workflows/test.yml) -->

[![Twitter Follow](https://img.shields.io/badge/follow-%40blackjacx-1DA1F2?logo=twitter&style=for-the-badge)](https://twitter.com/intent/follow?original_referer=https%3A%2F%2Fgithub.com%2Fblackjacx&screen_name=Blackjacxxx)
[![Version](https://shields.io/github/v/release/blackjacx/Assist?display_name=tag&include_prereleases&sort=semver)](https://github.com/Blackjacx/Assist/releases)
[![Swift Package Manager Compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![Swift Versions](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FBlackjacx%2FAssist%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/Blackjacx/Assist)
[![Platforms](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FBlackjacx%2FAssist%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/Blackjacx/Assist)
[![Xcode 16+](https://img.shields.io/badge/Xcode-16%2B-blue.svg)](https://developer.apple.com/download/)
[![License](https://img.shields.io/github/license/blackjacx/assist.svg)](https://github.com/blackjacx/assist/blob/master/LICENSE)
[![Donate](https://img.shields.io/badge/Donate-PayPal-blue.svg?logo=paypal&style=for-the-badge)](https://www.paypal.me/STHEROLD)

# Intro

App Store Connect API access using your private API key. The great power of this tool is that it can operate on all apps of one or multiple teams (is you wish to), e.g. it is super easy to print the live versions of all of your apps, even across multiple teams:

```sh
asc app-store-versions list -k <key_id_1> \
asc app-store-versions list -k <key_id_2> \
asc app-store-versions list -k <key_id_3>
```

## Features

- **Take control over Apple's App Store Connect API** on the command line, e.g. invite new beta testers, update beta groups, list app versions and much more
- **Generate screenshots from your app** by selecting desired language, device, appearance, and more. All of this works by leveraging your existing test suite
- **Send push notifications** to your user's devices using Apple Push Notification Service or Firebase Cloud Messaging

If you want to see the full potential of the provided tools, you can generate and view the man pages with ease. To do so, please clone the repo and execute the following commands to view the man pages of all included tools (asc, snap, and push):

```shell
# Generate manpages
swift package plugin generate-manual

# copy man page of e.g. asc to a folder where `man` can find it
cp .build/plugins/GenerateManual/outputs/asc/asc.1 /usr/local/share/man/man1/

# view the man page
man asc
```

## Installation

### Via [Homebrew](http://brew.sh/)

```sh
brew tap Blackjacx/asc
brew install asc
```

### Via [Mint](https://github.com/yonaskolb/mint)

Just install Mint using with [Homebrew](https://brew.sh/) via `brew install mint`.

```sh
mint install Blackjacx/Assist
```

You can also run command line tools with mint without installing them first. Mint will automatically clone and install it.

```sh
mint run git@github.com:Blackjacx/Assist.git asc apps
```

### Via Command Line

```sh
git clone https://github.com/blackjacx/assist.git AppStoreConnect
cd AppStoreConnect
swift run asc -h
```

## Documentation ASC (App Store Connect API CLI)

### Authentication

Authentication is handled by the tool itself. The only thing needed is your private API key. Generate one at [App Store Connect account](https://appstoreconnect.apple.com/access/api) and execute the following command which will just store the exact parameters you provide in the user defaults.

```sh
asc keys register -n "name" -k "key-id" -i "issuer-id" -p "path-to-private-key-file"
```

> ⚠️ No key generation performed here. The JWT is just generated on demand when using this tool. If you have multiple keys registered the tool will ask you which one you want to use.

### Sub Commands

Executing one of the following sub commands is as easy as appending it with its parameters to the base command:

```sh
# list all registered API keys
asc api-keys list

# register API key for specific team
asc api-keys register -n "name" -k "key-id" -i "issuer-id" -p "path-to-private-key-file"

# delete API key for specific team
asc api-keys delete -k "key-id"



# list is the default
asc beta-groups

# list only beta groups with a specific name
asc beta-groups -g "group-name"



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

```sh
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

### `beta-groups`

```sh
OVERVIEW: Manage groups of beta testers that have access to one or more builds.

USAGE: asc beta-groups <subcommand>

OPTIONS:
--version               Show the version.
-h, --help              Show help information.

SUBCOMMANDS:
list (default)          Find and list beta testers for all apps, builds, and beta groups.

See 'asc help beta-groups <subcommand>' for detailed help.
```

### `beta-testers`

```sh
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

### `apps`

```sh
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

```sh
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

### `builds`

```sh
OVERVIEW: Manage builds for testers and submit builds for review.

USAGE: asc builds <subcommand>

OPTIONS:
--version               Show the version.
-h, --help              Show help information.

SUBCOMMANDS:
list (default)          Find and list builds for all apps in App Store Connect.

See 'asc help builds <subcommand>' for detailed help.
```

### `bundle-ids`

```sh
OVERVIEW: Manage the bundle IDs that uniquely identify your apps.

USAGE: asc bundle-ids <subcommand>

OPTIONS:
  --version               Show the version.
  -h, --help              Show help information.

SUBCOMMANDS:
  list (default)          Find and list bundle IDs that are registered to your
                          team.
  register                Register a new bundle ID for app development.

  See 'asc help bundle-ids <subcommand>' for detailed help.

```

## Code Documentation

The code documentation for [ASC](https://swiftpackageindex.com/Blackjacx/Assist/develop/documentation/asc), [Push](https://swiftpackageindex.com/Blackjacx/Assist/develop/documentation/push) and [Snap](https://swiftpackageindex.com/Blackjacx/Assist/develop/documentation/snap) is generated and hosted by [Swift Package Index](https://swiftpackageindex.com/) (powered by [DocC](https://developer.apple.com/documentation/docc))

## Contribution

- If you found a **bug**, please open an **issue**.
- If you have a **feature request**, please open an **issue**.
- If you want to **contribute**, please submit a **pull request**.

Thanks to all of you who are part of this:

<a href="https://github.com/blackjacx/Assist/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=blackjacx/Assist" />
</a>

### Release

To release this Swift package the following steps have to be taken:

- Increment the version in `Core.Constants.version`
- Update to the latest shared development files:
  ```shell
  bash <(curl -H -s https://raw.githubusercontent.com/Blackjacx/Scripts/master/frameworks/bootstrap.sh)
  ```
- Run `bundle update` to update all Ruby gems
- Run `swift package update` to update all SPM dependencies
- Commit all changes on `develop` with the message:
  ```
  Release version `x.y.z`
  ```
- Release the new version:
  ```shell
  bundle exec fastlane release framework:"Assist" version:"x.y.z" formula:"blackjacx/formulae/asc"
  ```
- Create and merge the PR from the just created branch for the [Homebrew formula](https://github.com/Blackjacx/homebrew-formulae)
- Post the following on Twitter:

  ```
  Assist (ASC, Push, Snap) release x.y.z 🎉

  ▸ 🚀  Tools asc, snap, push successfully published
  ▸ 📅  Sep 2nd
  ▸ 🌎  https://swiftpackageindex.com/Blackjacx/Assist
  ▸ 🌎  https://github.com/Blackjacx/Assist/releases/latest
  ▸ 👍  Tell your friends!

  #SPM #Automated #Snapshots #Push #Firebase #APNS #ASC #AppStoreConnectAPI
  ```

## Author

[Stefan Herold](mailto:stefan.herold@gmail.com) • [X](https://twitter.com/Blackjacxxx) • [Bluesky](https://bsky.app/profile/blackjacx.bsky.social) • [Mastodon](https://mastodon.social/@blackjacx)

## License

ASC is available under the MIT license. See the [LICENSE](LICENSE) file for more info.

## Star History

<a href="https://star-history.com/#blackjacx/assist&Date">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=blackjacx/assist&type=Date&theme=dark" />
    <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=blackjacx/assist&type=Date" />
    <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=blackjacx/assist&type=Date" />
  </picture>
</a>
