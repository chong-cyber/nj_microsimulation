#!/usr/bin/perl

#This perl code analyzes the perl output sheets produced after runfrsnj.pl is run, and generates metrics that can be used to estimate the severity of benefit cliffs at the aggregate level, across those data sheets.

use warnings;
# data analysis:
our $csv = $ARGV[0] or die "Please enter a csv to analyze \n";
#By default, the microsimulation spits out the following csv file:
# 'C:\Seth\Bankstreet extra\perl_output.csv'.
# An example of this command is "frs_analysis.pl C:\Seth\perl_output.csv". One thing we need to figure out is how a directory with white spaces can be refeerenced here. TBD.
our $numberofcliffs_across_iterations_total_raw = 0;
our $hh_faces_at_least_one_cliff_total_raw = 0;
our $hh_faces_cliff_at_iter1_total_raw = 0;
our $hh_netresources_iter10_less_than_iter0_total_raw = 0;
our $numberofcliffs_across_iterations_total_weighted = 0;
our $hh_faces_at_least_one_cliff_total_weighted = 0;
our $hh_faces_cliff_at_iter1_total_weighted = 0;
our $hh_netresources_iter10_less_than_iter0_total_weighted = 0;
our $hh_faces_at_least_one_cliff_at_medicaid_loss_total_raw = 0;	
our $hh_faces_at_least_one_cliff_at_medicaid_loss_total_weighted = 0;
our $hh_faces_at_least_one_cliff_at_snap_loss_total_raw = 0;	
our $hh_faces_at_least_one_cliff_at_snap_loss_total_weighted = 0;
our $hh_faces_at_least_one_cliff_at_tanf_loss_total_weighted = 0;
our $hh_faces_at_least_one_cliff_at_tanf_loss_total_raw = 0;
our $hh_faces_at_least_one_cliff_at_ccdf_loss_total_raw = 0;	
our $hh_faces_at_least_one_cliff_at_ccdf_loss_total_weighted = 0;
our $hh_faces_ccdf_copay_cliff_total_raw = 0;
our $hh_faces_ccdf_copay_cliff_total_weighted = 0;
our $hh_faces_at_least_one_cliff_at_tanfandssi_joint_loss_total_raw = 0;	
our $hh_faces_at_least_one_cliff_at_tanfandssi_joint_loss_total_weighted = 0;
our $benefitcliff_size_raw = 0;
our $benefitcliff_size_weighted = 0;
our $population_from_sample_raw = 0;
our $population_from_sample_weighted  = 0;
our $average_benefit_cliff_size_raw = 0;
our $average_benefit_cliff_size_weighted = 0;
our $hh_faces_snap_benefit_cliff_total_raw = 0;	
our $hh_faces_snap_benefit_cliff_total_weighted = 0;



our (@SERIALNO, @WGTP, @net_resources_iter10, @net_resources_iter0, @hh_netresources_iter10_less_than_iter0, @numberofcliffs_across_iterations, @hh_faces_cliff_at_iter1, @hh_faces_at_least_one_cliff, @hh_faces_at_least_one_cliff_at_medicaid_loss, @hh_faces_at_least_one_cliff_at_tanf_loss, @hh_faces_at_least_one_cliff_at_snap_loss, @hh_faces_at_least_one_cliff_at_ccdf_loss, @hh_faces_ccdf_copay_cliff, @hh_faces_at_least_one_cliff_at_tanfandssi_joint_loss, @benefitcliff_size, @hh_faces_snap_benefit_cliff) = ();


print $csv. "\n";
csvtoarrays($csv);
#print join(',', @net_resources_iter1),"\n";

#counting the benefit cliffs, first per household:
#print 'expenses_iter30[0]: '.$expenses_iter30[0]."\n";
#print 'net_resources_iter30[0]: '.$net_resources_iter30[0]."\n";
#print 'expenses_iter30: '.@expenses_iter30."\n";
#print 'net_resources_iter30: '.@net_resources_iter30."\n";

for (my $i = 0; $i <= scalar(@SERIALNO) - 1; $i++) {
	$hh_faces_at_least_one_cliff[$i] = 0;
	if ($net_resources_iter10[$i] < $net_resources_iter0[$i]) {
		$hh_netresources_iter10_less_than_iter0[$i] = 1;
		$hh_netresources_iter10_less_than_iter0_total_raw += 1;
		$hh_netresources_iter10_less_than_iter0_total_weighted += $WGTP[$i];
	}
	
	for (my $j = 1; $j <= 30; $j++) { 
		if ($j == 1) {
			$population_from_sample_raw += 1;
			$population_from_sample_weighted += $WGTP[$i];
		}
		if (${'net_resources_iter'.$j}[$i] < ${'net_resources_iter'.($j-1)}[$i]) {
			$numberofcliffs_across_iterations[$i] += 1;
			$numberofcliffs_across_iterations_total_raw +=1;
			$numberofcliffs_across_iterations_total_weighted += $WGTP[$i];
			$benefitcliff_size[$i] += ${'net_resources_iter'.($j-1)}[$i] - ${'net_resources_iter'.$j}[$i];
			$benefitcliff_size_raw += ${'net_resources_iter'.($j-1)}[$i] - ${'net_resources_iter'.$j}[$i];
			$benefitcliff_size_weighted += $WGTP[$i] * (${'net_resources_iter'.($j-1)}[$i] - ${'net_resources_iter'.$j}[$i]);
			
			if ($j == 1) {
				$hh_faces_cliff_at_iter1[$i] = 1;
				$hh_faces_cliff_at_iter1_total_raw += 1;
				$hh_faces_cliff_at_iter1_total_weighted += $WGTP[$i];
			}
			if ($hh_faces_at_least_one_cliff[$i] == 0) {
				$hh_faces_at_least_one_cliff[$i] = 1;
				$hh_faces_at_least_one_cliff_total_raw +=1;	
				$hh_faces_at_least_one_cliff_total_weighted += $WGTP[$i];	
			}
			
			#For each of these, build in additional conditions that can be used to identify whether program rules within these programs are actually causing these cliffs, or not. Once all likely causes are identifed, the remainder can be considered "combination cliffs" that result more from marginal tax rates within some combination of programs rather than a sudden loss generated by one specific program.
			if ((${'hlth_cov_parent1_iter'.$j}[$i] ne 'Medicaid' &&  ${'hlth_cov_parent1_iter'.($j-1)}[$i] eq 'Medicaid') || (${'hlth_cov_parent2_iter'.$j}[$i] ne 'Medicaid' &&  ${'hlth_cov_parent2_iter'.($j-1)}[$i] eq 'Medicaid')) {
				$hh_faces_at_least_one_cliff_at_medicaid_loss[$i] = 1;
				$hh_faces_at_least_one_cliff_at_medicaid_loss_total_raw +=1;	
				$hh_faces_at_least_one_cliff_at_medicaid_loss_total_weighted += $WGTP[$i];
				#get size of cliff by looking at health expenses + wic + lifeline + ebb?
			}
			if (${'fsp_recd_iter'.$j}[$i] == 0 &&  ${'fsp_recd_iter'.($j-1)}[$i] > 0) {
				$hh_faces_at_least_one_cliff_at_snap_loss[$i] = 1;
				$hh_faces_at_least_one_cliff_at_snap_loss_total_raw +=1;	
				$hh_faces_at_least_one_cliff_at_snap_loss_total_weighted += $WGTP[$i];
				if (${'fsp_recd_iter'.($j-1)}[$i] - ${'fsp_recd_iter'.$j}[$i] > 1000) {
					$hh_faces_snap_benefit_cliff[$i] = 1;
					$hh_faces_snap_benefit_cliff_total_raw +=1;	
					$hh_faces_snap_benefit_cliff_total_weighted += $WGTP[$i];
				} #elsif (${'fsp_recd_iter'.($j-1)}[$i] + - ${'fsp_recd_iter'.$j}[$i] > 1000) { ... eventually, combine this with the meal program losses once the variables are correct here.
			}
			if (${'tanf_recd_iter'.$j}[$i] == 0 &&  ${'tanf_recd_iter'.($j-1)}[$i] > 0) {
				$hh_faces_at_least_one_cliff_at_tanf_loss[$i] = 1;
				$hh_faces_at_least_one_cliff_at_tanf_loss_total_raw +=1;	
				$hh_faces_at_least_one_cliff_at_tanf_loss_total_weighted += $WGTP[$i];
			}
			if (${'tanf_recd_iter'.$j}[$i] == 0 && ${'ssi_recd_iter'.$j}[$i] == 0 && ${'tanf_recd_iter'.($j-1)}[$i] > 0 && ${'ssi_recd_iter'.($j-1)}[$i] > 0) {
				$hh_faces_at_least_one_cliff_at_tanfandssi_joint_loss[$i] = 1;
				$hh_faces_at_least_one_cliff_at_tanfandssi_joint_loss_total_raw +=1;	
				$hh_faces_at_least_one_cliff_at_tanfandssi_joint_loss_total_weighted += $WGTP[$i];
			}			
			if (${'child_care_recd_iter'.$j}[$i] == 0 &&  ${'child_care_recd_iter'.($j-1)}[$i] > 0) {
				$hh_faces_at_least_one_cliff_at_ccdf_loss[$i] = 1;
				$hh_faces_at_least_one_cliff_at_ccdf_loss_total_raw +=1;	
				$hh_faces_at_least_one_cliff_at_ccdf_loss_total_weighted += $WGTP[$i];
			}
			if (${'child_care_recd_iter'.($j-1)}[$i] - ${'child_care_recd_iter'.$j}[$i] > 1000) {
				$hh_faces_ccdf_copay_cliff[$i] = 1;
				$hh_faces_ccdf_copay_cliff_total_raw +=1;	
				$hh_faces_ccdf_copay_cliff_total_weighted += $WGTP[$i];
			}
		}
	}
}
$average_benefit_cliff_size_raw = $benefitcliff_size_raw / $numberofcliffs_across_iterations_total_raw;
$average_benefit_cliff_size_weighted = $benefitcliff_size_weighted / $numberofcliffs_across_iterations_total_weighted;


foreach my $metric (qw(population_from_sample_raw population_from_sample_weighted numberofcliffs_across_iterations_total_raw numberofcliffs_across_iterations_total_weighted hh_faces_at_least_one_cliff_total_raw hh_faces_at_least_one_cliff_total_weighted hh_faces_cliff_at_iter1_total_raw hh_faces_cliff_at_iter1_total_weighted hh_netresources_iter10_less_than_iter0_total_raw hh_netresources_iter10_less_than_iter0_total_weighted hh_faces_at_least_one_cliff_at_medicaid_loss_total_raw hh_faces_at_least_one_cliff_at_medicaid_loss_total_weighted hh_faces_at_least_one_cliff_at_snap_loss_total_raw hh_faces_at_least_one_cliff_at_snap_loss_total_weighted 
hh_faces_snap_benefit_cliff_total_raw 
hh_faces_snap_benefit_cliff_total_weighted 
hh_faces_at_least_one_cliff_at_tanf_loss_total_raw hh_faces_at_least_one_cliff_at_tanf_loss_total_weighted hh_faces_at_least_one_cliff_at_ccdf_loss_total_raw hh_faces_at_least_one_cliff_at_ccdf_loss_total_weighted hh_faces_ccdf_copay_cliff_total_raw hh_faces_ccdf_copay_cliff_total_weighted hh_faces_at_least_one_cliff_at_tanfandssi_joint_loss_total_raw hh_faces_at_least_one_cliff_at_tanfandssi_joint_loss_total_weighted benefitcliff_size_raw benefitcliff_size_weighted average_benefit_cliff_size_raw average_benefit_cliff_size_weighted )) { #
	print $metric.": ".${$metric}."\n";
}

sub csvtoarrays {
	#This will just convert the columns in a csv to arrays, that can be used for later lookups.
	my @table_fields = ();
	my @table_data = ();

	open(CSVLOOKUPTABLE, '<', $_[0]) or die "Couldn't open csv lookup file $!";
	#The zeroeth argument is the csv file.

	while (my $table_line = <CSVLOOKUPTABLE>) {
		my @table_fields = split "," , $table_line;

		#Tihs part is using the names in the first row to create a set of input names, and then using the order of those input names to assign the input values of the subsequent rows.
		if ($. == 1) {
			my $table_listorder = 0;
			foreach my $nameofinput (@table_fields) { 
				$table_data[$table_listorder] = $nameofinput;
				$table_listorder += 1;
			}
		} else {
			#print @table_data;
			our $table_valueorder = 0;
			foreach my $table_cell (@table_fields) {
				#@{$table_data[$table_valueorder]}[0] = 0; #Maybe integrate this into main coding.
				#@{$table_data[$table_valueorder]}[1] = 0; 
				@{$table_data[$table_valueorder]}[$. - 2] = $table_cell; #Maybe integrate this "- 2" into main coding, since it addresses the lack of zeroeth and first elements in the created arrays. 			
				$table_valueorder += 1;	
			}
		}
	}
	close CSVLOOKUPTABLE;
}

