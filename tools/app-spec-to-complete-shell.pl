use v5.10;
use strict; use warnings;

use App::Spec;
use YAML::XS;
use XXX;

our ($data, $name, $shell_file_handle, $indent, $meta, $has_options);
my $types = {
  flag => undef,
  integer => 'int',
  string => 'str',
  file => 'file',
  dir => 'dir',
};

sub main {
  my ($spec) = @_;

  # Use App::Spec to load the completion data into a consistent format:
  local $data = clean(App::Spec->read($spec));

  $meta = YAML::XS::LoadFile('comp/Meta');

  $name = get('name', 1);

  write_from();

  write_head();

  write_name();

  write_options();

  write_commands() || write_args();

  write_foot();

  # Ignore these fields
  get($_) for qw(abstract class markup plugins plugins_by_type);

  assert_all_done();
}

sub write_from {
  print <<"...";
# From https://github.com/perlpunk/shell-completions/blob/master/specs/$name.yaml
#
# shellcheck shell=sh disable=2102
...
}

sub write_head {
  print <<"...";

CompleteShell v0.2
...
}

sub write_name {
  my $desc = get('title', 1);
  $desc = get_desc($desc);
  say '';
  say fmt('N', $name, 'v0.0.0', $desc);

  if (my $tags = $meta->{$name}->{tags}) {
    say '';
    say fmt('M', 'tags', $tags);

  } else {
    warn "The '$name' command has no tags in 'comp/Meta'";
  }
}

sub write_options {
  $has_options = 0;
  my $options = get('options') or return;
  $has_options = 1;

  say '' unless $indent;

  for (@$options) {
    my $o = get_option($_);

    my @words = (
      'O',
      $o->{short},
      $o->{long},
      $o->{type},
      $o->{desc},
    );
    unshift @words, ' ' if $indent;
    say fmt(@words);
  }
}

sub write_args {
  my $blank_line = $has_options;
  $has_options = 0;
  my $args = get('parameters') or return;

  say '' if $blank_line;

  for my $arg (@$args) {
    local $data = clean($arg);

    my $type = get_type();

    assert_all_done();

    my @words = ('A', $type);
    unshift @words, ' ' if $indent;

    say fmt(@words);
  }
}

sub write_commands {
  my $commands = get('subcommands') or return;

  local $indent = 1;

  for my $key (sort keys %$commands) {
    local $data = clean($commands->{$key});

    my $class = get('class') || '';
    next if $class eq 'App::Spec::Plugin::Help';

    my $name = get('name');
    next if $name eq '_meta';

    my $desc = get('summary') or XXX $data;
    $desc = get_desc($desc);

    say '';

    say fmt('C', $name, $desc);

    write_options();

    write_args();

    get($_) for qw(markup plugins_by_type subcommands);

    assert_all_done();
  }
}

sub write_foot {
  print <<'...';

# vim: set ft=sh:
...
}

sub write_shell {
  my ($func_name, $func_code) = @_;

  if (not $shell_file_handle) {
    my $file = "comp/$name.sh";
    open $shell_file_handle, '>', $file
      or die "Can't open '$file' for output: $!";

    say $shell_file_handle '# shellcheck shell=bash';
  }

  $func_code =~ s/^/  /gm;
  print $shell_file_handle <<"...";

$func_name() {
$func_code

  true
}
...
}

sub get_type {
  my $type;

  if (my $enum = get('enum')) {
    get('type') =~ /^(string|integer)$/ or die;

    $type = '[' . join(',', @$enum) . ']';

  } elsif ($data->{completion}) {
    $type = lc(get('name', 1));
    my $completion = get('completion', 1);
    local $data = clean($completion);
    my $code = get('command_string', 1);
    assert_all_done();
    write_shell($name, $code);

  } elsif ($data->{type}) {
    $type = get('type');
    die $type unless exists $types->{$type};
    $type = $types->{$type};

  } else {
    XXX $data;
  }

  get($_) for qw(name summary type);

  $type .= '...' if get('multiple');

  return $type || undef;
}

sub get_option {
  my $spec = shift;
  my $o = {};

  local $data = clean($spec);

  my $name = $data->{name};
  if (length($name) == 1 and not $data->{alias}) {
    $o->{short} = $name;
  } else {
    $o->{long} = $name;
    my $alias = get('aliases');
    if ($alias and length($alias->[0]) == 1) {
      $o->{short} = $alias->[0];
    }
  }

  $o->{desc} = get('summary');
  $o->{type} = get_type();
  get('default');

  assert_all_done();

  $o->{long} &&= "--$o->{long}";
  $o->{short} &&= "-$o->{short}";
  $o->{type} &&= "=$o->{type}";
  $o->{desc} &&= get_desc($o->{desc});

  return $o;
}

sub get_desc {
  my ($text) = @_;
  return unless $text;

  if ($text =~ /'/) {
    $text =~ s/\\/\\\\/g;
    $text =~ s/"/\\"/g;
    $text = ucfirst($text);
    return qq{.."$text"};

  } else {
    $text = ucfirst($text);
    return qq{..'$text'};
  }
}

sub fmt {
  my $text = shift(@_) || '';

  for my $str (@_) {
    next unless defined $str;
    if ($str =~ /^\.\./) {
      $text = sprintf("%-20s  %s", $text, $str);
    } else {
      $text .= " $str";
    }
  }

  die if $text =~ /\n/;

  return $text;
}

# We want to know that we've handled every field given to us, so delete the
# empty values.
sub clean {
  my ($data) = (@_);

  my $hash = { %$data };

  for my $key (keys %$hash) {
    delete $hash->{$key} unless $hash->{$key};
    delete $hash->{$key} if ref($hash->{$key}) eq 'ARRAY'
      and not @{$hash->{$key}};
  }

  return $hash;
}

# Get a value from the current context and delete it so we know we've handled
# it.
sub get {
  my ($key, $required) = (@_);

  if (not exists $data->{$key} and $required) {
    warn "Can't find value for '$key' in:\n";
    XXX $data;
  }

  my $value = delete $data->{$key};

  return $value;
}

# Die if the current context is not empty. We call this after we think we've
# handled all the fields.
sub assert_all_done {
  die "Data not empty:\n" . ZZZ($data) if %$data;
}

main @ARGV;
