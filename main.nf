
nextflow.enable.dsl = 2

process COMPRESS {
    label 'compress'
    publishDir params.outdir
    
    input:
    tuple val(name), path(reads)
	
    output:
    tuple val(name), path("${name}*.gz"), emit: compressed_reads
	
script:
    """
    gzip -f ${reads[0]}
    gzip -f ${reads[1]}
    """
}

process DECOMPRESS {
    label 'decompress'
    publishDir params.outdir
    
    input:
    tuple val(name), path(reads)
	
    output:
    tuple val(name), path("${name}*fastq"), emit: decompressed_reads
	
    script:
    """
    gunzip -f ${reads[0]}
    gunzip -f ${reads[1]}
    """
}

workflow{

    read_pairs_ch = channel.fromFilePairs( params.reads, checkIfExists: true ) 
    COMPRESS(read_pairs_ch)
    DECOMPRESS(COMPRESS.out.compressed_reads)
}