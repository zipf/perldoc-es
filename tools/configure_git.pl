#!/usr/bin/perl
#
#
#  Configure basic settings for git
#

use feature 'say';

say 'Configuration of global work of git';

print 'Write your username in Github: ';
my $user = readline;
chomp $user;

print 'Write email address in Github: ';
my $email = readline;
chomp $email;

system('git', 'config', '--global', 'user.name',	$user		);
system('git', 'config', '--global', 'user.email',	$email		);
system('git', 'config', '--global', 'push.default',	'tracking'	);
system('git', 'config', '--global', 'pack.threads',	0		);
system('git', 'config', '--global', 'core.autocrlf',	'false'		);
system('git', 'config', '--global', 'apply.whitespace',	'nowarn'	);
system('git', 'config', '--global', 'color.ui',		'auto'		);
system('git', 'config', '--global', 'core.excludesfile',"~/.gitignore"	);
system('git', 'config', '--global', 'alias.up',		'pull --rebase'	);
