use inc::Module::Install;
name 'Plack-Middleware-Headers';
all_from 'lib/Plack/Middleware/Headers.pm';
readme_from 'lib/Plack/Middleware/Headers.pm';

requires 'parent';
requires 'Plack::Middleware';

build_requires 'Test::More';
use_test_base;
auto_include_deps;
author_tests('xt');
auto_set_repository;
WriteAll;
