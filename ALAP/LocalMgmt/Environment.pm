package ALAP::LocalMgmt::Environment;
use Modern::Perl;

our $root = $ENV{mylink} || 'D:/link';
our $backLinkName = '.source.lnk';

#File containing records for actions;
our $actFile = '.mgmt_actions.bat';

our $undefMode = $ENV{undefMode};

1;