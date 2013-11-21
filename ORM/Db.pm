use strict;

package ORM::Db;

my $cached_read_dbh = [];
my $cached_write_dbh = [];

use Carp::Assert 'assert';

sub dbh_is_ok
{
	my $dbh = shift;

	my $rv = $dbh;

	if( $dbh )
	{
		unless( $dbh -> ping() )
		{
			$rv = undef;
		}
	}

	return $rv;
}

sub __set_default_if_not_set
{
	my ( $self, $dbh ) = @_;

	unless( &dbh_is_ok( $self -> get_dbh() ) )
	{
		# small racecond :)
		$self -> init( $dbh );
	}
}

sub init
{
	my ( $self, $dbh ) = @_;

	unless( $dbh )
	{
		# non-object call ?
		$dbh = $self;
	}

	if( ref( $dbh ) eq 'HASH' )
	{
		my ( $rdbh, $wdbh ) = @{ $dbh }{ 'read', 'write' };
		assert( $rdbh and $wdbh );

		$cached_read_dbh = ( ref( $rdbh ) eq 'ARRAY' ? $rdbh : [ $rdbh ] );
		$cached_write_dbh = ( ref( $wdbh ) eq 'ARRAY' ? $wdbh : [ $wdbh ] );

	} else
	{
		# $cached_dbh = $dbh;
		# old way
		
		$cached_read_dbh = [ $dbh ];
		$cached_write_dbh = [ $dbh ];
	}
}

sub __get_rand_array_el
{
	my $arr = shift;
	return $arr -> [ 0 ]; # not very random
}

sub get_dbh
{
	my $for_what = shift;

	my $rv = undef;

	if( $for_what eq 'write' )
	{
		$rv = &get_write_dbh();
	} else
	{
		$rv = &get_read_dbh();
	}
	return $rv;

}

sub get_read_dbh
{
	return &__get_rand_array_el( $cached_read_dbh );
}

sub get_write_dbh
{
	return &__get_rand_array_el( $cached_write_dbh );
}

sub dbq
{
	my ( $v, $dbh ) = @_;

	unless( $dbh )
	{
		$dbh = &get_read_dbh();
	}

	return $dbh -> quote( $v );
}

sub getrow
{
	my ( $sql, $dbh ) = @_;

	unless( $dbh )
	{
		assert( 0, 'cant safely fall back to read dbh here' );
	}


	return $dbh -> selectrow_hashref( $sql );

}

sub prep
{
	my ( $sql, $dbh ) = @_;

	unless( $dbh )
	{
		assert( 0, 'cant safely fall back to read dbh here' );
	}

	return $dbh -> prepare( $sql );
	
}

sub doit
{
	my ( $sql, $dbh ) = @_;

	unless( $dbh )
	{
		assert( 0, 'cant safely fall back to read dbh here too' );
	}

	return $dbh -> do( $sql );
}

sub errstr
{
	my $dbh = shift;

	return $dbh -> errstr();
}

sub nextval
{
	my ( $sn, $dbh ) = @_;

	unless( $dbh )
	{
		$dbh = &get_write_dbh();
	}

	my $sql = sprintf( "SELECT nextval(%s) AS newval", &dbq( $sn, $dbh ) );

	assert( my $rec = &getrow( $sql, $dbh ),
		sprintf( 'could not get new value from sequence %s: %s',
			 $sn,
			 &errstr( $dbh ) ) );

	return $rec -> { 'newval' };
}

42;
