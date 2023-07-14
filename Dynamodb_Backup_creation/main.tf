name: Backup DynamoDB Table
	on:
	  push:
	    branches:
	      - Devenable-testing
	
	permissions:
	      id-token: write   # This is required for requesting the JWT
	      contents: read
	jobs:
	  restore-dynamodb:
	    runs-on: ubuntu-latest
	    steps:
	      - name: Checkout repository
	        uses: actions/checkout@v2
	
	      - name: Set up AWS credentials
	        uses: aws-actions/configure-aws-credentials@v1
	        with:
	          aws-region: eu-central-1
	          role-to-assume: ****************************
	          
	      - name: Checkout repository
	        uses: actions/checkout@v2
	        with:
	          repository: VenkySubbaraj/Terraform/
	          token: ${{ secrets.FULL_TOKEN }}        
	          path: './'
	
	      - name: Commit and push changes
	        run: |
	          echo "[url \"https://${{ secrets.FULL_TOKEN }}:x-oauth-basic@github.com/\"]"$'\n\t'"insteadOf = https://github.com/" >> ~/.gitconfig
	          
	      - name: Creating a table in Dynamodb via TF
	        run: |
	          ls
	          cd ffdp2.0/
	          terraform init 
	          terraform plan -lock=false 
	          terraform apply --auto-approve -lock=false
	          
	          
	          
	      - name: Creating a table backup
	        run: |
	          aws dynamodb create-backup --table-name RawEventEntity-default --backup-name Backup-RawEventEntity-stage
	          
	      - name: Get latest DynamoDB backup ARN
	        id: get-latest-backup
	        run: |
	          # Use AWS CLI to get the latest backup ARN
	          latest_backup_arn=$(aws dynamodb list-backups --table-name RawEventEntity-default --query "sort_by(BackupSummaries, &BackupCreationDateTime)[-1].BackupArn" --output text)
	          echo "backup_arn=$latest_backup_arn" >> $GITHUB_ENV
	          
	      - name: Check if DynamoDB table exists
	        id: table-check
	        run: |
	          aws dynamodb describe-table --table-name RawEventEntity-default20 --query "Table"
	        continue-on-error: true          
	          
	
	      - name: Creating table with backup ARN
	        if: steps.table-check.outcome != 'success'
	        run: |
	          aws dynamodb restore-table-from-backup --target-table-name RawEventEntity-default20 --backup-arn ${{ env.backup_arn}}
	
	          
	      - name: Restoring table with Dynamodb table backup
	        run: |
	          ls
	          cd ffdp2.0/
	          terraform init 
	          terraform state rm "module.metastore_stage.aws_dynamodb_table.this[\"RawEventEntity-default\"]"
	          terraform import "module.metastore_stage.aws_dynamodb_table.this[\"RawEventEntity-default\"]" RawEventEntity-default20
