use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
  VERSION   => '0.1',
  PREREQ_PM => {
    'Mojolicious' => '9.17'
  },
  test => {TESTS => 't/*.t'}
);
