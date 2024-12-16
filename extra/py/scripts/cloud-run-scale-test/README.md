# Scale Testing
# run the below from the entire repository root

# the below command uses the Dockerfile at <root>/Dockerfile
gcloud builds submit --tag gcr.io/juntochat-dev/kazm-scale-testing --timeout=1200 

gcloud run deploy kazm-scale-testing --image gcr.io/juntochat-dev/kazm-scale-testing --region us-central1 --platform managed --concurrency 1 --memory 4Gi --cpu 2


#Local
docker build -t kazm-scale-testing  . 
docker run --rm -p 8080:8080 -e PORT=8080 --shm-size=2g kazm-scale-testing