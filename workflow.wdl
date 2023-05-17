version 1.0

workflow read_coverage {

    meta {
        author: "Jean Monlong"
        email: "jmonlong@ucsc.edu"
        description: "Compute the read coverage across the genome by bin from an input BAM using mosdepth"
    }

    parameter_meta {
        BAM: "Input BAM. Must be sorted."
        BAM_INDEX: "Index of the sorted BAM input."
        BIN_SIZE: "Size of the bins, i.e. non-overlapping genomic windows where the read coverage will be aggregated. Default is 5000."
    }
    
    input {
        File BAM
        File BAM_INDEX
        Int? BIN_SIZE = 5000
    }

    call run_mosdepth {
        input:
        bam=BAM,
        bam_index=BAM_INDEX,
        bin_size=BIN_SIZE
    }
    
    output {
        File cov_bed = run_mosdepth.bed
    }
}

task run_mosdepth {
    input {
        File bam
        File bam_index
        Int? bin_size = 5000
        Int memSizeGB = 4
        Int threadCount = 1
        Int diskSizeGB = 2*round(size(bam, "GB")) + 20
    }

    String basen = basename(bam, ".bam")
    
    command <<<
        set -eux -o pipefail

        ln -s ~{bam} reads.bam
        ln -s ~{bam_index} reads.bam.bai
        
        mosdepth -b ~{bin_size} -n -x -m ~{basen} reads.bam
    >>>
    
    output {
        File bed = "~{basen}.regions.bed.gz"
    }
    
    runtime {
        memory: memSizeGB + " GB"
        cpu: threadCount
        disks: "local-disk " + diskSizeGB + " SSD"
        docker: "quay.io/biocontainers/mosdepth@sha256:d550465fce1cbfbe9cfe0facd4aa910b455f9ba93f4f4d701a08a7096e8f7d6e"
        preemptible: 2
    }
}
