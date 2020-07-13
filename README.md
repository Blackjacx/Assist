# Assist

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
# The path to my ruby script (or any script) that generates the JWT token based on the other environment variables
ASC_AUTH_JWT_SCRIPT_PATH="~/dev/scripts/jwt.rb"
```

You can just download my [JWT ruby script](https://github.com/Blackjacx/Scripts/blob/master/jwt.rb), put it somewhere on your disk and specify it's path in the respective environment variable.

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

#### Users

The following is currently under construction:
- adding beta testers
- removing beta testers