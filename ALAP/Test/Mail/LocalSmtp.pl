package ALAP::Test::Mail::LocalSmtp;

#use Modern::Perl;
use warnings;
use feature "switch";
use feature ":5.10";

# [192.168.240.106]
 use Net::SMTP;
 use Net::Cmd;
#$smtp = Net::SMTP->new('mx.zero.jp', Hello => "78.111.92.107", Debug => 1);
$smtp = Net::SMTP->new('foggy.com', Hello => "192.168.240.106", Debug => 1);
#$smtp->mail('alap@foggy.com',
# Return => "HDRS", ENVID => "fucka_envid" ) or die "can't set the 'mail' field";

#$smtp->datasend('MAIL FROM:<alap@foggy.com> RET=HDRS ENVID=QQ314159' . "\r\n") or die('fucka1');
#$smtp->datasend('MAIL FROM:<alap@foggy.com>' . "\r\n") or die('fucka1');
#$smtp->command('MAIL FROM:<alap@foggy.com> RET=HDRS ENVID=QQ314159' )->response() == CMD_OK or die('fucka1');
$smtp->command('MAIL FROM:<alap@foggy.com> RET=HDRS' )->response() == CMD_OK or die('fucka1');

#$smtp->datasend('RCPT TO:<alap@foggy.com> NOTIFY=SUCCESS,FAILURE' . "\r\n") or die('fucka2');
#$smtp->datasend('RCPT TO:<alap@foggy.com>' . "\r\n") or die('fucka2');
$smtp->command('RCPT TO:<others@foggy.com> NOTIFY=SUCCESS,FAILURE')->response() == CMD_OK or die('fucka2');

#$smtp->recipient('<alap@foggy.com>',
#{ Notify => ['SUCCESS', 'FAILURE'],
#ORcpt => 'orecip@foggy.com'} ) or die "can't set the 'To' field";
$smtp->data();
#$smtp->datasend('To: alap@foggy.com' . "\n");
#$smtp->datasend('From: alap@foggy.com' . "\n");
#$smtp->datasend("\n");
#$smtp->datasend("A simple test message. Lol\n");
$smtp->dataend();
$smtp->quit;