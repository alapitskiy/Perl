package ALAP::Test::Test2;

use warnings;
use feature "switch";
use feature ":5.10";

 use Net::SMTP::TLS;
 my $mailer = new Net::SMTP::TLS(
        'smtp.fitechsource.com',
        Hello   =>      '[78.111.92.107]',
     #   Port    =>      25, #redundant
        User    =>      'alapitskiy@fitechsource.com',
        Password=>      'EAg1F4HC',
        #Debug => 1,
        );
 $mailer->mail('jerald@fitechsource.com');
 $mailer->to('alapitskiy@fitechsource.com');
 $mailer->data;
 $mailer->datasend("Sent thru TLS!");
 $mailer->dataend;
 $mailer->quit;