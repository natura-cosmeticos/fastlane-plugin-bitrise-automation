# bitrise_automation plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-bitrise_automation)

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-bitrise_automation`, add it to your project by running:

```bash
fastlane add_plugin bitrise_automation
```

## About bitrise_automation

Interact with [Bitrise](https://bitrise.io/) projects from fastlane. This allows you to trigger a Bitrise workflow and its related information using the [Bitrise API](https://devcenter.bitrise.io/api/api-index/).

This is useful if you want to interact with Bitrise from your terminal using Fastlane or if you are encapsulating Bitrise builds from another CI (such as Jenkins).

This plugin assumes you already have an app configured on Bitrise and uses a Personal Access Token from Bitrise to communicate with the Bitrise API. Check the [official documentation](https://devcenter.bitrise.io/api/authentication/) to learn how to acquire a token.

### Features

- Trigger a workflow asynchronously (returning immediately after build has been requested)
- Trigger a workflow synchronously (waiting until the build executes and finishes)
- Check build success/failure (exiting with success or failure according to the status on Bitrise)
- Retrieve the list of artifacts from a build
- Download the artifacts produced by a build

### Known issues

- For now the only option is to trigger a build via a commit hash. It should be more flexible as Bitrise allows triggering by branch, tag, commit or default strategy.
- The author option to trigger the build is not implemented
- The environments option to trigger the build is not implemented
- Pagination on API responses is not implemented

## Usage

It is recommended to set the `BITRISE_APP_SLUG` and `BITRISE_ACCESS_TOKEN` environment variables to avoid committing those values into your repository.

### trigger_bitrise_workflow
Use this action to trigger a workflow on Bitrise and query its status.

| Key | Description | Environment variable | Default value |
| --- | --- | --- | --- |
| `app_slug` | The app slug of the project on Bitrise | BITRISE_APP_SLUG | |
| `access_token` | The [personal access token](https://devcenter.bitrise.io/api/authentication/) used to call Bitrise API | BITRISE_ACCESS_TOKEN | |
| `workflow` | The name of the workflow to trigger | BITRISE_WORKFLOW | |
| `commit_hash` | The hash of the commit that will be checked out  | BITRISE_BUILD_COMMIT_HASH | |
| `build_message` | A custom message that will be used to identify the build | BITRISE_BUILD_MESSAGE | |
| `wait_for_build` | Whether the action should wait until the build finishes or return immediately after requesting the build | BITRISE_WAIT_FOR_BUILD | false |
| `download_artifacts` | Whether to download or not the produced artifacts | BITRISE_DOWNLOAD_ARTIFACTS | false |

The returned value is a hash containing the information about the build. 

| Hash key | Description |
| --- | --- |
| `status` | The status of the build |
| `build_slug` | The build slug that can be used to identify the build on other actions |
| `build_number` | The build number |
| `build_url` | The URL to the build page on Bitrise |

### bitrise_build_status
Use this action to query the status of a build on Bitrise.

| Key | Description | Environment variable | Default value |
| --- | --- | --- | --- |
| `app_slug` | The app slug of the project on Bitrise | BITRISE_APP_SLUG | |
| `access_token` | The [personal access token](https://devcenter.bitrise.io/api/authentication/) used to call Bitrise API | BITRISE_ACCESS_TOKEN | |
| `build_slug` | The slug that identifies the build on Bitrise | BITRISE_BUILD_SLUG | |

The returned value is a hash containing the information about the build status. 

| Hash key | Description |
| --- | --- |
| `status` | The status of the build: not finished (0), successful (1), failed (2), aborted with failure (3), aborted with success (4) |
| `status_text` | The status text |
| `is_on_hold` | Indicates whether the build has started yet (true: the build hasn't started) |

### bitrise_build_artifacts
Use this action to retrieve information about the artifacts of a build or to automatically download them from Bitrise.

| Key | Description | Environment variable | Default value |
| --- | --- | --- | --- |
| `app_slug` | The app slug of the project on Bitrise | BITRISE_APP_SLUG | |
| `access_token` | The [personal access token](https://devcenter.bitrise.io/api/authentication/) used to call Bitrise API | BITRISE_ACCESS_TOKEN | |
| `build_slug` | The slug that identifies the build on Bitrise | BITRISE_BUILD_SLUG | |
| `download_artifacts` | Whether to download or not the produced artifacts | BITRISE_DOWNLOAD_ARTIFACTS | false |

The returned value is an list of hashes containing the information about the artifacts. If there are no artifacts, it returns an empty list.

| Hash key | Description |
| --- | --- |
| `artifact_type` | The type of the artifact as detected by Bitrise |
| `file_size_bytes` | The size of the artifact in bytes |
| `slug` | The slug that identifies the artifact |
| `title` | The name of artifact |

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
