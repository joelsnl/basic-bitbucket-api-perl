
# Basic BitbucketAPI Perl Library
This Perl library provides an easy-to-use interface for interacting with the Bitbucket API. It includes methods for accessing repositories, commits, pull requests, project permissions, extensions, users, groups, and more. It is designed for flexibility and can be easily integrated into various automation tasks or scripts.

## Features
* Get Repositories: Fetch all repositories in a workspace.

* NBSP Get Commits: Retrieve commit history for a repository.

* Create Pull Requests: Easily create a pull request.

* Get and Set Permissions: Fetch and modify user or group permissions for a project.

* Get Extensions: Retrieve hooks and integrations for a repository.

* Get Users and Groups: Fetch all users and groups in a workspace.

* Pagination Handling: Automatically handles paginated responses.

## Installation
1. Clone this repository or download the BitbucketAPI.pm file.
2. Install dependencies:
   * Install LWP::UserAgent (for making HTTP requests).
   * Install JSON (for parsing JSON responses).
   * Install URI and URI::Escape (for URI encoding).
   * Install MIME::Base64 (for basic authentication).
You can install all these packages by entering this command in your terminal of choice (mind you, you need CPAN):
```bash
cpan LWP::UserAgent JSON URI URI::Escape MIME::Base64
```
   
## Usage

```bash
# Initialize the Bitbucket API object
my $bitbucket = BitbucketAPI->new(
    username => 'your_username',
    password => 'your_password'
);

# Set the permission for a user
my $result = $bitbucket->set_permissions(
    'workspace_name', 'PROJECT_KEY', 'user_name', 'write', 'user'
);
print "Permission updated: " . $result->{permission} . "\n";

# Set the permission for a group
my $result = $bitbucket->set_permissions(
    'workspace_name', 'PROJECT_KEY', 'group_name', 'admin', 'group'
);
print "Permission updated: " . $result->{permission} . "\n";

```
