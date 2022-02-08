variable "lambda_function_name" {
  default = "EMR_instance"
 }
 variable "lambda_handler" {
  default = "index.lambda_handler"
 }
 variable "function_name" {
  default = "Lambda_instance"
 }
 variable "handler" {
  default = "index.lambda_handler"
 }
 variable "runtime" {
  default = "python3.8"
 }
 
 variable "component" {
  default = "my-lambda2"
 }
 
 variable "deployment_identifier" {
  default = "production"
 }
 
 variable "region" {
  default = "ap-south-1"
 }
