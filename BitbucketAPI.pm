package BitbucketAPI;
use LWP::UserAgent;
use HTTP::Request;
use HTTP::Headers;
use JSON;
use URI;
use URI::Escape;
use MIME::Base64;
use Carp;
use Exporter 'import';

# Export the functions to use in other scripts
our @EXPORT_OK = qw(
    new
    get_repositories
    get_commits
    create_pull_request
    get_project_permissions
    get_extensions
    get_all_users
    get_all_groups
    get_all_projects
    set_permissions
    handle_pagination
);

# Constructor to initialize the object
sub new {
    my ($class, %args) = @_;
    my $self = {
        username => $args{username},
        password => $args{password},
        base_url => $args{base_url} || "https://api.bitbucket.org/2.0",
        ua       => LWP::UserAgent->new,
    };
    $self->{ua}->timeout(30);  # Set timeout for requests (in seconds)
    bless $self, $class;
    return $self;
}

# Helper to send GET requests
sub _get {
    my ($self, $url) = @_;
    my $request = HTTP::Request->new(GET => $url);
    $request->header('Authorization' => 'Basic ' . encode_base64("$self->{username}:$self->{password}"));
    my $response = $self->{ua}->request($request);

    if ($response->is_success) {
        return decode_json($response->decoded_content);
    }
    else {
        carp "GET request failed: " . $response->status_line;
        return undef;
    }
}

# Helper to send POST requests
sub _post {
    my ($self, $url, $data) = @_;
    my $json_data = encode_json($data);
    my $request = HTTP::Request->new(POST => $url, ['Content-Type' => 'application/json'], $json_data);
    $request->header('Authorization' => 'Basic ' . encode_base64("$self->{username}:$self->{password}"));
    my $response = $self->{ua}->request($request);

    if ($response->is_success) {
        return decode_json($response->decoded_content);
    }
    else {
        carp "POST request failed: " . $response->status_line;
        return undef;
    }
}

# Helper to send PUT requests for updating resources
sub _put {
    my ($self, $url, $data) = @_;
    my $json_data = encode_json($data);
    my $request = HTTP::Request->new(PUT => $url, ['Content-Type' => 'application/json'], $json_data);
    $request->header('Authorization' => 'Basic ' . encode_base64("$self->{username}:$self->{password}"));
    my $response = $self->{ua}->request($request);

    if ($response->is_success) {
        return decode_json($response->decoded_content);
    }
    else {
        carp "PUT request failed: " . $response->status_line;
        return undef;
    }
}

# Fetch repositories for a workspace
sub get_repositories {
    my ($self, $workspace, %params) = @_;
    my $url = "$self->{base_url}/repositories/$workspace";
    $url .= "?" . join("&", map { "$_=" . uri_escape($params{$_}) } keys %params) if %params;

    return $self->_get($url);
}

# Get commits for a specific repository
sub get_commits {
    my ($self, $workspace, $repo_slug, %params) = @_;
    my $url = "$self->{base_url}/repositories/$workspace/$repo_slug/commits";
    $url .= "?" . join("&", map { "$_=" . uri_escape($params{$_}) } keys %params) if %params;

    return $self->_get($url);
}

# Create a pull request
sub create_pull_request {
    my ($self, $workspace, $repo_slug, $title, $source_branch, $dest_branch, %params) = @_;
    my $url = "$self->{base_url}/repositories/$workspace/$repo_slug/pullrequests";
    
    my $data = {
        title => $title,
        source => { branch => { name => $source_branch } },
        destination => { branch => { name => $dest_branch } },
        %params,  # Additional parameters (e.g., description, reviewers)
    };
    
    return $self->_post($url, $data);
}

# Get users and groups assigned to a project with permissions
sub get_project_permissions {
    my ($self, $workspace, $project_key) = @_;
    my $url = "$self->{base_url}/workspaces/$workspace/projects/$project_key/permissions";
    
    return $self->_get($url);
}

# Get the value of extensions (e.g., repository hooks, integrations)
sub get_extensions {
    my ($self, $workspace, $repo_slug) = @_;
    my $url = "$self->{base_url}/repositories/$workspace/$repo_slug/hooks";
    
    return $self->_get($url);
}

# Get all users in the workspace
sub get_all_users {
    my ($self, $workspace) = @_;
    my $url = "$self->{base_url}/workspaces/$workspace/members";
    
    return $self->_get($url);
}

# Get all groups in the workspace
sub get_all_groups {
    my ($self, $workspace) = @_;
    my $url = "$self->{base_url}/workspaces/$workspace/groups";
    
    return $self->_get($url);
}

# Get all projects in the workspace
sub get_all_projects {
    my ($self, $workspace) = @_;
    my $url = "$self->{base_url}/workspaces/$workspace/projects";
    
    return $self->_get($url);
}

# Set permissions for users or groups on a project
sub set_permissions {
    my ($self, $workspace, $project_key, $user_or_group, $permission, $type) = @_;
    
    # Validate permission and type
    my %valid_permissions = (read => 1, write => 1, admin => 1);
    my %valid_types = (user => 1, group => 1);
    
    unless ($valid_permissions{$permission} && $valid_types{$type}) {
        carp "Invalid permission or type!";
        return;
    }

    # Construct the URL
    my $url = "$self->{base_url}/workspaces/$workspace/projects/$project_key/permissions/$type/$user_or_group";
    
    # Construct the payload
    my $data = {
        permission => $permission,
    };
    
    return $self->_put($url, $data);
}

# Handle pagination (since Bitbucket paginates responses)
sub handle_pagination {
    my ($self, $url) = @_;
    my $all_data = [];
    while ($url) {
        my $data = $self->_get($url);
        push @$all_data, @$data{qw(values)};
        last unless $data->{next};
        $url = $data->{next};
    }
    return $all_data;
}

1;
