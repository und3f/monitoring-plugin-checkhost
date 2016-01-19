use inc::Module::Install;

name 'Monitoring-Plugin-CheckHost';
all_from 'lib/Monitoring/Plugin/CheckHost.pm';
install_script 'script/checkhost_ping';
install_script 'script/checkhost_http';

no_index 'nagios-checkhost.cfg';

requires 'Carp';
requires 'List::Util';
requires 'LWP::UserAgent';
requires 'Monitoring::Plugin';
requires 'Test::More' => '0.88';
requires 'Try::Tiny';

tests 't/*.t';

resources
  bugtracker => 'https://github.com/und3f/monitoring-plugin-checkhost/issues',
  repository => 'https://github.com/und3f/monitoring-plugin-checkhost';

WriteAll;
