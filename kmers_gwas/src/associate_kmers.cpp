///
///      @file  associate_kmers.cpp
///     @brief  Loading and correlating phenotype to the presence of k-mers
///
/// 	We will load a phenotype data and a table of k-mers presence absence.
/// 	The program will output the interesting k-mers as well as their presence-absence
/// 	information to output files.
///
///    @author  Yoav Voichek (YV), yoav.voichek@tuebingen.mpg.de
///
///  @internal
///    Created  07/17/18
///   Compiler  gcc/g++
///    Company  Max Planck Institute for Developmental Biology Dep 6
///  Copyright  Copyright (c) 2018, Yoav Voichek
///
/// This source code is released for free distribution under the terms of the
/// GNU General Public License as published by the Free Software Foundation.
///=====================================================================================
///

#include "kmer_general.h"
#include "kmers_multiple_databases.h"
#include "best_associations_heap.h"

#include <iostream>
#include <utility> //std::pair

#include "CTPL/ctpl_stl.h" //thread pool library
#include <cxxopts/include/cxxopts.hpp>

using namespace std;

int main(int argc, char* argv[]) {
	cxxopts::Options options("associate_kmers", "Associate k-mers presence/absence pattern with a phenotype of interest");
	try
	{
		options.add_options()
			("p,phenotype_file", "phenotype file name", cxxopts::value<string>())
			("b,base_name", "base name to use for all files", cxxopts::value<string>())
			("o,output_dir", "where to save output files", cxxopts::value<string>()->default_value("."))
			("kmers_table",	"Presence/absemce k-mer file", cxxopts::value<string>())
			("n,best", "Number of best k-mers to report", cxxopts::value<size_t>()->default_value("1000000"))
			("first_phenotype_best", "if provided will save a different number of k-mers for the first phenotype", cxxopts::value<size_t>())
			("batch_size", "Loading only part of the presence absence info to memory", cxxopts::value<size_t>()->default_value("10000000"))
			("parallel", "Max number of threads to use", cxxopts::value<size_t>()->default_value("4"))
			("kmer_len", "Length of the k-mers", cxxopts::value<uint32_t>())
			("maf", "Minor allele frequency", cxxopts::value<double>()->default_value("0.05")) 
			("mac", "Minor allele count", cxxopts::value<size_t>()->default_value("5"))
			("k_mers_scores", "output the best k_mers scores in binary format")
			("pattern_counter", "Count the number of unique presence/absence patterns")
			("help", "print help")
			;
		auto vm = options.parse(argc, argv);
		if (vm.count("help"))
		{
			cerr << options.help() << endl;
			exit(0);
		}
		/****************************************************************************************************/
		/* END of parsing and checking input parameters */
		/****************************************************************************************************/
		string fn_base = vm["output_dir"].as<string>() + "/" + vm["base_name"].as<string>();
		size_t heap_size = vm["best"].as<size_t>();	// # best k-mers to report
		size_t batch_size = vm["batch_size"].as<size_t>(); // part of kmers-table to import in each step
		ctpl::thread_pool tp(vm["parallel"].as<size_t>()); // How many threads can we use

		uint32_t kmer_length = vm["kmer_len"].as<uint32_t>(); // length of k-mers in table
		if((kmer_length > 31) || (kmer_length <10)) {
			cerr << "kmer length has to be between 10-31" << endl;
			exit(1);
		}

		double maf = vm["maf"].as<double>(); // Minor allele frequency
		size_t mac = vm["mac"].as<size_t>(); // Minor allele count

		// This option is for debug perpuses (run only on part of the data)
		uint64_t debug_option_batches_to_run = NULL_KEY;

		// Loading the phenotype (also include the list of needed accessions)
		pair<vector<string>, vector<PhenotypeList>> phenotypes_info = load_phenotypes_file(
				vm["phenotype_file"].as<string>());	
		size_t phenotypes_n = phenotypes_info.first.size();

		// Intersect phenotypes only to the present DBs (can also check if all must be present)
		for(size_t i=0; i<phenotypes_n; i++)
			phenotypes_info.second[i] = intersect_phenotypes_to_present_DBs(phenotypes_info.second[i], 
					vm["kmers_table"].as<string>(), true);
		vector<PhenotypeList> p_list{phenotypes_info.second};

		// Create heaps to save all best k-mers & scores
		vector<BestAssociationsHeap> k_heap;
		if(vm.count("first_phenotype_best")) { // save a different number of k-mers for the first phenotype
			k_heap.resize(1, BestAssociationsHeap(vm["first_phenotype_best"].as<size_t>()));
		} 
		k_heap.resize(phenotypes_n, BestAssociationsHeap(heap_size));

		// Convert the MAF & MAC to be one parameter => corrected MAC
		size_t n_accessions = p_list[0].first.size();
		size_t min_count = ceil(static_cast<double>(n_accessions)*maf); 
		if(min_count < mac)
			min_count = mac;
		cerr << "Effective minor allele count:\t" << min_count << endl;
		MultipleKmersDataBases kmers_table_for_associations(vm["kmers_table"].as<string>(),
				p_list[0].first, kmer_length);
		MultipleKmersDataBases kmers_table_for_output(vm["kmers_table"].as<string>(),
				p_list[0].first, kmer_length);

		vector<std::future<void> > tp_results(phenotypes_n);
		/***************************************************************************************
		 * Statistics to be collected during the association - here we define what to collect  */
		// Count unique presence absence patterns
		std::future<void> pattern_counter_fut;
		KmersSet pa_patterns_counter(1);
		pa_patterns_counter.set_empty_key(NULL_KEY); // need to define empty value for google dense hash table

		/****************************************************************************************************
		 *	Associate presence/absence information with phenotypes
		 ***************************************************************************************************/
		double t0,t1; // for timing measurments
		t0 = get_time();
		size_t batch_index = 0;
		while(kmers_table_for_associations.load_kmers(batch_size, min_count) 
				&& (batch_index < debug_option_batches_to_run)) {

			// status information
			t1 = get_time();cerr << "Load [" <<  batch_index << "]\t" << (double)(t1-t0)/(60.) << 
				"min" << endl; t0 = get_time();

			if(vm.count("pattern_counter")) // If count patterns is on
				pattern_counter_fut = tp.push([&kmers_table_for_associations,&pa_patterns_counter](int){
						kmers_table_for_associations.update_presence_absence_pattern_counter(pa_patterns_counter);});

			for(size_t j=0; j<(phenotypes_n); j++) { // Check association for each sample 
				tp_results[j] = tp.push([&kmers_table_for_associations,&k_heap,&p_list,j,min_count](int){
						kmers_table_for_associations.add_kmers_to_heap(k_heap[j], p_list[j].second, min_count);});
			}
			for(size_t j=0; j<(phenotypes_n); j++) {
				tp_results[j].get();
				cerr << "."; cerr.flush();
			}
			if(vm.count("pattern_counter"))
				pattern_counter_fut.get();

			t1 = get_time();cerr << "Associations [" <<  batch_index << "]\t" << (double)(t1-t0)/(60.) << 
				"min" << endl; t0 = get_time();
			batch_index++;
		}
		if(vm.count("pattern_counter"))
			cerr << "Total patterns\t" << pa_patterns_counter.size() << endl;

		/****************************************************************************************************
		 *	save best k-mers to files and create list of k-mers from heaps (and clear heaps)	
		 ***************************************************************************************************/
		vector<kmers_output_list> best_kmers;	
		for(size_t j=0; j<(phenotypes_n); j++) { // For some reason this can be improved by parallelization
			if (vm.count("k_mers_scores")) {
				string fn_kmers = fn_base + "." + std::to_string(j) + ".best_kmers";
				k_heap[j].output_to_file_with_scores(fn_kmers + ".scores");
			}

			// Create set of best k-mers
			best_kmers.push_back(k_heap[j].get_kmers_for_output(kmer_length));
			k_heap[j].empty_heap(); // clear heap
		}

		/****************************************************************************************************
		 *	Reload all k-mers and out to plink files only the best k-mers found in the previous stage
		 ***************************************************************************************************/
		// Open all bed & bim plink files	
		vector<BedBimFilesHandle> plink_output;
		for(size_t j=0; j<(phenotypes_n); j++) {
			plink_output.emplace_back(fn_base + "." + std::to_string(j) + "." + phenotypes_info.first[j] ) ;
			write_fam_file(p_list[j], fn_base + "." + std::to_string(j) + "." + phenotypes_info.first[j] 
					+ ".fam");
		}

		// Reload k-mers to create plink bed/bim files
		batch_index = 0;
		while(kmers_table_for_output.load_kmers(batch_size, min_count) 
				&& (batch_index<debug_option_batches_to_run)) {
			cerr << "Save [" <<  batch_index << "]" << endl;
			for(size_t j=0; j<(phenotypes_n); j++) { // Check association for each samples  
				best_kmers[j].next_index = 
					kmers_table_for_output.output_plink_bed_file(plink_output[j], 
							best_kmers[j].list, best_kmers[j].next_index); 
				cerr << "."; cerr.flush();	
			}
			cerr << endl;
			batch_index++;
		}

		// close all bed & bim plink files & (specific fam?)
		for(size_t j=0; j<plink_output.size(); j++)
			plink_output[j].close();

		if(vm.count("pattern_counter")) {
			ofstream fout(fn_base + ".pattern_counter");
			fout <<   pa_patterns_counter.size() << endl; 
			fout.close();
		}
		// Output to file the number of tested k-mers
		ofstream fout(fn_base + ".tested_kmers");
		fout << k_heap[0].number_of_insertion() << endl; 
		fout.close();


	} catch (const cxxopts::OptionException& e)
	{
		cerr << "error parsing options: " << e.what() << endl;
		cerr << options.help() << endl;
		exit(1);
	}
	return 0;
}
