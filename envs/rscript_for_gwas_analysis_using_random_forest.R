# create parser object
parser <- ArgumentParser()

# specify our desired options 
# by default ArgumentParser will add an help option 
parser$add_argument("-v", "--vcf", default=NULL, type = "character",
                    help="Path to VCF file (gzipped or not)")
parser$add_argument("-p", "--phenotype", default=NULL, type="character", 
                    help="Phenotype input file")
parser$add_argument("-n", "--snps", type="integer", default=-1, 
                    help="Number of SNPs to consider in input file",
                    metavar="number")


parser$add_argument("-c", "--count", type="integer", default=5, 
                    help="Number of random normals to generate [default %(default)s]",
                    metavar="number")
parser$add_argument("--generator", default="rnorm", 
                    help = "Function to generate random deviates [default \"%(default)s\"]")
parser$add_argument("--mean", default=0, type="double",
                    help="Mean if generator == \"rnorm\" [default %(default)s]")
parser$add_argument("--sd", default=1, type="double",
                    metavar="standard deviation",
                    help="Standard deviation if generator == \"rnorm\" [default %(default)s]")

# get command line options, if help option encountered print help and exit,
# otherwise if options not found on command line then set defaults, 
args <- parser$parse_args()


# vcfR parameters
vcf_file_path: "data/chr01_7000SNPs_vcf.gz"         # path to VCF file (gzipped or not)
n_snps: 100                                         # number of rows in VCF file to read. Set to "-1" to read all lines"

# MUVR parameters
n_cores: 2                # Number of processor threads to use
n_repetitions: 3          # Number of MUVR repetitions (whole dataset, whole process)
n_outer: 8                # Number of outer cross-validation segments
n_inner: 4                # number of inner cross-validation segments
variable_ratio: 0.8       # Proportion of variables kept per iteration (recursive variable elimination) 
n_permutations: 10        # Number of permutations (here set to 25 for illustration; normally set to ≥100) 

