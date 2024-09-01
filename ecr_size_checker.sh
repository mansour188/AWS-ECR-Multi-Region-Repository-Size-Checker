#!/bin/bash

repos=""
sizes=""
name_lens=""

# Check if user is logged in
if ! aws sts get-caller-identity &> /dev/null; then
  echo "ERROR: Seems like your SSO session is invalid. Please run"
  printf "\n  $ aws sso login\n\n"
  echo "before you run the script."
  exit 1
fi

# Get all AWS regions
regions=$(aws ec2 describe-regions --output json | jq -r .Regions[].RegionName)

# Loop through each region
for region in $regions; do
  echo "Processing region: $region"

  # Get the repositories in the current region
  data=$(aws ecr describe-repositories --region "$region" --output json | jq .repositories)
  repo_count=$(echo $data | jq length)
  index=1
  
  for name in $(echo $data | jq -r .[].repositoryName); do
    # Progress
    echo -en "\033[K"
    echo -n "[$index/$repo_count] GET $name in $region" $'\r'

    # Get size of all images in the repository
    size=$(aws ecr describe-images --region "$region" --repository-name "$name" --output json | jq .imageDetails[].imageSizeInBytes | awk '{s+=$1}END{OFMT="%.0f";print s}')

    if [ -n "$size" ]; then
      raw_size="$size"
      size=$(numfmt --to=iec --suffix=B --format "%.2f" $size)
    else
      raw_size="0"
      size="<no-images>"
    fi
    
    repos="${repos}$region/$name $size\n"
    sizes="${sizes}$raw_size\n"
    name_lens="${name_lens}${#name}\n"
    
    index=$(expr $index + 1)
  done
done

# Sort repos by size
repos=$(printf "$repos" | sort -k2 -h)

# Add separator before total
max_name_len=$(printf $name_lens | sort -n | tail -1)
repos="${repos}\n$(printf -- '-%.0s' $(seq ${max_name_len})) --------\n"

# Add total size
total=$(printf $sizes | awk '{s+=$1}END{OFMT="%.0f";print s}')
repos="${repos}TOTAL $(numfmt --to=iec --suffix=B --format "%.2f" $total)\n"

# Print final table
printf "$repos" | column -t --table-columns REGION/REPOSITORY,SIZE -R SIZE
