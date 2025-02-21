<!-- omit in toc -->
# Contributing to Frankly

Thanks for your interest in contributing to Frankly!

We encourage and value all contributions. See the [Table of Contents](#table-of-contents) for ways to help and contribution guidelines. Reading the relevant sections beforehand will facilitate a smoother process for everyone. We look forward to your contributions. 🎉

> Like the project but don't have time to contribute? There are other easy ways to support Frankly!
> - Star the project
> - Post on social media about it
> - Refer this project in your project's readme
> - Mention the project at local meetups and tell your friends/colleagues

<!-- omit in toc -->
## Table of Contents

- [Asking Questions](#asking-questions)
- [Reporting Bugs](#reporting-bugs)
- [Contributing](#contributing)
  - [Getting Started](#getting-started)
  - [What to Work On](#what-to-work-on)
- [Styleguides](#styleguides)
  - [Commit Messages](#commit-messages)
- [Code of Conduct](#code-of-conduct)

## Asking Questions

> Before you ask a question, please search both the [Help Center](https://rebootingsocialmedia.notion.site/Frankly-Help-Center-23b4f9a120a344d4af2b2ce44b2ae229) and our existing [Issues](https://github.com/berkmancenter/frankly/issues) to see if your question has been addressed.

If you still have a question or need clarification, we recommend the following:

- Open an [Issue](https://github.com/berkmancenter/frankly/issues/new/choose).
- Provide as much context as you can about what you're running into.
- Provide project and platform versions (nodejs, npm, etc), depending on what seems relevant.

We will address the issue as soon as possible.

## Reporting Bugs
> ### Sensitive Bugs <!-- omit in toc -->
> Never report security related issues, vulnerabilities or bugs including sensitive information to the issue tracker, or elsewhere in public. Instead, please send sensitive bugs by email to <support@frankly.org>.

<!-- omit in toc -->
### Before Submitting a Bug Report

- Check [Github Issues](https://github.com/berkmancenter/frankly/issues?q=label%3Abug) to make sure the bug has not already been reported.
- Ensure the bug is not an error on your end. For example, ensure you are using the latest version of Frankly and that you are using compatible environment components/versions. (See [Troubleshooting](https://rebootingsocialmedia.notion.site/Troubleshooting-c6f922b816a742a9bba4bf000e84565d) in the [Frankly Help Center](https://rebootingsocialmedia.notion.site/Frankly-Help-Center-23b4f9a120a344d4af2b2ce44b2ae229).)
- Investigate thoroughly so that you can describe the issue in detail in your report.

<!-- omit in toc -->
### Submitting Your Report

Bug reports can be submitted to [GitHub Issues](https://github.com/berkmancenter/frankly/issues/new/choose). Please select the appropriate issue type, use a descriptive and concise title, and follow the prompts.

Once it's filed, a team member will attempt to reproduce the issue with your provided steps. If reproduced, the project team will triage accordingly. If there are no reproduction steps or no obvious way to reproduce the issue, the team will ask you for clarification. Bugs will not be addressed until they are reproduced by a team member.

## Contributing

> ### Legal Notice <!-- omit in toc -->
> When contributing to this project, you must agree that you have authored 100% of the content, that you have the necessary rights to the content, and that the content you contribute may be provided under the project licence.

### Getting Started
We would love for you to contribute to Frankly! To set up your development environment, please refer to our [README](https://github.com/berkmancenter/frankly/blob/staging/README.md). The instructions there should allow you to run Frankly locally on your machine.

If the feature you want to work on requires third-party services (e.g. Agora for video calling, or Mux for running livestreams), please follow the instructions in the README to set up your own accounts. The free tiers of these services should allow for testing development use cases.

If you have any questions about the instructions, please feel free to [submit an issue](https://github.com/berkmancenter/frankly/issues/new). We welcome any suggestions for improvements to the README from contributors, especially as a Pull Request to the documentation itself.

### What to Work On
You can see what the Frankly team is working on in the [Frankly Public Workstream](https://github.com/orgs/berkmancenter/projects/3). We would **love** your help, and that's the place to start.

Look for anything in our backlog with the [help welcome](https://github.com/orgs/berkmancenter/projects/3/views/1?filterQuery=-status%3A%22Won%27t+Do%22%2C%22Consider+Later%22+label%3A%22help+welcome%22) label especially. We also have a [good first issue](https://github.com/orgs/berkmancenter/projects/3/views/1?filterQuery=-status%3A%22Won%27t+Do%22%2C%22Consider+Later%22+label%3A%22good+first+issue%22+) label for first-time contributors.

## Styleguides
### Commit Messages
We prefer longform commit messages where possible! Check out [this article](https://meedan.com/post/how-to-write-longform-git-commits-for-better-software-development) for more on longform commits.

**Not ideal:**

```
Fix our multiply function
```

**Ideal:**

```
Fix our multiply function
Swapped `/` for `*`. Apparently multiplication and division are two different
things! We want to do
[multiplication](https://en.wikipedia.org/wiki/Multiplication) because
otherwise everything breaks. I did some research and found out that `*`
means "multiply" in most popular programming languages.

In the future we could also consider dividing by the inverse of an operand,
in case we move to a programming langauge that doesn't support multiplication.

Fixes #1234.
```

## Code of Conduct

This project and everyone participating in it is governed by the
[Frankly Code of Conduct](https://github.com/berkmancenter/frankly/blob/staging/CODE_OF_CONDUCT.md).
By participating, you are expected to uphold this code. Please report unacceptable behavior
to <support@frankly.org>.

<!-- omit in toc -->
## Attribution
This guide is based on the [contributing.md generator](https://contributing.md/generator).
