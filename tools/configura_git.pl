#!/usr/bin/perl

my $usuario;
print "Configuración del funcionamiento global del git\n";

print "Introduzca su nombre de usuario en Github [joaquinferrero]: ";
my $usuario = readline;
chomp $usuario;
$usuario ||= 'joaquinferrero';

print "Introduzca su dirección de correo en Github [explorer+git\@joaquinferrero.com]: ";
my $email = readline;
chomp $email;
$email ||= 'explorer+git@joaquinferrero.com';

system('git', 'config', '--global', 'user.name',        $usuario        );
system('git', 'config', '--global', 'user.email',       $email          );
system('git', 'config', '--global', 'push.default',     'tracking'      );
system('git', 'config', '--global', 'pack.threads',     0               );
system('git', 'config', '--global', 'core.autocrlf',    'false'         );
system('git', 'config', '--global', 'apply.whitespace', 'nowarn'        );
system('git', 'config', '--global', 'color.ui',         'auto'          );
system('git', 'config', '--global', 'core.excludesfile',"~/.gitignore"  );
system('git', 'config', '--global', 'alias.up',         'pull --rebase' );

