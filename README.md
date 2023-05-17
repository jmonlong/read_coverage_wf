# Read coverage computation workflow

Simple workflow that computes the read coverage in bins (non-overlapping genomic windows) using [mosdepth](https://github.com/brentp/mosdepth).
The input must be a sorted BAM and its index.

## Test locally

```
miniwdl run --as-me -i test/test.inputs.json workflow.wdl
```
