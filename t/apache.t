#!/usr/bin/perl -w

use strict;
use Test::More tests => 21;

BEGIN { use_ok('App::Info::HTTPD::Apache') }

ok( my $apache = App::Info::HTTPD::Apache->new, "Got Object");
isa_ok($apache, 'App::Info::HTTPD::Apache');
isa_ok($apache, 'App::Info');

if ($apache->installed) {
    ok( $apache->installed, "Apache is installed" );
    ok( $apache->name, "Got name" );
    ok( $apache->version, "Got version" );
    ok( $apache->major_version, "Got major version" );
    ok( $apache->minor_version, "Got minor version" );
    ok( $apache->patch_version, "Got patch version" );
    ok( $apache->lib_dir, "Got lib dir" );
    ok( $apache->bin_dir, "Got bin_dir" );
    ok( $apache->so_lib_dir, "Got so lib dir" );
    ok( $apache->inc_dir, "Got inc dir" );
    ok( $apache->httpd_root, "Got httpd root" );
    ok( $apache->magic_number, "Got magic number" );
    $apache->mod_so;
    pass("Can get mod_so");
    is( ref $apache->static_mods, 'ARRAY', "Got static mods" );
    ok( $apache->compile_option('SERVER_CONFIG_FILE'), "Got compile option" );
} else {
    ok( !$apache->installed, "Apache is not installed" );
    ok( !$apache->name, "Don't got name" );
    ok( !$apache->version, "Don't got version" );
    ok( !$apache->major_version, "Don't got major version" );
    ok( !$apache->minor_version, "Don't got minor version" );
    ok( !$apache->patch_version, "Don't got patch version" );
    ok( !$apache->lib_dir, "Don't got lib dir" );
    ok( !$apache->bin_dir, "Don't got bin_dir" );
    ok( !$apache->so_lib_dir, "Don't got so lib dir" );
    ok( !$apache->inc_dir, "Don't got inc dir" );
    ok( !$apache->httpd_root, "Don't got httpd root" );
    ok( !$apache->magic_number, "Don't got magic number" );
    ok( !$apache->mod_so, "Don't got mod_so" );
    ok( !$apache->static_mods, "Don't got static mods" );
    ok( !$apache->compile_option('SERVER_CONFIG_FILE'),
        "Don't got compile option" );
}

ok( $apache->home_url, "Get home URL" );
ok( $apache->download_url, "Get download URL" );
