# bitrise_automation plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-bitrise_automation)

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-bitrise_automation`, add it to your project by running:

```bash
fastlane add_plugin bitrise_automation
```

## About bitrise_automation

Interact with [Bitrise](https://bitrise.io/) projects from fastlane.

This is useful if you want to interact with Bitrise from your terminal using Fastlane or if you are encapsulating Bitrise builds from another CI (such as Jenkins).

This plugin assumes you already have an app configured on Bitrise and uses a Personal Access Token from Bitrise to communicate with the Bitrise API. Check the [official documentation](https://devcenter.bitrise.io/api/authentication/) to learn how to acquire a token.

### Features

- Trigger a workflow asynchronously (returning immediately after build has been requested)
- Trigger a workflow synchronously (waiting until the build executes and finishes)
- Check build success/failure (exiting with success or failure according to the status on Bitrise)
- Retrieve the list of artifacts from a build
- Download the artifacts produced by a build

### Known issues

- Pagination on API responses is not implemented


## Example

Check out the [example `Fastfile`](fastlane/Fastfile) to see how to use this plugin. Try it by cloning the repo, running `fastlane install_plugins` and `bundle exec fastlane test`.

## Run tests for this plugin

To run both the tests, and code style validation, run

```
rake
```

To automatically fix many of the styling issues, use
```
rubocop -a
```

## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://docs.fastlane.tools/plugins/plugins-troubleshooting/) guide.

## Using _fastlane_ Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://docs.fastlane.tools/plugins/create-plugin/).

## About _fastlane_

_fastlane_ is the easiest way to automate beta deployments and releases for your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).
