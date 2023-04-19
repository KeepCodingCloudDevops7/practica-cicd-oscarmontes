all: clean init plan apply 

clean:
	cd .. && cd terraform/www && rm -fR terraform/ && rm -fR terraform.* && rm -fR .terraform.*

init:
	cd ../terraform/www && terraform init

plan:
	cd ../terraform/www && terraform plan

apply:
	cd ../terraform/www && terraform apply -auto-approve

destroy: 
	cd ../terraform/www && terraform destroy -auto-approve
