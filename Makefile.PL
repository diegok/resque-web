use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
  AUTHOR    => 'Diego Kuperman <diego@freekeylabs.com>',
  ABSTRACT  => 'An improved version off ruby\'s sinatra resque-web on top of resque-perl, mojolicious and vue.',
  VERSION   => '0.1',
  PREREQ_PM => {
    'Mojolicious' => '9.17',
    'Resque'      => '0.42'
  },
  test => {TESTS => 't/*.t'},
  EXE_FILES => ['script/resque-web']
);
