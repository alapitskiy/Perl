package ALAP::Test::Test1;

#use Modern::Perl;
use warnings;
use feature "switch";
use feature ":5.10";

# [192.168.240.106]
 use Net::SMTP;
#$smtp = Net::SMTP->new('mx.zero.jp', Hello => "78.111.92.107", Debug => 1);
$smtp = Net::SMTP->new('mx.zero.jp', Hello => "etheric.net", Debug => 1);
$smtp->mail('<allapitskiy@fitechsource.com>');
$smtp->recipient('<alapitskiy@fitechsource.com>') or die "can't set the 'To' field";
$smtp->data();
$smtp->datasend('To: alapitskiy@fitechsource.com' . "\n");
$smtp->datasend("\n");
$smtp->datasend("A simple test message\n");
$smtp->dataend();
$smtp->quit;