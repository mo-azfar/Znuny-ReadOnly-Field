# --
# Copyright (C) 2024 mo-azfar, https://github.com/mo-azfar
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package Kernel::Output::HTML::FilterContent::ReadOnlyField;

use strict;
use warnings;
use utf8;

our @ObjectDependencies = (
    'Kernel::System::Web::Request',
    'Kernel::Output::HTML::Layout',
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    my $Action = $ParamObject->GetParam( Param => 'Action' );

    return 1 if !$Action;
    return 1 if !$Param{Templates}->{$Action};
    return 1 if !@{ $Param{FieldName} };

    my $FieldNames = join "', '", @{ $Param{FieldName} };

    my $JS = <<"EOF";
        <script type="text/javascript">
        \$(document).ajaxComplete(function (Event, XHR, Settings) {

            var FieldNames = [ '$FieldNames' ];

            FieldNames.forEach(function (FieldName) {
                var Element = \$('#' + FieldName);

                if ( Element.length && Element.val() ) {
                    if (Element.is('select')) {
                        Element.prop('disabled', true);
                    }
                    else if (Element.is('input')) {
                        Element.prop('readonly', true);
                    }
                }
            });
        });
        </script>
EOF

    ${ $Param{Data} } =~ s{</body}{$JS</body};

    return 1;

}

1;
