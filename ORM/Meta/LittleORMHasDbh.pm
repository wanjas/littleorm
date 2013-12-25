use strict;

package ORM::Meta::LittleORMHasDbh;
use Moose::Role;
Moose::Util::meta_class_alias( 'LittleORMHasDbh' );

has '_littleorm_rdbh' => ( is => 'rw',
			   isa => 'ArrayRef[DBI::db]' );

has '_littleorm_wdbh' => ( is => 'rw',
			   isa => 'ArrayRef[DBI::db]' );

has '_littleorm_db_connector' => ( is => 'rw',
				   isa => 'ORM::Db::Connector' );

42;
