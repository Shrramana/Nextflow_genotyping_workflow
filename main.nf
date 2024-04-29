#!/bin/bash


//Getting input file from the command line
params.input1 = file(args[0])
params.input2 = file(args[1])
//params.input3 = file("$baseDir/*.fna")


//Setting path for output dir
params.outdir = "$baseDir"

// process for assembly using skesa

process skesa { 
maxForks 1
publishDir("${params.outdir}", mode: 'copy')

//Setting input
input: 
file input1
file input2


//Setting output
output: 
path "skesa_assembly.fna", emit: out1

//Skesa command for assembly
script: 
""" 
skesa --reads $input1 $input2 --contigs_out skesa_assembly.fna 1> skesa.stdout.txt 2> skesa.stderr.txt 
""" 
} 


// Process for performing qa using quast

process qa { 
maxForks 3
publishDir("${params.outdir}", mode: 'copy')

//Setting input
input: 
file inputextra


//busco -m genome -i $inputextra --auto-lineage -o $baseDir


//qa command for
script: 
""" 
quast $inputextra -o $baseDir
""" 
} 


// process for performing genotyping using mlst

process genotype { 
maxForks 3
publishDir("${params.outdir}", mode: 'copy')

//Setting input
input: 
file asm


//Setting output
//output: 
//path "*"

//genotype command for
script: 
""" 
mlst $asm > MLST_Summary.tsv
""" 
} 

// Workflow to instruct on process sequence and setting channels for input 

workflow { 
	inp1_ch = Channel.fromPath(params.input1)
	inp2_ch = Channel.fromPath(params.input2)

	skesa_out=skesa(inp1_ch,inp2_ch)
	 qaa = skesa_out | qa & genotype
	 //geno = skesa_out | genotype

} 
