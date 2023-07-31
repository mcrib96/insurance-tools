#!/usr/bin/perlml
#
use CAM::PDF;
use JSON;
use IO::Compress::Zip qw(zip $ZipError);

local ($buffer);

# Get posted form data
$ENV{'REQUEST_METHOD'} =~ tr/a-z/A-Z/;
if ($ENV{'REQUEST_METHOD'} eq "POST") {
   read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
} else {
   $buffer = $ENV{'QUERY_STRING'};
}

# decode string to json
$FORM = decode_json($buffer) || die $error;

# get the items
my @items = @{$FORM->{"items"}};

# input pdf name
my $input = "./EOI_acord_27_fillable.pdf";
my $pdf = CAM::PDF->new($input) || die 'error';

my $index = 0;
my @files_to_merge = ();

# define the available fields
my @FIELDS = ("date", "insured", "company", "loan_number", "policy_number", "effective_date", "expiration_date", "continue_until_terminated", "location", "description", "basic", "broad", "special", "coverage_information", "amount_of_insurance", "deductible", "remarks", "additional_interest", "additional_insured", "lenders_loss_payable", "loss_payee", "mortgagee");

foreach (@items) {
    my $item = $_;

    # set each field value
    foreach my $field (@FIELDS) {
        $pdf->fillFormFields($field => $item->{$field});
    }
    $pdf->fillFormFields("loan_number_2", $item->{loan_number});
    
    my $address = $item->{location};

    # write out the file to another file, if necessary
    $output = "./out/eoi-$address.pdf";
    push(@files_to_merge, $output);
    $pdf->cleanoutput($output);
    $pdf = CAM::PDF->new($input) || die 'error';

    $index++;
}


# create zip file
unlink("EOI.zip");
my $output = `zip -j EOI.zip ./out/eoi-*.pdf`;

# send it back to the browser
 print "Status: 200\n";
 print "Content-type: application/zip\n\n";
open(my $zip, '<', "./EOI.zip");
binmode $zip;
binmode STDOUT;
my $buf;
while (read($zip, $buf, 1024, 0)) {
    print $buf;
}
close($zip);

# clean up the temp files
foreach my $file (@files_to_merge) {
    unlink($file);
}
