package Catalyst::View::GD::Barcode;

use strict;

our $VERSION = '0.01';

my($Revision) = '$Id: Barcode.pm,v 1.1 2006/02/21 06:21:10 yanagisawa Exp $';

=head1 NAME

Catalyst::View::GD::Barcode - GD::BarcodeをCatalystのViewで簡単に利用します。

=head1 SYNOPSIS

バーコードにする文字列を格納します。
 $c->stash->{'barcode_string'} = '123456';

バーコードの種類を選択します。指定しない場合は、EAN13
 $c->stash->{'barcode_type'} = 'NW7';

それ以外のGD::Barcodeのオプションを格納します。
 $c->stash->{'barcode_option'} = {NoText => 1}

実際に出力します。
 $c->forward('Catalyst::View::GD::Barcode');

=head1 DESCRIPTION

Redirect for Catalyst used easily is offered.

=head1 METHODS

=over 2

=item gen_barcoed

GD::Barcodeを使用して、バーコードを作ります。
バーコードの文字列とtypeを指定するだけでそれ以外のことを考える必要はありません。
正しい処理ができなかった場合は、text/plainで文字列を返します。

=back

=cut


sub gen_barcode {
    my $self = shift;
    my $c = shift;
    my $str =  $c->stash->{'barcode_string'};
    my $type = $c->stash->{'barcode_type'};
    my $opt = {};
    if($str) {
	##### set option
	$opt = $c->stash->{'barcode_option'};
	$type ||= 'EAN13';
	my($Barcode);
	my $m_name = "GD::Barcode::$type";
	eval("use $m_name;");
	if($@) {
	    die "Do not install Barcord module $m_name";
	}
	if ($type eq 'EAN13') {
	    $Barcode = $m_name->new($self->calc_checkdigit(sprintf('%012s', $str)));
	} elsif($type eq 'Code39') {
	    $Barcode = $m_name->new('*'.$str.'*');
	} else {
	    $Barcode = $m_name->new($str);
	}
	unless($Barcode) {
	    $c->res->header('Content-Type' => 'text/plain');
	    return $GD::Barcode::errStr;
	} else {
	    $c->res->header('Content-Type' => 'image/png');
	    return $Barcode->plot(%{$opt})->png();
	}
    }else{
	$c->res->header('Content-Type' => 'image/png');
	return 'No Barcode String';
    }
}

=over 2

=item process

$c->res->body()にバーコードの文字列を詰め込みます。

=back

=cut

sub process{
    my $self = shift;
    my $c = shift;
    $c->res->body($self->gen_barcode($c));
    return 1;
}

=over 2

=item calc_checkdigit

チェックディジットを計算して返します。

=back

=cut

sub calc_checkdigit {
    my $self = shift;
    my $str = shift;
    my($checkdigit) = (10 - ((((substr($str, 1, 1) + substr($str, 3, 1) + substr($str, 5, 1) + substr($str, 7, 1) + substr($str, 9, 1) + substr($str, 11, 1)) * 3) + (substr($str, 0, 1) + substr($str, 2, 1) + substr($str, 4, 1) + substr($str, 6, 1) + substr($str, 8, 1) + substr($str, 10, 1))) % 10)) % 10;
    if (length($str) == 12) {
	$str .= $checkdigit;
    } elsif (length($str) == 13) {
	substr($str, 12, 1) = $checkdigit;
    }
    return $str;
}

=head1 SEE ALSO

L<Catalyst>

=head1 AUTHOR

Toshimitu Yanagisawa, C<yanagisawa@shanon.co.jp>

=head1 COPYRIGHT AND LICENSE

This program is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
