#!/usr/bin/perlml
#
use CAM::PDF;
use JSON;

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
my $input = "./acord_140_fillable.pdf";
my $pdf = CAM::PDF->new($input) || die 'error';

my $index = 0;
my $file_index = 0;
my $output = "./out/test$file_index.pdf";
my @files_to_merge = ();

# print "Status: 200\n";
# print "Content-type: text/plain\n\n";

# define the available fields
my @FIELDS = ('effective_date', 'premises_number', 'building_number', 'street_address', 'building_description',
'building_value_soi', 'bv_amount','bv_coins','bv_valuation','bv_causes_of_loss', 'bv_inflation_guard','bv_ded', 'bv_ded_type', 'bv_blkt', 'bv_forms_conditions', 
'rental_income_soi', 'ri_amount','ri_coins','ri_valuation','ri_causes_of_loss', 'ri_inflation_guard','ri_ded', 'ri_ded_type', 'ri_blkt', 'ri_forms_conditions',
'construction_type','stories','basements','year_built','total_area',
'cb_wiring','year_wiring', 'cb_roofing','year_roofing', 'cb_plumbing', 'year_plumbing', 'cb_heating', 'year_heating','roof_type');

foreach (@items) {
    my $item = $_;
    # write out the file to another file, if necessary
    if ($index %2 == 0 && $index > 0) {
        $output = "./out/test$file_index.pdf";
        push(@files_to_merge, $output);
        $pdf->clearAnnotations();
        $pdf->cleanoutput($output);
        $pdf = CAM::PDF->new($input) || die 'error';
        $file_index++;
    }
    
    # set each field value
    foreach my $field (@FIELDS) {
        $ref_field = "$field";
        if ($index %2 == 0) {
            $field =~ s/_2$//;
        } else {
            $field .= "_2";
        }
        $ref_field =~ s/_2$//;
        $pdf->fillFormFields($field => $item->{$ref_field});
    }
    $index++;
}
# write out the last item to another file, if necessary
if ($index % 2 == 1) {
    $output = "./out/test$file_index.pdf";
    push(@files_to_merge, $output);
    $pdf->clearAnnotations();
    $pdf->cleanoutput($output);
}

# merge the generated files into a single file
my $output_file = shift(@files_to_merge);
my $output_pdf = CAM::PDF->new($output_file);
foreach my $input_file (@files_to_merge) {
    my $input_pdf = CAM::PDF->new($input_file);
    $output_pdf->appendPDF($input_pdf);
}
$pdf->clearAnnotations();
$output_pdf->cleanoutput("./out/new.pdf");

# # send it back to the browser
print "Status: 200\n";
print "Content-type: application/pdf\n\n";
open(my $pdf, '<', "./out/new.pdf");
binmode $pdf;
binmode STDOUT;
my $buf;
while (read($pdf, $buf, 1024, 0)) {
    print $buf;
}
close($pdf);

# clean up the temp files
# unlink("./out/new.pdf");
unlink($output_file);
foreach my $file (@files_to_merge) {
    unlink($file);
}
