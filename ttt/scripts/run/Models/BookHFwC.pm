#!/usr/bin/perl

use strict;

package Models::BookHFwC;
use ORM;
extends 'ORM::Model';
with 'TestDBConnectConfigRole';

sub _db_table { 'book' }

has_field 'id' => ( isa => 'Int',
		    description => { primary_key => 1,
				     db_field_type => 'int' } );

has_field 'title' => ( isa => 'Str' );

has_field 'author' => ( isa => 'Models::AuthorHF',
			description => { foreign_key => 'yes' } );

42;
