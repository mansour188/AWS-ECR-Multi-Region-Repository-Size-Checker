# AWS ECR Multi-Region Repository Size Checker

This script retrieves the sizes of images in all Amazon Elastic Container Registry (ECR) repositories across all AWS regions and displays them in a sorted table. It ensures that the user is logged in via AWS SSO before execution.

## Prerequisites

- AWS CLI installed and configured.
- AWS SSO session active.
- `jq` installed for processing JSON data.
- `awk` and `numfmt` utilities available on your system (standard on most Unix/Linux distributions).

## How to Use

1. **Ensure AWS SSO session is active**:
   Before running the script, ensure that you are logged in to your AWS account using AWS SSO.

   ```bash
   aws sso login
   ```
## Run the Script:
```bash
./ecr_size_checker.sh

```

# Output 

```bash
    Processing region: us-east-1
[1/3] GET my-repo-1 in us-east-1
[2/3] GET my-repo-2 in us-east-1
[3/3] GET my-repo-3 in us-east-1
Processing region: eu-west-1
[1/2] GET my-repo-4 in eu-west-1
[2/2] GET my-repo-5 in eu-west-1

us-east-1/my-repo-1  500MB
us-east-1/my-repo-2  2.3GB
us-east-1/my-repo-3  <no-images>
eu-west-1/my-repo-4  1.1GB
eu-west-1/my-repo-5  750MB
--------------------------------------
TOTAL                4.65GB

```