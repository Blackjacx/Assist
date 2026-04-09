# AGENTS.md

## Coding Conventions

- Write code in Swift language.
- Follow `.config/swiftformat`. Do not introduce formatting styles that conflict with existing output.
- Always use multi-line formatting for lists, arrays, function parameters, etc. and add a comma after the last item.

## Testing instructions

- Prefer testing suites related to the fix. Test full project only if necessary.
- Only return back to me if all works and you fixed potential compile-time or test errors.

## Commits

- Use conventional commit messages, described in https://www.conventionalcommits.org
- Never exceed a commit-title line length of 50.
- Never exceed a commit-body line length of 72.


## Pull Requests

- Always create a PR for changes instead of committing directly to develop.
- Always Use the template `.github/PULL_REQUEST_TEMPLATE.md` for creating PRs.
- Feel free to create multiple commits on the PR during a session.
- Always add a changelog entry in ./changelog with the same title as the PR.
- A changelog entry has the format `* [<pr-number>](<link-to-pr>): <pr-title> - [<author-github-handle>](<author-github-link>).`
- Commit changelog entries separately using using the message `gc -am "chore: add changelog item"`.
- When suggesting new code comments in PRs, always respect a maximum line length of 80 for readability.

## Safety Notes

- Never add secrets, tokens, or credential-dependent logic.
- Avoid writing raw logs to new files unless explicitly required.

## Deployment steps

## Misc

- Always create a new temporary directory using `mktemp -d` when downloading content from the internet, creating temporary files, etc.