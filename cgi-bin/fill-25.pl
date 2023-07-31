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
my $input = "./COI_acord_25_fillable.pdf";
my $pdf = CAM::PDF->new($input) || die 'error';

my $index = 0;
my @files_to_merge = ();

# define the available fields
my @FIELDS = ("date", "insured", "insurer_a", "insurer_a_naic", "insurer_b", "insurer_b_naic", 
    "insurer_c", "insurer_c_naic", "insurer_d", "insurer_d_naic", "insurer_e", 
    "insurer_e_naic", "insurer_f", "insurer_f_naic", "cl_instr_letter", "claims_made",
    "occur", "cl_addl_insd", "cl_subr_wvd", "cl_policy_number", "cl_policy_eff", 
    "cl_policy_exp", "cl_each_occurrence", "cl_damaged_to_rented", "cl_med_exp", 
    "cl_personal_adv_injury", "cl_general_aggregate", "cl_products_comp", "cl_agg_limit_per_policy", 
    "cl_agg_limit_per_project", "cl_agg_limit_per_location", "instr_ltr_2", "umbrella_liab",
    "umbrella_occur", "excess_liab", "excess_claims_made", "excess_policy_number", "excess_policy_eff",
    "excess_policy_exp", "excess_each_occurrence", "excess_aggregate", "location", "certificate_holder");

foreach (@items) {
    my $item = $_;

    # set each field value
    foreach my $field (@FIELDS) {
        $pdf->fillFormFields($field => $item->{$field});
    }
    
    my $address = $item->{location};

    # write out the file to another file, if necessary
    $output = "./out/coi-$address.pdf";
    push(@files_to_merge, $output);
    $pdf->cleanoutput($output);
    $pdf = CAM::PDF->new($input) || die 'error';

    $index++;
}


# create zip file
unlink("COI.zip");
my $output = `zip -j COI.zip ./out/coi-*.pdf`;

# send it back to the browser
 print "Status: 200\n";
 print "Content-type: application/zip\n\n";
open(my $zip, '<', "./COI.zip");
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
