Pakete
============
[![BuddyBuild](https://dashboard.buddybuild.com/api/statusImage?appID=5714a66524b97e01000a92f0&branch=master&build=latest)](https://dashboard.buddybuild.com/apps/5714a66524b97e01000a92f0/build/latest)
![Language](https://img.shields.io/badge/language-Swift%202-orange.svg)
![License](https://img.shields.io/github/license/paketehq/ios.svg?style=flat)

Pakete is a PH package tracker app for iOS.

## Notes
This open source app will only connect to the staging server.

## How to build

0) Install bundler Gem

```bash
[sudo] gem install bundler
```

1) Clone the repository

```bash
$ git clone https://github.com/paketehq/ios.git
```

2) Install gems and pods

```bash
$ cd ios
$ bundle install
$ bundle exec fastlane oss
```

3) Open the workspace in Xcode

```bash
$ open "Pakete.xcworkspace"
```
4) Compile and run the app in your simulator

# Requirements

* Xcode 7.x
* iOS 8
* Swift 2.x

## Communication

- If you **found a bug**, open an issue.
- If you **have a feature request**, open an issue.
- If you **want to contribute**, submit a pull request.

## License

Pakete-iOS is available under the MIT license. See the LICENSE file for more info.
